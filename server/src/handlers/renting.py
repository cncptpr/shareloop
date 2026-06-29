import json

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.database import get_db
from src.db.models import User
from src.dependencies import get_current_user
from src.models.openapi import (
    CreateOfferRequest,
    SendMessageRequest,
    SubmitItemRatingRequest,
    SubmitUserRatingRequest,
)
from src.notifications.registry import registry
from src.services import renting as renting_service

router = APIRouter(tags=["renting"])


async def _notify_other(
    db: AsyncSession,
    request_id: int,
    current_user_id: int,
    event_type: str,
    data: dict,
):
    detail = await renting_service.get_rent_request_by_id(db, request_id, current_user_id)
    if detail is None:
        return
    other_id = detail.requester.id if current_user_id != detail.requester.id else detail.owner_id
    payload = json.dumps(
        {
            "type": event_type,
            "rent_request_id": request_id,
            "data": data,
        }
    )
    await registry.notify(other_id, payload)


@router.post("/api/items/{item_id}/rent-requests", status_code=status.HTTP_201_CREATED)
async def api_create_rent_request(
    item_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await renting_service.create_rent_request(db, user.id, item_id)
    if result is None:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR)
    return result


@router.get("/api/rent-requests")
async def api_get_rent_requests(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await renting_service.get_rent_requests(db, user.id)
    return result


@router.get("/api/rent-requests/{request_id}")
async def api_get_rent_request(
    request_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await renting_service.get_rent_request_by_id(db, request_id, user.id)
    if result is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    return result


@router.post("/api/rent-requests/{request_id}/mark-read", status_code=status.HTTP_204_NO_CONTENT)
async def api_mark_rent_request_read(
    request_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    ok = await renting_service.mark_rent_request_read(db, request_id, user.id)
    if not ok:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)


@router.post("/api/rent-requests/{request_id}/messages", status_code=status.HTTP_201_CREATED)
async def api_send_message(
    request_id: int,
    body: SendMessageRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    msg = await renting_service.send_message(db, request_id, user.id, body.content)
    if msg is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    await _notify_other(
        db,
        request_id,
        user.id,
        "message.created",
        msg.model_dump(mode="json", by_alias=True),
    )
    return msg


@router.post("/api/rent-requests/{request_id}/offers", status_code=status.HTTP_201_CREATED)
async def api_create_offer(
    request_id: int,
    body: CreateOfferRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    offer = await renting_service.create_offer(
        db,
        request_id,
        user.id,
        body.start_date.isoformat()
        if hasattr(body.start_date, "isoformat")
        else str(body.start_date),
        body.end_date.isoformat() if hasattr(body.end_date, "isoformat") else str(body.end_date),
    )
    if offer is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    await _notify_other(
        db,
        request_id,
        user.id,
        "offer.created",
        offer.model_dump(mode="json", by_alias=True),
    )
    return offer


@router.post("/api/offers/{offer_id}/accept")
async def api_accept_offer(
    offer_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    offer = await renting_service.accept_offer(db, offer_id, user.id)
    if offer is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    await _notify_other(
        db,
        offer.rent_request_id,
        user.id,
        "offer.accepted",
        offer.model_dump(mode="json", by_alias=True),
    )
    return offer


@router.post("/api/rent-requests/{request_id}/confirm-borrow")
async def api_confirm_borrow(
    request_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    detail = await renting_service.confirm_borrow(db, request_id, user.id)
    if detail is None:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)
    await _notify_other(
        db,
        request_id,
        user.id,
        "borrow.confirmed",
        detail.model_dump(mode="json", by_alias=True),
    )
    return detail


@router.post("/api/rent-requests/{request_id}/confirm-return")
async def api_confirm_return(
    request_id: int,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    detail = await renting_service.confirm_return(db, request_id, user.id)
    if detail is None:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)
    await _notify_other(
        db,
        request_id,
        user.id,
        "return.confirmed",
        detail.model_dump(mode="json", by_alias=True),
    )
    return detail


@router.post(
    "/api/rent-requests/{request_id}/user-rating",
    status_code=status.HTTP_201_CREATED,
)
async def api_submit_user_rating(
    request_id: int,
    body: SubmitUserRatingRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result, rating = await renting_service.submit_user_rating(db, request_id, user.id, body)
    if result == "ok" and rating is not None:
        return rating
    if result == "not_found":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    if result == "forbidden":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)
    if result == "conflict":
        raise HTTPException(status_code=status.HTTP_409_CONFLICT)
    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST)


@router.post(
    "/api/rent-requests/{request_id}/item-rating",
    status_code=status.HTTP_201_CREATED,
)
async def api_submit_item_rating(
    request_id: int,
    body: SubmitItemRatingRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result, rating = await renting_service.submit_item_rating(db, request_id, user.id, body)
    if result == "ok" and rating is not None:
        return rating
    if result == "not_found":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    if result == "forbidden":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)
    if result == "conflict":
        raise HTTPException(status_code=status.HTTP_409_CONFLICT)
    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST)
