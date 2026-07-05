from geoalchemy2 import Geography
from sqlalchemy import cast as sa_cast
from sqlalchemy import func as sa_func
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.models import Item, ItemImage, Profile
from src.models.openapi import ItemOverview, LatLng, Person


async def get_featured_items(
    db: AsyncSession, location: LatLng | None
) -> list[ItemOverview]:
    if location:
        return await _get_with_distance(db, location.lat, location.lng)
    return await _get_without_distance(db)


def _first_image_subquery():
    return (
        select(ItemImage.id)
        .where(ItemImage.item_id == Item.id)
        .order_by(ItemImage.sort_order, ItemImage.created_at)
        .limit(1)
        .correlate(Item)
        .scalar_subquery()
    )


def _distance_expr(lat: float, lng: float):
    point = sa_cast(
        sa_func.st_setsrid(sa_func.st_makepoint(lng, lat), 4326),
        Geography(srid=4326),
    )
    return sa_func.coalesce(
        sa_func.st_distance(Item.location, point) / 1000,
        0.0,
    )


async def _get_with_distance(db: AsyncSession, lat: float, lng: float) -> list[ItemOverview]:
    distance = _distance_expr(lat, lng)
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
            Item.price_per_day,
            distance.label("distance_km"),
            _first_image_subquery().label("first_image_uuid"),
        )
        .select_from(Item)
        .join(Profile, Profile.id == Item.author_id)
        .order_by(Item.score.desc())
    )
    result = await db.execute(stmt)
    rows = result.all()
    return [_row_to_overview(row, has_distance=True) for row in rows]


async def _get_without_distance(db: AsyncSession) -> list[ItemOverview]:
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
            Item.price_per_day,
            _first_image_subquery().label("first_image_uuid"),
        )
        .select_from(Item)
        .join(Profile, Profile.id == Item.author_id)
        .order_by(Item.score.desc())
    )
    result = await db.execute(stmt)
    rows = result.all()
    return [_row_to_overview(row, has_distance=False) for row in rows]


def _row_to_overview(row, has_distance: bool) -> ItemOverview:
    first_img = row.first_image_uuid
    return ItemOverview(
        id=row.id,
        title=row.title,
        description=row.description,
        author=Person(id=row.author_id, name=row.author_name),
        distance=({"km": row.distance_km} if has_distance else None),
        city=row.city,
        postal_code=row.postal_code,
        score=row.score,
        image_uuid=str(first_img) if first_img else None,
        category=row.category,
        price_per_day=row.price_per_day,
    )
