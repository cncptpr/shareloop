import base64
import os
import uuid as uuid_mod

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import func as sa_func
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.config import settings
from src.database import get_db
from src.db.models import Item, ItemImage, Profile, RentRequest, User, UserRating
from src.dependencies import get_current_user
from src.models.openapi import (
    ItemOverview,
    Person,
    UpdateUserProfileRequest,
    UploadItemImageRequest,
    UploadItemImageResponse,
    UserProfile,
    UserRatingDetail,
)

router = APIRouter(tags=["users"])


@router.get("/api/users/{user_id}/profile")
async def api_get_user_profile(user_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(
            User.id,
            User.email,
            User.last_online_at,
            User.created_at,
            Profile.name,
            Profile.bio,
            Profile.avatar_uuid,
        )
        .select_from(User)
        .outerjoin(Profile, Profile.id == User.id)
        .where(User.id == user_id)
    )
    row = result.one_or_none()
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    item_count_result = await db.execute(
        select(sa_func.count(Item.id)).where(Item.author_id == user_id)
    )
    item_count = item_count_result.scalar() or 0

    rating_count_result = await db.execute(
        select(sa_func.count(UserRating.id)).where(UserRating.reviewee_id == user_id)
    )
    rating_count = rating_count_result.scalar() or 0

    avg_rating_result = await db.execute(
        select(
            (
                sa_func.coalesce(sa_func.avg(UserRating.friendliness), 0)
                + sa_func.coalesce(sa_func.avg(UserRating.punctuality), 0)
                + sa_func.coalesce(sa_func.avg(UserRating.reliability), 0)
                + sa_func.coalesce(sa_func.avg(UserRating.communication), 0)
                + sa_func.coalesce(sa_func.avg(UserRating.careful_handling), 0)
            )
            / 5
        ).where(UserRating.reviewee_id == user_id)
    )
    avg_rating = avg_rating_result.scalar()

    share_count_result = await db.execute(
        select(sa_func.count(RentRequest.id)).where(
            RentRequest.requester_id == user_id,
            RentRequest.borrow_confirmed_at.isnot(None),
            RentRequest.returned_at.isnot(None),
        )
    )
    share_count = share_count_result.scalar() or 0

    return UserProfile(
        id=row.id,
        name=row.name or "",
        email=row.email,
        bio=row.bio,
        rating=avg_rating,
        created_at=row.created_at,
        last_online_at=row.last_online_at,
        item_count=item_count,
        rating_count=rating_count,
        share_count=share_count,
        avatar_uuid=str(row.avatar_uuid) if row.avatar_uuid else None,
    )


@router.patch("/api/users/{user_id}/profile")
async def api_update_user_profile(
    user_id: int,
    body: UpdateUserProfileRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)

    profile = await db.get(Profile, user_id)
    if profile is None:
        profile = Profile(id=user_id)
        db.add(profile)
    if body.name is not None:
        profile.name = body.name
    if body.bio is not None:
        profile.bio = body.bio
    await db.commit()
    await db.refresh(profile)

    return await api_get_user_profile(user_id, db)


@router.get("/api/users/{user_id}/items")
async def api_get_user_items(user_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(User).where(User.id == user_id)
    )
    if result.scalar_one_or_none() is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    first_image = (
        select(ItemImage.id)
        .where(ItemImage.item_id == Item.id)
        .order_by(ItemImage.sort_order, ItemImage.created_at)
        .limit(1)
        .correlate(Item)
        .scalar_subquery()
    )

    stmt = (
        select(
            Item.id,
            Item.title,
            Item.description,
            Profile.name.label("author_name"),
            Item.author_id,
            Item.score,
            Item.city,
            Item.postal_code,
            Item.category,
            first_image.label("first_image_uuid"),
        )
        .select_from(Item)
        .join(Profile, Profile.id == Item.author_id)
        .where(Item.author_id == user_id)
        .order_by(Item.created_at.desc())
    )
    rows = (await db.execute(stmt)).all()
    return [
        ItemOverview(
            id=row.id,
            title=row.title,
            description=row.description,
            author=Person(id=row.author_id, name=row.author_name),
            city=row.city,
            postal_code=row.postal_code,
            score=row.score,
            image_uuid=str(row.first_image_uuid) if row.first_image_uuid else None,
            category=row.category,
        )
        for row in rows
    ]


@router.get("/api/users/{user_id}/ratings")
async def api_get_user_ratings(user_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(User).where(User.id == user_id)
    )
    if result.scalar_one_or_none() is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    rating_result = await db.execute(
        select(UserRating, Profile)
        .join(Profile, Profile.id == UserRating.reviewer_id)
        .where(UserRating.reviewee_id == user_id)
        .order_by(UserRating.created_at.desc())
    )
    rows = rating_result.all()
    return [
        UserRatingDetail(
            id=rating.id,
            reviewer=Person(id=reviewer.id, name=reviewer.name),
            friendliness=rating.friendliness,
            punctuality=rating.punctuality,
            reliability=rating.reliability,
            communication=rating.communication,
            careful_handling=rating.careful_handling,
            comment=rating.comment,
            created_at=rating.created_at,
        )
        for rating, reviewer in rows
    ]


def _detect_ext_mime(filename: str):
    parts = filename.rsplit(".", 1)
    ext = parts[-1].lower() if len(parts) > 1 else ""
    mapping = {"jpg": "jpg", "jpeg": "jpg", "png": "png", "gif": "gif", "webp": "webp"}
    ext = mapping.get(ext, "jpg")
    mime = {"png": "image/png", "gif": "image/gif", "webp": "image/webp"}.get(ext, "image/jpeg")
    return ext, mime


@router.post("/api/users/{user_id}/avatar", status_code=status.HTTP_201_CREATED)
async def api_upload_user_avatar(
    user_id: int,
    body: UploadItemImageRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)

    profile = await db.get(Profile, user_id)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    if profile.avatar_uuid is not None:
        old_ext, _ = _detect_ext_mime("")
        for fname in os.listdir(settings.uploads_dir):
            if fname.startswith(str(profile.avatar_uuid)):
                os.remove(os.path.join(settings.uploads_dir, fname))
                break

    raw = base64.b64decode(body.data)
    ext = _detect_ext_mime(body.filename)[0]
    image_uuid = uuid_mod.uuid4()
    dest = os.path.join(settings.uploads_dir, f"{image_uuid}.{ext}")
    os.makedirs(settings.uploads_dir, exist_ok=True)
    with open(dest, "wb") as f:
        f.write(raw)

    profile.avatar_uuid = image_uuid
    await db.commit()

    return UploadItemImageResponse(uuid=str(image_uuid))


@router.delete("/api/users/{user_id}/avatar", status_code=status.HTTP_204_NO_CONTENT)
async def api_delete_user_avatar(
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)

    profile = await db.get(Profile, user_id)
    if profile is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    if profile.avatar_uuid is not None:
        for fname in os.listdir(settings.uploads_dir):
            if fname.startswith(str(profile.avatar_uuid)):
                os.remove(os.path.join(settings.uploads_dir, fname))
                break
        profile.avatar_uuid = None
        await db.commit()

    return Response(status_code=status.HTTP_204_NO_CONTENT)
