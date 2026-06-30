from datetime import datetime

from sqlalchemy import select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.models import ItemRating, Profile, UserRating
from src.models.openapi import ItemRating as ApiItemRating
from src.models.openapi import Person
from src.models.openapi import UserRating as ApiUserRating

DEFAULT_LAST_READ = "1970-01-01T00:00:00.000Z"


def _ts_to_str(dt: datetime | None) -> str:
    if dt is None:
        return DEFAULT_LAST_READ
    return dt.isoformat().replace("+00:00", "Z")


def _user_rating_from_row(rating: UserRating) -> ApiUserRating:
    return ApiUserRating(
        id=rating.id,
        rent_request_id=rating.rent_request_id,
        reviewer_id=rating.reviewer_id,
        reviewee_id=rating.reviewee_id,
        friendliness=rating.friendliness,
        punctuality=rating.punctuality,
        reliability=rating.reliability,
        communication=rating.communication,
        careful_handling=rating.careful_handling,
        comment=rating.comment,
        created_at=_ts_to_str(rating.created_at),
    )


def _item_rating_from_row(rating: ItemRating, reviewer: Profile) -> ApiItemRating:
    return ApiItemRating(
        id=rating.id,
        rent_request_id=rating.rent_request_id,
        item_id=rating.item_id,
        reviewer=Person(id=reviewer.id, name=reviewer.name),
        condition=rating.condition,
        cleanliness=rating.cleanliness,
        overall=rating.overall,
        comment=rating.comment,
        created_at=_ts_to_str(rating.created_at),
    )


async def _get_user_rating_by_reviewer(
    db: AsyncSession, request_id: int, reviewer_id: int
) -> ApiUserRating | None:
    try:
        result = await db.execute(
            select(UserRating).where(
                UserRating.rent_request_id == request_id,
                UserRating.reviewer_id == reviewer_id,
            )
        )
    except SQLAlchemyError:
        await db.rollback()
        return None

    rating = result.scalar_one_or_none()
    if rating is None:
        return None
    return _user_rating_from_row(rating)


async def _get_item_rating_by_reviewer(
    db: AsyncSession, request_id: int, reviewer_id: int
) -> ApiItemRating | None:
    try:
        result = await db.execute(
            select(ItemRating, Profile)
            .join(Profile, Profile.id == ItemRating.reviewer_id)
            .where(
                ItemRating.rent_request_id == request_id,
                ItemRating.reviewer_id == reviewer_id,
            )
        )
    except SQLAlchemyError:
        await db.rollback()
        return None

    row = result.one_or_none()
    if row is None:
        return None
    rating, reviewer = row
    return _item_rating_from_row(rating, reviewer)
