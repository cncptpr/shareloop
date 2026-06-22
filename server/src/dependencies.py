from datetime import UTC, datetime

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.auth.tokens import hash_token
from src.database import get_db
from src.db.models import Session as SessionModel
from src.db.models import User

bearer_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    token_hash = hash_token(credentials.credentials)
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.token_hash == token_hash,
            SessionModel.expires_at > datetime.now(UTC),
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    result = await db.execute(select(User).where(User.id == session.user_id))
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    return user


async def get_current_user_with_token(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> tuple[User, str]:
    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    token_hash = hash_token(credentials.credentials)
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.token_hash == token_hash,
            SessionModel.expires_at > datetime.now(UTC),
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    result = await db.execute(select(User).where(User.id == session.user_id))
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    return user, credentials.credentials


async def get_optional_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> User | None:
    if credentials is None:
        return None
    token_hash = hash_token(credentials.credentials)
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.token_hash == token_hash,
            SessionModel.expires_at > datetime.now(UTC),
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        return None
    result = await db.execute(select(User).where(User.id == session.user_id))
    return result.scalar_one_or_none()
