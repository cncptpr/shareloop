import os
import uuid as uuid_pkg

from fastapi import APIRouter, Depends, HTTPException, status
from geoalchemy2 import Geography as GeoAlchemyGeography
from geoalchemy2 import Geometry
from sqlalchemy import func as sa_func
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession

from src.config import settings
from src.database import get_db
from src.db.models import Item, ItemImage, ItemRating, Profile
from src.dependencies import get_current_user
from src.models.openapi import (
    CreateItemRequest,
    CreateItemResponse,
    EditItemImagesRequest,
    ItemDetail,
    ItemEditDetail,
    ItemSearchRequest,
    Person,
    UpdateItemRequest,
    UploadItemImageRequest,
    UploadItemImageResponse,
)
from src.models.openapi import (
    ItemRating as ApiItemRating,
)
from src.services.featured_items import get_featured_items
from src.services.search import search_items

router = APIRouter(tags=["items"])


@router.post("/api/featured-items")
async def api_get_featured_items(
    body: dict | None = None,
    db: AsyncSession = Depends(get_db),
):
    location = None
    if body and "lat" in body and "lng" in body:
        from src.models.openapi import LatLng

        location = LatLng(lat=body["lat"], lng=body["lng"])
    items = await get_featured_items(db, location)
    return items


@router.post("/api/items/search")
async def api_search_items(
    body: ItemSearchRequest | None = None,
    db: AsyncSession = Depends(get_db),
):
    if body is None:
        return []
    items = await search_items(db, body)
    return items


@router.post("/api/items", status_code=status.HTTP_201_CREATED)
async def api_create_item(
    body: CreateItemRequest,
    user=Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if not body.city or not body.postal_code:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)

    item = Item(
        title=body.title,
        description=body.description,
        author_id=user.id,
        score=0.0,
        location=sa_func.st_setsrid(sa_func.st_makepoint(body.lng, body.lat), 4326).cast(
            GeoAlchemyGeography(srid=4326)
        ),
        city=body.city,
        postal_code=body.postal_code,
        address=body.address,
        category=body.category,
        price_per_day=body.price_per_day,
    )
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return CreateItemResponse(id=item.id)


@router.get("/api/items/{item_id}")
async def api_get_item(item_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
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
            Item.price_per_day,
            Item.address,
            sa_func.to_char(Item.created_at, "YYYY-MM-DDThh24:mi:ssZ").label("created_at"),
        )
        .select_from(Item)
        .join(Profile, Profile.id == Item.author_id)
        .where(Item.id == item_id)
    )
    row = result.one_or_none()
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    img_result = await db.execute(
        select(ItemImage.id)
        .where(ItemImage.item_id == item_id)
        .order_by(ItemImage.sort_order, ItemImage.created_at)
    )
    image_uuids = [str(r[0]) for r in img_result.all()]

    rating_result = await db.execute(
        select(ItemRating, Profile)
        .join(Profile, Profile.id == ItemRating.reviewer_id)
        .where(ItemRating.item_id == item_id)
        .order_by(ItemRating.created_at.desc())
    )
    rating_rows = rating_result.all()
    item_ratings = [
        ApiItemRating(
            id=rating.id,
            rent_request_id=rating.rent_request_id,
            item_id=rating.item_id,
            reviewer=Person(id=reviewer.id, name=reviewer.name),
            condition=rating.condition,
            cleanliness=rating.cleanliness,
            overall=rating.overall,
            comment=rating.comment,
            created_at=rating.created_at.isoformat().replace("+00:00", "Z"),
        )
        for rating, reviewer in rating_rows
    ]
    return ItemDetail(
        id=row.id,
        title=row.title,
        description=row.description,
        author=Person(id=row.author_id, name=row.author_name),
        score=row.score,
        city=row.city,
        postal_code=row.postal_code,
        address=row.address,
        image_uuids=image_uuids,
        category=row.category,
        price_per_day=row.price_per_day,
        created_at=row.created_at,
        item_rating_count=len(item_ratings),
        item_ratings=item_ratings,
    )


@router.put("/api/items/{item_id}")
async def api_update_item(
    item_id: int,
    body: UpdateItemRequest,
    user=Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Item).where(Item.id == item_id))
    item = result.scalar_one_or_none()
    if item is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    if item.author_id != user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)

    if not body.city or not body.postal_code:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    item.title = body.title
    item.description = body.description
    item.city = body.city
    item.postal_code = body.postal_code
    item.address = body.address
    item.category = body.category
    item.price_per_day = body.price_per_day
    item.location = sa_func.st_setsrid(sa_func.st_makepoint(body.lng, body.lat), 4326).cast(
        GeoAlchemyGeography(srid=4326)
    )
    await db.commit()
    return CreateItemResponse(id=item.id)


@router.get("/api/items/{item_id}/edit")
async def api_get_item_edit(
    item_id: int,
    user=Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
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
            Item.price_per_day,
            Item.address,
            sa_func.st_x(Item.location.cast(Geometry(srid=4326))).label("lng"),
            sa_func.st_y(Item.location.cast(Geometry(srid=4326))).label("lat"),
            sa_func.to_char(Item.created_at, "YYYY-MM-DDThh24:mi:ssZ").label("created_at"),
        )
        .select_from(Item)
        .join(Profile, Profile.id == Item.author_id)
        .where(Item.id == item_id)
    )
    row = result.one_or_none()
    if row is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    if row.author_id != user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)

    img_result = await db.execute(
        select(ItemImage.id)
        .where(ItemImage.item_id == item_id)
        .order_by(ItemImage.sort_order, ItemImage.created_at)
    )
    image_uuids = [str(r[0]) for r in img_result.all()]

    return ItemEditDetail(
        id=row.id,
        title=row.title,
        description=row.description,
        author=Person(id=row.author_id, name=row.author_name),
        score=row.score,
        city=row.city,
        postal_code=row.postal_code,
        address=row.address,
        image_uuids=image_uuids,
        category=row.category,
        price_per_day=row.price_per_day,
        lat=row.lat,
        lng=row.lng,
        created_at=row.created_at,
    )


@router.post("/api/items/{item_id}/images", status_code=status.HTTP_201_CREATED)
async def api_upload_item_image(
    item_id: int,
    body: UploadItemImageRequest,
    user=Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Item).where(Item.id == item_id))
    item = result.scalar_one_or_none()
    if item is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    if item.author_id != user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)

    import base64

    try:
        image_bytes = base64.b64decode(body.data)
    except Exception:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR) from None

    ext, mime = _detect_ext_and_mime(body.filename)
    image_uuid = uuid_pkg.uuid4()
    uuid_string = str(image_uuid)
    filepath = os.path.join(settings.uploads_dir, f"{uuid_string}.{ext}")

    os.makedirs(settings.uploads_dir, exist_ok=True)
    with open(filepath, "wb") as f:
        f.write(image_bytes)

    img = ItemImage(
        id=image_uuid,
        item_id=item_id,
        original_name=body.filename,
        mime_type=mime,
        sort_order=body.sort_order,
    )
    db.add(img)
    try:
        await db.commit()
    except Exception:
        if os.path.exists(filepath):
            os.remove(filepath)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR) from None

    return UploadItemImageResponse(uuid=image_uuid)


@router.put("/api/items/{item_id}/images", status_code=status.HTTP_204_NO_CONTENT)
async def api_edit_item_images(
    item_id: int,
    body: EditItemImagesRequest,
    user=Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Item).where(Item.id == item_id))
    item = result.scalar_one_or_none()
    if item is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    if item.author_id != user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)

    for uuid_str in body.delete:
        try:
            parsed = uuid_pkg.UUID(uuid_str) if isinstance(uuid_str, str) else uuid_str
        except Exception:
            continue
        img_result = await db.execute(
            select(ItemImage).where(ItemImage.id == parsed, ItemImage.item_id == item_id)
        )
        img = img_result.scalar_one_or_none()
        if img:
            ext = _detect_ext(img.original_name)
            filepath = os.path.join(settings.uploads_dir, f"{uuid_str}.{ext}")
            if os.path.exists(filepath):
                os.remove(filepath)
            await db.delete(img)

    for entry in body.reorder:
        try:
            parsed = uuid_pkg.UUID(entry.uuid) if isinstance(entry.uuid, str) else entry.uuid
        except Exception:
            continue
        await db.execute(
            text(
                "UPDATE item_images SET sort_order = :sort_order WHERE id = :id AND item_id = :item_id"
            ),
            {"sort_order": entry.sort_order, "id": str(parsed), "item_id": item_id},
        )

    await db.commit()


def _detect_ext_and_mime(filename: str) -> tuple[str, str]:
    parts = filename.rsplit(".", 1)
    ext = parts[-1].lower() if len(parts) > 1 else "jpg"
    ext_map = {"jpg": "jpg", "jpeg": "jpg", "png": "png", "gif": "gif", "webp": "webp"}
    ext = ext_map.get(ext, "jpg")
    mime_map = {"png": "image/png", "gif": "image/gif", "webp": "image/webp"}
    mime = mime_map.get(ext, "image/jpeg")
    return ext, mime


def _detect_ext(filename: str) -> str:
    parts = filename.rsplit(".", 1)
    ext = parts[-1].lower() if len(parts) > 1 else "jpg"
    ext_map = {"jpg": "jpg", "jpeg": "jpg", "png": "png", "gif": "gif", "webp": "webp"}
    return ext_map.get(ext, "jpg")
