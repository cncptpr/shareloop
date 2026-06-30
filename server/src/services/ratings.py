from datetime import UTC, datetime

from sqlalchemy import func as sa_func
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.models import Item, ItemRating, Profile, UserRating
from src.models.openapi import (
    ItemRating as ApiItemRating,
)
from src.models.openapi import (
    SubmitItemRatingRequest,
    SubmitUserRatingRequest,
)
from src.models.openapi import (
    UserRating as ApiUserRating,
)
from src.services.rating_common import (
    _get_item_rating_by_reviewer,
    _get_user_rating_by_reviewer,
    _item_rating_from_row,
    _user_rating_from_row,
)
from src.services.renting import (
    _get_request_detail_row,
)


def _normalize_comment(comment: str | None) -> str | None:
    if comment is None:
        return None
    normalized = comment.strip()
    return normalized or None


async def _refresh_profile_rating(db: AsyncSession, user_id: int) -> None:
    result = await db.execute(select(Profile).where(Profile.id == user_id))
    profile = result.scalar_one_or_none()
    if profile is None:
        return

    average_expr = sa_func.avg(
        (
            UserRating.friendliness
            + UserRating.punctuality
            + UserRating.reliability
            + sa_func.coalesce(UserRating.communication, UserRating.careful_handling)
        )
        / 4.0
    )
    result = await db.execute(select(average_expr).where(UserRating.reviewee_id == user_id))
    average = result.scalar_one_or_none()
    profile.rating = float(average) if average is not None else None
    profile.updated_at = datetime.now(UTC)


async def _refresh_item_score(db: AsyncSession, item: Item) -> None:
    result = await db.execute(
        select(sa_func.avg(ItemRating.overall)).where(ItemRating.item_id == item.id)
    )
    average = result.scalar_one()
    item.score = float(average)


async def submit_user_rating(
    db: AsyncSession,
    request_id: int,
    user_id: int,
    user_input: SubmitUserRatingRequest,
) -> tuple[str, ApiUserRating | None]:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return "not_found", None
    rr, item, _, _ = data
    if user_id not in (rr.requester_id, item.author_id):
        return "forbidden", None
    if rr.returned_at is None:
        return "invalid", None

    is_requester = user_id == rr.requester_id
    if is_requester:
        valid_role_fields = (
            user_input.communication is not None and user_input.careful_handling is None
        )
    else:
        valid_role_fields = (
            user_input.communication is None and user_input.careful_handling is not None
        )
    if not valid_role_fields:
        return "invalid", None

    existing_user_rating = await _get_user_rating_by_reviewer(db, request_id, user_id)
    if existing_user_rating is not None:
        return "conflict", None
    reviewee_id = item.author_id if is_requester else rr.requester_id
    user_comment = _normalize_comment(user_input.comment)

    user_rating = UserRating(
        rent_request_id=request_id,
        reviewer_id=user_id,
        reviewee_id=reviewee_id,
        friendliness=user_input.friendliness,
        punctuality=user_input.punctuality,
        reliability=user_input.reliability,
        communication=user_input.communication,
        careful_handling=user_input.careful_handling,
        comment=user_comment,
    )
    db.add(user_rating)

    try:
        await db.flush()
        await db.refresh(user_rating)
        await _refresh_profile_rating(db, reviewee_id)
        await db.commit()
    except IntegrityError:
        await db.rollback()
        return "conflict", None

    await db.refresh(user_rating)
    return "ok", _user_rating_from_row(user_rating)


async def submit_item_rating(
    db: AsyncSession,
    request_id: int,
    user_id: int,
    item_input: SubmitItemRatingRequest,
) -> tuple[str, ApiItemRating | None]:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return "not_found", None
    rr, item, requester, _ = data
    if user_id != rr.requester_id:
        return "forbidden", None
    if rr.returned_at is None:
        return "invalid", None

    existing_item_rating = await _get_item_rating_by_reviewer(db, request_id, user_id)
    if existing_item_rating is not None:
        return "conflict", None

    item_rating = ItemRating(
        rent_request_id=request_id,
        item_id=item.id,
        reviewer_id=user_id,
        condition=item_input.condition,
        cleanliness=item_input.cleanliness,
        overall=(item_input.condition + item_input.cleanliness) / 2.0,
        comment=_normalize_comment(item_input.comment),
    )
    db.add(item_rating)

    try:
        await db.flush()
        await db.refresh(item_rating)
        await _refresh_item_score(db, item)
        await db.commit()
    except IntegrityError:
        await db.rollback()
        return "conflict", None

    await db.refresh(item_rating)
    return "ok", _item_rating_from_row(item_rating, requester)
