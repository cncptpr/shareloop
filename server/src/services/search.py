from geoalchemy2 import Geography
from sqlalchemy import case, select
from sqlalchemy import cast as sa_cast
from sqlalchemy import func as sa_func
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.models import Item, ItemImage, Profile
from src.models.openapi import ItemOverview, ItemSearchRequest, Person, SortBy


async def search_items(db: AsyncSession, req: ItemSearchRequest) -> list[ItemOverview]:
    lat = req.lat or 0.0
    lng = req.lng or 0.0
    query_str = req.query or ""
    categories = req.categories or []
    min_score = req.min_score or 0.0
    max_distance_km = req.max_distance_km or 0.0
    sort_by_enum = req.sort_by

    point = sa_cast(
        sa_func.st_setsrid(sa_func.st_makepoint(lng, lat), 4326),
        Geography(srid=4326),
    )
    distance_expr = sa_func.coalesce(
        sa_func.st_distance(Item.location, point) / 1000,
        0.0,
    )

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
            Item.address,
            Item.category,
            Item.price_per_day,
            distance_expr.label("distance_km"),
            first_image.label("first_image_uuid"),
        )
        .select_from(Item)
        .join(Profile, Profile.id == Item.author_id)
    )

    conditions = []

    if query_str:
        pattern = f"%{query_str}%"
        conditions.append(
            Item.title.ilike(pattern) | Item.description.ilike(pattern)
        )

    if categories:
        conditions.append(Item.category.in_(categories))

    if min_score > 0:
        conditions.append(Item.score >= min_score)

    if max_distance_km > 0:
        conditions.append(distance_expr <= max_distance_km)

    if conditions:
        stmt = stmt.where(*conditions)

    order_col = case(
        (sort_by_enum == SortBy.distance, distance_expr),
        (sort_by_enum == SortBy.score, -Item.score),
        (sort_by_enum == SortBy.newest, -sa_func.extract("epoch", Item.created_at)),
        else_=Item.score,
    ).desc() if sort_by_enum else Item.score.desc()

    stmt = stmt.order_by(order_col)

    result = await db.execute(stmt)
    rows = result.all()
    return [
        ItemOverview(
            id=row.id,
            title=row.title,
            description=row.description,
            author=Person(id=row.author_id, name=row.author_name),
            distance={"km": row.distance_km},
            city=row.city,
            postal_code=row.postal_code,
            address=row.address,
            score=row.score,
            image_uuid=str(row.first_image_uuid) if row.first_image_uuid else None,
            category=row.category,
            price_per_day=row.price_per_day,
        )
        for row in rows
    ]
