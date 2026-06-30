from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.database import get_db
from src.db.models import User
from src.dependencies import get_current_user
from src.models.openapi import (
    SubmitItemRatingRequest,
    SubmitUserRatingRequest,
)
from src.services import ratings as ratings_service

router = APIRouter(tags=["ratings"])


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
    result, rating = await ratings_service.submit_user_rating(db, request_id, user.id, body)
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
    result, rating = await ratings_service.submit_item_rating(db, request_id, user.id, body)
    if result == "ok" and rating is not None:
        return rating
    if result == "not_found":
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    if result == "forbidden":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)
    if result == "conflict":
        raise HTTPException(status_code=status.HTTP_409_CONFLICT)
    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST)
