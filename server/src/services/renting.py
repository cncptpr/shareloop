from datetime import UTC, datetime

from sqlalchemy import case, literal_column, select
from sqlalchemy import func as sa_func
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.models import (
    Item,
    ItemRating,
    Message,
    Profile,
    RentOffer,
    RentRequest,
    UserRating,
)
from src.models.openapi import (
    ItemRating as ApiItemRating,
)
from src.models.openapi import (
    Message as ApiMessage,
)
from src.models.openapi import (
    Person,
    RentRequestDetail,
    RentRequestOverview,
    SubmitItemRatingRequest,
    SubmitUserRatingRequest,
)
from src.models.openapi import (
    RentOffer as ApiRentOffer,
)
from src.models.openapi import (
    UserRating as ApiUserRating,
)

EPOCH = datetime(1970, 1, 1, tzinfo=UTC)
DEFAULT_LAST_READ = "1970-01-01T00:00:00.000Z"


def _ts_to_str(dt: datetime | None) -> str:
    if dt is None:
        return DEFAULT_LAST_READ
    return dt.isoformat().replace("+00:00", "Z")


def _pick_last_read(
    auth_user_id: int,
    requester_id: int,
    requester_read_at: datetime | None,
    owner_read_at: datetime | None,
) -> str:
    if auth_user_id == requester_id:
        return _ts_to_str(requester_read_at)
    return _ts_to_str(owner_read_at)


async def _first_row(stmt, db: AsyncSession):
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


async def _get_request_detail_row(db: AsyncSession, request_id: int):
    stmt = select(RentRequest).where(RentRequest.id == request_id)
    result = await db.execute(stmt)
    rr = result.scalar_one_or_none()
    if rr is None:
        return None
    result = await db.execute(select(Item).where(Item.id == rr.item_id))
    item = result.scalar_one_or_none()
    if item is None:
        return None
    result = await db.execute(select(Profile).where(Profile.id == rr.requester_id))
    requester = result.scalar_one_or_none()
    if requester is None:
        return None
    result = await db.execute(select(Profile).where(Profile.id == item.author_id))
    owner = result.scalar_one_or_none()
    if owner is None:
        return None
    return rr, item, requester, owner


def _detail_from_row(rr, item, requester, owner, auth_user_id: int) -> RentRequestDetail:
    return RentRequestDetail(
        id=rr.id,
        item_id=rr.item_id,
        requester=Person(id=requester.id, name=requester.name),
        item_title=item.title,
        owner_name=owner.name,
        owner_id=item.author_id,
        latest_accepted_offer_id=rr.latest_accepted_offer_id,
        latest_open_offer_id=rr.latest_open_offer_id,
        borrow_confirmed_at=_ts_to_str(rr.borrow_confirmed_at) if rr.borrow_confirmed_at else None,
        returned_at=_ts_to_str(rr.returned_at) if rr.returned_at else None,
        created_at=_ts_to_str(rr.created_at),
        updated_at=_ts_to_str(rr.updated_at),
        messages=[],
        offers=[],
        last_read=_pick_last_read(
            auth_user_id, rr.requester_id, rr.requester_read_at, rr.owner_read_at
        ),
    )


def _overview_from_row(rr, item, requester, owner, unread_count: int) -> RentRequestOverview:
    return RentRequestOverview(
        id=rr.id,
        item_id=rr.item_id,
        requester=Person(id=requester.id, name=requester.name),
        item_title=item.title,
        owner_name=owner.name,
        owner_id=item.author_id,
        latest_accepted_offer_id=rr.latest_accepted_offer_id,
        latest_open_offer_id=rr.latest_open_offer_id,
        borrow_confirmed_at=_ts_to_str(rr.borrow_confirmed_at) if rr.borrow_confirmed_at else None,
        returned_at=_ts_to_str(rr.returned_at) if rr.returned_at else None,
        created_at=_ts_to_str(rr.created_at),
        updated_at=_ts_to_str(rr.updated_at),
        unread_count=unread_count,
    )


def _offer_from_row(offer: RentOffer) -> ApiRentOffer:
    return ApiRentOffer(
        id=offer.id,
        rent_request_id=offer.rent_request_id,
        sender_id=offer.sender_id,
        start_date=_ts_to_str(offer.start_date),
        end_date=_ts_to_str(offer.end_date),
        accepted_at=_ts_to_str(offer.accepted_at) if offer.accepted_at else None,
        created_at=_ts_to_str(offer.created_at),
        updated_at=_ts_to_str(offer.updated_at),
    )


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


async def create_rent_request(
    db: AsyncSession, user_id: int, item_id: int
) -> RentRequestDetail | None:
    rr = RentRequest(item_id=item_id, requester_id=user_id)
    db.add(rr)
    await db.commit()
    await db.refresh(rr)
    data = await _get_request_detail_row(db, rr.id)
    if data is None:
        return None
    return _detail_from_row(*data, user_id)


async def get_rent_requests(db: AsyncSession, user_id: int) -> list[RentRequestOverview]:
    stmt = (
        select(RentRequest)
        .where(
            (RentRequest.requester_id == user_id)
            | RentRequest.item_id.in_(select(Item.id).where(Item.author_id == user_id))
        )
        .order_by(RentRequest.updated_at.desc())
    )
    result = await db.execute(stmt)
    rrs = result.scalars().all()

    unread_map = await _build_unread_map(db, user_id)
    items_cache = {}
    profiles_cache = {}

    overviews = []
    for rr in rrs:
        if rr.item_id not in items_cache:
            result = await db.execute(select(Item).where(Item.id == rr.item_id))
            items_cache[rr.item_id] = result.scalar_one_or_none()
        item = items_cache[rr.item_id]
        if item is None:
            continue

        if rr.requester_id not in profiles_cache:
            result = await db.execute(select(Profile).where(Profile.id == rr.requester_id))
            profiles_cache[rr.requester_id] = result.scalar_one_or_none()
        requester = profiles_cache[rr.requester_id]

        if item.author_id not in profiles_cache:
            result = await db.execute(select(Profile).where(Profile.id == item.author_id))
            profiles_cache[item.author_id] = result.scalar_one_or_none()
        owner = profiles_cache[item.author_id]

        if requester is None or owner is None:
            continue

        overviews.append(_overview_from_row(rr, item, requester, owner, unread_map.get(rr.id, 0)))
    return overviews


async def get_rent_request_by_id(
    db: AsyncSession, request_id: int, user_id: int
) -> RentRequestDetail | None:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return None
    rr, item, requester, owner = data
    if rr.requester_id != user_id and item.author_id != user_id:
        return None
    detail = _detail_from_row(rr, item, requester, owner, user_id)

    msgs = await get_messages(db, request_id, user_id)
    if msgs is not None:
        detail.messages = msgs
    offers = await get_offers(db, request_id, user_id)
    if offers is not None:
        detail.offers = offers
    detail.my_user_rating = await _get_user_rating_by_reviewer(db, request_id, user_id)
    detail.my_item_rating = await _get_item_rating_by_reviewer(db, request_id, user_id)
    return detail


async def mark_rent_request_read(db: AsyncSession, request_id: int, user_id: int) -> bool:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return False
    rr, item, _, _ = data
    if rr.requester_id != user_id and item.author_id != user_id:
        return False

    now = datetime.now(UTC)
    if rr.requester_id == user_id:
        rr.requester_read_at = now
    else:
        rr.owner_read_at = now
    await db.commit()
    return True


async def send_message(
    db: AsyncSession, request_id: int, user_id: int, content: str
) -> ApiMessage | None:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return None
    rr, item, _, _ = data
    if rr.requester_id != user_id and item.author_id != user_id:
        return None

    msg = Message(rent_request_id=request_id, author_id=user_id, content=content)
    db.add(msg)
    await db.commit()
    await db.refresh(msg)
    return ApiMessage(
        id=msg.id,
        rent_request_id=msg.rent_request_id,
        author_id=msg.author_id,
        content=msg.content,
        created_at=_ts_to_str(msg.created_at),
    )


async def get_messages(db: AsyncSession, request_id: int, user_id: int) -> list[ApiMessage] | None:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return None
    rr, item, _, _ = data
    if rr.requester_id != user_id and item.author_id != user_id:
        return None

    stmt = select(Message).where(Message.rent_request_id == request_id).order_by(Message.created_at)
    result = await db.execute(stmt)
    msgs = result.scalars().all()
    return [
        ApiMessage(
            id=m.id,
            rent_request_id=m.rent_request_id,
            author_id=m.author_id,
            content=m.content,
            created_at=_ts_to_str(m.created_at),
        )
        for m in msgs
    ]


async def get_messages_after(
    db: AsyncSession, request_id: int, user_id: int, after: datetime
) -> list[ApiMessage] | None:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return None
    rr, item, _, _ = data
    if rr.requester_id != user_id and item.author_id != user_id:
        return None

    stmt = (
        select(Message)
        .where(Message.rent_request_id == request_id, Message.created_at > after)
        .order_by(Message.created_at)
    )
    result = await db.execute(stmt)
    msgs = result.scalars().all()
    return [
        ApiMessage(
            id=m.id,
            rent_request_id=m.rent_request_id,
            author_id=m.author_id,
            content=m.content,
            created_at=_ts_to_str(m.created_at),
        )
        for m in msgs
    ]


async def create_offer(
    db: AsyncSession, request_id: int, user_id: int, start_date: str, end_date: str
) -> ApiRentOffer | None:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return None
    rr, item, _, _ = data
    if rr.requester_id != user_id and item.author_id != user_id:
        return None

    try:
        start = datetime.fromisoformat(start_date.replace("Z", "+00:00"))
        end = datetime.fromisoformat(end_date.replace("Z", "+00:00"))
    except Exception:
        return None

    offer = RentOffer(
        rent_request_id=request_id,
        sender_id=user_id,
        start_date=start,
        end_date=end,
    )
    db.add(offer)
    await db.flush()
    await db.refresh(offer)

    rr.latest_open_offer_id = offer.id
    rr.updated_at = datetime.now(UTC)
    await db.commit()
    return _offer_from_row(offer)


async def get_offers(db: AsyncSession, request_id: int, user_id: int) -> list[ApiRentOffer] | None:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return None
    rr, item, _, _ = data
    if rr.requester_id != user_id and item.author_id != user_id:
        return None

    stmt = (
        select(RentOffer)
        .where(RentOffer.rent_request_id == request_id)
        .order_by(RentOffer.created_at)
    )
    result = await db.execute(stmt)
    offers = result.scalars().all()
    return [_offer_from_row(o) for o in offers]


async def get_offers_after(
    db: AsyncSession, request_id: int, user_id: int, after: datetime
) -> list[ApiRentOffer] | None:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return None
    rr, item, _, _ = data
    if rr.requester_id != user_id and item.author_id != user_id:
        return None

    stmt = (
        select(RentOffer)
        .where(
            RentOffer.rent_request_id == request_id,
            RentOffer.created_at > after,
        )
        .order_by(RentOffer.created_at)
    )
    result = await db.execute(stmt)
    offers = result.scalars().all()
    return [_offer_from_row(o) for o in offers]


async def accept_offer(db: AsyncSession, offer_id: int, user_id: int) -> ApiRentOffer | None:
    result = await db.execute(select(RentOffer).where(RentOffer.id == offer_id))
    offer = result.scalar_one_or_none()
    if offer is None:
        return None

    data = await _get_request_detail_row(db, offer.rent_request_id)
    if data is None:
        return None
    rr, item, _, _ = data

    if offer.sender_id == user_id:
        return None
    if user_id not in (rr.requester_id, item.author_id):
        return None
    if rr.latest_open_offer_id != offer.id:
        return None

    now = datetime.now(UTC)
    offer.accepted_at = now
    offer.updated_at = now
    rr.latest_accepted_offer_id = offer.id
    rr.latest_open_offer_id = None
    rr.updated_at = now
    await db.commit()
    return _offer_from_row(offer)


async def confirm_borrow(
    db: AsyncSession, request_id: int, user_id: int
) -> RentRequestDetail | None:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return None
    rr, item, requester, owner = data
    if item.author_id != user_id:
        return None
    if rr.latest_accepted_offer_id is None:
        return None
    if rr.borrow_confirmed_at is not None:
        return None
    if rr.returned_at is not None:
        return None

    rr.borrow_confirmed_at = datetime.now(UTC)
    rr.updated_at = datetime.now(UTC)
    await db.commit()
    return _detail_from_row(rr, item, requester, owner, user_id)


async def confirm_return(
    db: AsyncSession, request_id: int, user_id: int
) -> RentRequestDetail | None:
    data = await _get_request_detail_row(db, request_id)
    if data is None:
        return None
    rr, item, requester, owner = data
    if item.author_id != user_id:
        return None
    if rr.borrow_confirmed_at is None:
        return None
    if rr.returned_at is not None:
        return None

    rr.returned_at = datetime.now(UTC)
    rr.updated_at = datetime.now(UTC)
    await db.commit()
    return _detail_from_row(rr, item, requester, owner, user_id)


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


async def _build_unread_map(db: AsyncSession, user_id: int) -> dict[int, int]:
    sa_func.now()

    messages_subq = select(
        Message.rent_request_id,
        Message.created_at.label("event_at"),
    ).where(Message.author_id != user_id)

    offers_subq = select(
        RentOffer.rent_request_id,
        RentOffer.created_at.label("event_at"),
    ).where(RentOffer.sender_id != user_id)

    accepted_subq = (
        select(
            RentOffer.rent_request_id,
            RentOffer.accepted_at.label("event_at"),
        )
        .select_from(RentOffer)
        .join(RentRequest, RentRequest.id == RentOffer.rent_request_id)
        .where(
            RentOffer.accepted_at.isnot(None),
            RentRequest.requester_id == user_id,
        )
    )

    borrow_subq = select(
        RentRequest.id.label("rent_request_id"),
        RentRequest.borrow_confirmed_at.label("event_at"),
    ).where(
        RentRequest.borrow_confirmed_at.isnot(None),
        RentRequest.requester_id == user_id,
    )

    return_subq = select(
        RentRequest.id.label("rent_request_id"),
        RentRequest.returned_at.label("event_at"),
    ).where(
        RentRequest.returned_at.isnot(None),
        RentRequest.requester_id == user_id,
    )

    all_events = messages_subq.union_all(offers_subq, accepted_subq, borrow_subq, return_subq).cte(
        "u"
    )

    read_at_case = case(
        (user_id == RentRequest.requester_id, RentRequest.requester_read_at),
        else_=RentRequest.owner_read_at,
    )

    stmt = (
        select(
            RentRequest.id,
            sa_func.count(all_events.c.event_at).label("cnt"),
        )
        .outerjoin(
            all_events,
            (all_events.c.rent_request_id == RentRequest.id)
            & (
                all_events.c.event_at
                > sa_func.coalesce(read_at_case, literal_column("'1970-01-01'::timestamp"))
            ),
        )
        .where(
            (RentRequest.requester_id == user_id)
            | RentRequest.item_id.in_(select(Item.id).where(Item.author_id == user_id))
        )
        .group_by(RentRequest.id)
    )

    result = await db.execute(stmt)
    rows = result.all()
    return {row.id: row.cnt for row in rows}
