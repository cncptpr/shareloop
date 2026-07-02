import base64
import os
import uuid as uuid_mod

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import exists, select
from sqlalchemy import func as sa_func
from sqlalchemy.ext.asyncio import AsyncSession

from src.config import settings
from src.database import get_db
from src.db.models import Follow, Item, ItemImage, Profile, RentRequest, User, UserRating
from src.dependencies import get_current_user, get_optional_user
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
async def api_get_user_profile(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User | None = Depends(get_optional_user),
):
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
            sa_func.avg(
                (
                    UserRating.friendliness
                    + UserRating.punctuality
                    + UserRating.reliability
                    + sa_func.coalesce(UserRating.communication, UserRating.careful_handling)
                )
                / 4.0
            )
        ).where(UserRating.reviewee_id == user_id)
    )
    avg_rating = avg_rating_result.scalar_one_or_none()

    share_count_result = await db.execute(
        select(sa_func.count(RentRequest.id)).where(
            RentRequest.requester_id == user_id,
            RentRequest.borrow_confirmed_at.isnot(None),
            RentRequest.returned_at.isnot(None),
        )
    )
    share_count = share_count_result.scalar() or 0

    follower_count_result = await db.execute(
        select(sa_func.count(Follow.followed_id)).where(Follow.followed_id == user_id)
    )
    follower_count = follower_count_result.scalar() or 0

    is_followed = None
    if current_user is not None:
        is_followed_result = await db.execute(
            select(
                exists(
                    select(Follow).where(
                        Follow.follower_id == current_user.id,
                        Follow.followed_id == user_id,
                    )
                )
            )
        )
        is_followed = is_followed_result.scalar() or False

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
        follower_count=follower_count,
        is_followed=is_followed,
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
        profile = Profile(id=user_id, name=body.name or "")
        db.add(profile)
    if body.name is not None:
        profile.name = body.name
    if body.bio is not None:
        profile.bio = body.bio
    await db.commit()
    await db.refresh(profile)

    return await api_get_user_profile(user_id, db, current_user)


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
        if os.path.isdir(settings.uploads_dir):
            for fname in os.listdir(settings.uploads_dir):
                if fname.startswith(str(profile.avatar_uuid)):
                    os.remove(os.path.join(settings.uploads_dir, fname))
                    break

    try:
        raw = base64.b64decode(body.data)
    except Exception:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR) from None
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

    if profile.avatar_uuid is not None and os.path.isdir(settings.uploads_dir):
        for fname in os.listdir(settings.uploads_dir):
            if fname.startswith(str(profile.avatar_uuid)):
                os.remove(os.path.join(settings.uploads_dir, fname))
                break
        profile.avatar_uuid = None
        await db.commit()

    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/api/users/{user_id}/follow", status_code=status.HTTP_201_CREATED)
async def api_follow_user(
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if user_id == current_user.id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot follow yourself")

    target_exists = await db.execute(
        select(exists(select(User).where(User.id == user_id)))
    )
    if not target_exists.scalar():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    already_following = await db.execute(
        select(
            exists(
                select(Follow).where(
                    Follow.follower_id == current_user.id,
                    Follow.followed_id == user_id,
                )
            )
        )
    )
    if already_following.scalar():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Already following")

    db.add(Follow(follower_id=current_user.id, followed_id=user_id))
    await db.commit()

    return Response(status_code=status.HTTP_201_CREATED)


@router.delete("/api/users/{user_id}/follow", status_code=status.HTTP_204_NO_CONTENT)
async def api_unfollow_user(
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Follow).where(
            Follow.follower_id == current_user.id,
            Follow.followed_id == user_id,
        )
    )
    follow = result.scalar_one_or_none()
    if follow is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Not following")

    await db.delete(follow)
    await db.commit()

    return Response(status_code=status.HTTP_204_NO_CONTENT)
