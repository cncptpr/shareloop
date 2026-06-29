from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.auth.password import verify_password
from src.auth.tokens import generate_token_pair, hash_token
from src.database import get_db
from src.db.models import Session, User
from src.dependencies import get_current_user, get_current_user_with_token
from src.models.openapi import LoginRequest, LoginResult, RefreshRequest

router = APIRouter(tags=["auth"])

ACCESS_TOKEN_LIFETIME = timedelta(hours=1)
REFRESH_TOKEN_LIFETIME = timedelta(days=30)


def _user_to_api(user: User) -> dict:
    return {
        "id": user.id,
        "email": user.email,
        "lastOnlineAt": user.last_online_at,
        "createdAt": user.created_at,
    }


@router.post("/api/auth/login")
async def login(body: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()
    if user is None or not verify_password(body.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    (access_token, access_hash), (refresh_token, refresh_hash) = generate_token_pair()
    now = datetime.now(UTC)
    access_expiry = now + ACCESS_TOKEN_LIFETIME
    refresh_expiry = now + REFRESH_TOKEN_LIFETIME

    session = Session(
        user_id=user.id,
        token_hash=access_hash,
        expires_at=access_expiry,
        refresh_token_hash=refresh_hash,
        refresh_expires_at=refresh_expiry,
    )
    db.add(session)
    user.last_online_at = now
    await db.commit()

    return LoginResult(
        user=_user_to_api(user),
        access_token=access_token,
        refresh_token=refresh_token,
        access_expires_at=access_expiry,
        refresh_expires_at=refresh_expiry,
    )


@router.post("/api/auth/refresh")
async def refresh(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    refresh_hash = hash_token(body.refresh_token)
    result = await db.execute(
        select(Session).where(
            Session.refresh_token_hash == refresh_hash,
            Session.refresh_expires_at > datetime.now(UTC),
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    result = await db.execute(select(User).where(User.id == session.user_id))
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    (new_access_token, new_access_hash), (new_refresh_token, new_refresh_hash) = (
        generate_token_pair()
    )
    now = datetime.now(UTC)
    access_expiry = now + ACCESS_TOKEN_LIFETIME
    refresh_expiry = now + REFRESH_TOKEN_LIFETIME

    session.token_hash = new_access_hash
    session.expires_at = access_expiry
    session.refresh_token_hash = new_refresh_hash
    session.refresh_expires_at = refresh_expiry
    await db.commit()

    return LoginResult(
        user=_user_to_api(user),
        access_token=new_access_token,
        refresh_token=new_refresh_token,
        access_expires_at=access_expiry,
        refresh_expires_at=refresh_expiry,
    )


@router.post("/api/auth/verify")
async def verify(user: User = Depends(get_current_user)):
    return _user_to_api(user)


@router.post("/api/auth/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    db: AsyncSession = Depends(get_db),
    auth: tuple[User, str] = Depends(get_current_user_with_token),
):
    user, token = auth
    token_hash = hash_token(token)
    result = await db.execute(
        select(Session).where(
            Session.token_hash == token_hash, Session.user_id == user.id
        )
    )
    session = result.scalar_one_or_none()
    if session:
        await db.delete(session)
        await db.commit()
