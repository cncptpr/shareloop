import os
import re
import shutil
import uuid as uuid_mod
from datetime import UTC, datetime, timedelta

from geoalchemy2 import Geography as GeoAlchemyGeography
from sqlalchemy import delete, select
from sqlalchemy import func as sa_func
from sqlalchemy.ext.asyncio import AsyncSession

from src.auth.password import hash_password
from src.config import settings
from src.db.models import (
    Item,
    ItemImage,
    ItemRating,
    Message,
    Profile,
    RentOffer,
    RentRequest,
    Session,
    User,
    UserRating,
)
from src.seeding.reader import load_and_validate

_REF_RE = re.compile(r"^ref\(([^)]+)\)$")
_RE_TS = re.compile(r"^([+-]?)(\d+)([dhm])(?: (\d{2}):(\d{2}))?$")


def _resolve(value: str, resolved: dict[str, int]) -> int:
    m = _REF_RE.match(value)
    if not m:
        raise ValueError(f"Ungültiger Ref: {value}")
    ref_id = m.group(1)
    return resolved[ref_id]


def _detect_ext_mime(filename: str):
    parts = filename.rsplit(".", 1)
    ext = parts[-1].lower() if len(parts) > 1 else ""
    mapping = {"jpg": "jpg", "jpeg": "jpg", "png": "png", "gif": "gif", "webp": "webp"}
    ext = mapping.get(ext, "jpg")
    mime = {"png": "image/png", "gif": "image/gif", "webp": "image/webp"}.get(ext, "image/jpeg")
    return ext, mime


def _parse_ts(s: str) -> datetime:
    if s == "now":
        return datetime.now(UTC)
    m = _RE_TS.match(s)
    if m:
        sign = -1 if m.group(1) == "-" else 1
        num = int(m.group(2))
        unit = m.group(3)
        now = datetime.now(UTC)
        if unit == "d":
            dt = now + sign * timedelta(days=num)
            if m.group(4) is not None:
                dt = dt.replace(hour=int(m.group(4)), minute=int(m.group(5)), second=0, microsecond=0)
            return dt
        diff = timedelta(hours=num if unit == "h" else 0, minutes=num if unit == "m" else 0)
        return now + sign * diff
    return datetime.fromisoformat(s.replace("Z", "+00:00"))


async def run_seed(db: AsyncSession) -> None:
    seed_data = load_and_validate(settings.seeding_dir)
    if seed_data is None:
        raise ValueError("Seed data ungültig oder nicht gefunden")

    resolved: dict[str, int] = {}

    await db.execute(delete(ItemRating))
    await db.execute(delete(UserRating))
    await db.execute(delete(Message))
    await db.execute(delete(RentOffer))
    await db.execute(delete(RentRequest))
    await db.execute(delete(ItemImage))
    await db.execute(delete(Item))
    await db.execute(delete(Session))
    await db.execute(delete(Profile))
    await db.execute(delete(User))

    uploads_dir = settings.uploads_dir
    if os.path.isdir(uploads_dir):
        for name in os.listdir(uploads_dir):
            path = os.path.join(uploads_dir, name)
            if os.path.isfile(path):
                os.remove(path)

    for u in seed_data["users"]:
        user = User(
            email=u["email"],
            password_hash=hash_password(u["password"]),
        )
        db.add(user)
        await db.flush()

        profile = Profile(
            id=user.id,
            name=u["name"],
            bio=u.get("bio"),
            rating=u.get("rating"),
        )
        db.add(profile)
        await db.flush()

        resolved[u["id"]] = user.id

    for item_data in seed_data["items"]:
        author_id = _resolve(item_data["author"], resolved)
        item = Item(
            title=item_data["title"],
            description=item_data["description"],
            author_id=author_id,
            score=item_data["score"],
            location=sa_func.st_setsrid(
                sa_func.st_makepoint(item_data["lng"], item_data["lat"]), 4326
            ).cast(GeoAlchemyGeography(srid=4326)),
            city=item_data["city"],
            postal_code=item_data.get("postalCode"),
            category=item_data.get("category", "Sonstiges"),
            price_per_day=item_data.get("pricePerDay"),
        )
        db.add(item)
        await db.flush()
        resolved[item_data["id"]] = item.id

        for img in item_data.get("images", []):
            src = os.path.join(settings.seeding_dir, img["path"])
            filename = os.path.basename(src)
            ext, mime = _detect_ext_mime(filename)
            image_uuid = uuid_mod.uuid4()
            dest_name = f"{image_uuid}.{ext}"
            dest_path = os.path.join(uploads_dir, dest_name)
            os.makedirs(uploads_dir, exist_ok=True)
            shutil.copy2(src, dest_path)

            image = ItemImage(
                id=image_uuid,
                item_id=item.id,
                original_name=filename,
                mime_type=mime,
                sort_order=img.get("sort_order", 0),
            )
            db.add(image)

    await db.flush()

    for req_data in seed_data.get("rent_requests", []):
        item_id = _resolve(req_data["item"], resolved)
        requester_id = _resolve(req_data["requester"], resolved)

        result = await db.execute(select(Item).where(Item.id == item_id))
        item_obj = result.scalar_one()
        owner_id = item_obj.author_id

        rr = RentRequest(
            item_id=item_id,
            requester_id=requester_id,
        )
        db.add(rr)
        await db.flush()
        resolved[req_data["id"]] = rr.id

        event_times: list[datetime] = []

        for msg in req_data.get("messages", []):
            author_id = _resolve(msg["author"], resolved)
            created_at = _parse_ts(msg.get("created_at", "now"))
            message = Message(
                rent_request_id=rr.id,
                author_id=author_id,
                content=msg["content"],
                created_at=created_at,
            )
            db.add(message)
            event_times.append(created_at)

        await db.flush()

        latest_open_offer_id: int | None = None
        latest_accepted_offer_id: int | None = None

        for offer_data in req_data.get("offers", []):
            sender_id = _resolve(offer_data["sender"], resolved)
            created_at = _parse_ts(offer_data.get("created_at", "now"))
            offer = RentOffer(
                rent_request_id=rr.id,
                sender_id=sender_id,
                start_date=_parse_ts(offer_data["start_date"]),
                end_date=_parse_ts(offer_data["end_date"]),
                created_at=created_at,
            )
            event_times.append(created_at)

            if offer_data.get("accepted", False):
                accepted_at = _parse_ts(offer_data.get("accepted_at", "now"))
                offer.accepted_at = accepted_at
                event_times.append(accepted_at)
                db.add(offer)
                await db.flush()
                latest_accepted_offer_id = offer.id
            else:
                db.add(offer)
                await db.flush()
                latest_open_offer_id = offer.id

        if latest_accepted_offer_id is not None:
            rr.latest_accepted_offer_id = latest_accepted_offer_id
        if latest_open_offer_id is not None:
            rr.latest_open_offer_id = latest_open_offer_id

        if req_data.get("borrow_confirmed", False):
            bt = _parse_ts(req_data.get("borrow_confirmed_at", "now"))
            rr.borrow_confirmed_at = bt
            event_times.append(bt)
        if req_data.get("returned", False):
            rt = _parse_ts(req_data.get("returned_at", "now"))
            rr.returned_at = rt
            event_times.append(rt)

        for ur_data in req_data.get("user_ratings", []):
            reviewer_id = _resolve(ur_data["reviewer"], resolved)
            communication = None
            careful_handling = None
            if reviewer_id == requester_id:
                communication = ur_data.get("communication")
            elif reviewer_id == owner_id:
                careful_handling = ur_data.get("carefulHandling")
            ur = UserRating(
                rent_request_id=rr.id,
                reviewer_id=reviewer_id,
                reviewee_id=requester_id if reviewer_id == owner_id else owner_id,
                friendliness=ur_data["friendliness"],
                punctuality=ur_data["punctuality"],
                reliability=ur_data["reliability"],
                communication=communication,
                careful_handling=careful_handling,
                comment=ur_data.get("comment"),
                created_at=_parse_ts(ur_data.get("created_at", "now")),
            )
            db.add(ur)

        for ir_data in req_data.get("item_ratings", []):
            reviewer_id = _resolve(ir_data["reviewer"], resolved)
            condition = ir_data["condition"]
            cleanliness = ir_data["cleanliness"]
            overall = round((condition + cleanliness) / 2.0, 1)
            ir = ItemRating(
                rent_request_id=rr.id,
                item_id=item_id,
                reviewer_id=reviewer_id,
                condition=condition,
                cleanliness=cleanliness,
                overall=overall,
                comment=ir_data.get("comment"),
                created_at=_parse_ts(ir_data.get("created_at", "now")),
            )
            db.add(ir)

        read_at = _parse_ts(req_data.get("read_at", "now"))
        event_times.append(read_at)
        for read_ref in req_data.get("mark_read", []):
            user_id = _resolve(read_ref, resolved)
            if user_id == requester_id:
                rr.requester_read_at = read_at
            elif user_id == owner_id:
                rr.owner_read_at = read_at

        rr.updated_at = max(event_times) if event_times else datetime.now(UTC)
        db.add(rr)

    await db.flush()

    for rat_data in seed_data.get("item_ratings", []):
        rating = ItemRating(
            rent_request_id=_resolve(rat_data["rent_request"], resolved),
            item_id=_resolve(rat_data["item"], resolved),
            reviewer_id=_resolve(rat_data["reviewer"], resolved),
            condition=rat_data["condition"],
            cleanliness=rat_data["cleanliness"],
            overall=rat_data["overall"],
            comment=rat_data.get("comment"),
            created_at=_parse_ts(rat_data.get("created_at", "now")),
        )
        db.add(rating)

    await db.flush()
