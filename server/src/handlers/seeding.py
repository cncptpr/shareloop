import logging
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.database import get_db
from src.db.models import SeedMeta
from src.seeding.engine import run_seed
from src.seeding.state import is_seeding_available

logger = logging.getLogger("shareloop.seeding")

router = APIRouter(tags=["seeding"])

SERVER_INFO = {
    "serverVersion": "v0.1.0",
    "apiVersion": "v0.1.0",
    "seeding": None,
}


@router.get("/api/info")
async def get_info(db: AsyncSession = Depends(get_db)):
    if not is_seeding_available():
        return dict(SERVER_INFO)

    result = await db.execute(select(SeedMeta).where(SeedMeta.id == 1))
    meta = result.scalar_one_or_none()
    if meta is None:
        meta = SeedMeta(id=1)
        db.add(meta)
        await db.commit()

    seeding = "enabled" if meta.seeded_at is not None else "prompt"
    return {"serverVersion": "v0.1.0", "apiVersion": "v0.1.0", "seeding": seeding}


@router.post("/api/seed")
async def seed_database(db: AsyncSession = Depends(get_db)):
    if not is_seeding_available():
        raise HTTPException(status_code=400, detail="Seeding is disabled")

    try:
        await run_seed(db)
        await _set_seeded_at(db)
        return {"message": "Seeding erfolgreich"}
    except Exception as e:
        await db.rollback()
        logger.exception("Seeding fehlgeschlagen")
        raise HTTPException(status_code=500, detail=f"Seeding fehlgeschlagen: {e}") from e


@router.post("/api/seed/decline")
async def decline_seed(db: AsyncSession = Depends(get_db)):
    if not is_seeding_available():
        raise HTTPException(status_code=400, detail="Seeding is disabled")

    await _set_seeded_at(db)
    return {"message": "Seeding abgelehnt"}


async def _set_seeded_at(db: AsyncSession) -> None:
    result = await db.execute(select(SeedMeta).where(SeedMeta.id == 1))
    meta = result.scalar_one_or_none()
    if meta is None:
        meta = SeedMeta(id=1)
    meta.seeded_at = datetime.now(UTC)
    db.add(meta)
    await db.commit()
