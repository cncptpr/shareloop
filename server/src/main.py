import asyncio
import json
import logging
import os
from datetime import UTC

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from sqlalchemy import select, text

from src.config import settings
from src.database import async_session_factory, engine
from src.db.models import Base, SeedMeta, User
from src.handlers import auth, images, items, renting
from src.handlers.seeding import router as seeding_router
from src.notifications.registry import registry
from src.seeding.reader import load_and_validate
from src.seeding.state import set_seeding_available

logger = logging.getLogger("shareloop")

app = FastAPI(title="Shareloop API", version="1.0.0")

app.include_router(auth.router)
app.include_router(items.router)
app.include_router(renting.router)
app.include_router(images.router)
app.include_router(seeding_router)


@app.on_event("startup")
async def startup():
    os.makedirs(settings.uploads_dir, exist_ok=True)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        await apply_compat_migrations(conn)
    await apply_migrations()
    await init_seeding()


async def init_seeding():
    seed_data = load_and_validate(settings.seeding_dir)
    if seed_data is None:
        set_seeding_available(False)
        logger.warning("Seeding data.yaml nicht gefunden oder ungültig – Seeding deaktiviert")
        return

    set_seeding_available(True)
    logger.info("Seeding data.yaml gefunden und gültig – Seeding aktiviert")

    async with async_session_factory() as db:
        result = await db.execute(select(SeedMeta).where(SeedMeta.id == 1))
        if result.scalar_one_or_none() is None:
            db.add(SeedMeta(id=1))
            await db.commit()
            logger.info("SeedMeta Zeile angelegt")


async def apply_compat_migrations(conn):
    await conn.execute(
        text(
            """
            DO $$
            BEGIN
                IF EXISTS (
                    SELECT 1 FROM information_schema.columns
                    WHERE table_name = 'item_ratings'
                      AND column_name = 'description_accuracy'
                ) THEN
                    ALTER TABLE item_ratings
                        ADD COLUMN IF NOT EXISTS cleanliness INTEGER;
                    UPDATE item_ratings
                    SET cleanliness = ROUND(
                        (description_accuracy + functionality) / 2.0
                    )::INTEGER
                    WHERE cleanliness IS NULL;
                    ALTER TABLE item_ratings
                        ALTER COLUMN cleanliness SET NOT NULL;
                    ALTER TABLE item_ratings
                        DROP COLUMN description_accuracy,
                        DROP COLUMN functionality;
                    ALTER TABLE item_ratings
                        ADD CONSTRAINT ck_item_rating_cleanliness
                        CHECK (cleanliness BETWEEN 1 AND 5);
                END IF;
            END $$
            """
        )
    )
    await conn.execute(
        text(
            "ALTER TABLE item_ratings ALTER COLUMN overall TYPE DOUBLE PRECISION "
            "USING overall::double precision"
        )
    )


async def apply_migrations():
    import glob
    migration_dir = os.path.join(os.path.dirname(__file__), "..", "..", "db", "priv", "migrations")
    if not os.path.isdir(migration_dir):
        return
    files = sorted(glob.glob(os.path.join(migration_dir, "*.sql")))
    if not files:
        return
    async with engine.begin() as conn:
        result = await conn.execute(
            text("SELECT table_name FROM information_schema.tables WHERE table_name = 'alembic_version'")
        )
        if result.scalar_one_or_none():
            return
        for f in files:
            with open(f) as fh:
                sql = fh.read()
            for stmt in sql.split("--- migration:up")[1].split("--- migration:down")[0].split(";"):
                stmt = stmt.strip()
                if stmt:
                    try:
                        await conn.execute(text(stmt))
                    except Exception:
                        pass


@app.websocket("/ws")
async def websocket_endpoint(ws: WebSocket):
    await ws.accept()
    auth_user: User | None = None
    auth_subject: int | None = None

    try:
        raw = await asyncio.wait_for(ws.receive_text(), timeout=5.0)
    except TimeoutError:
        await ws.send_text(json.dumps({"type": "auth", "status": "timeout"}))
        await ws.close()
        return
    except WebSocketDisconnect:
        return

    try:
        msg = json.loads(raw)
        if msg.get("type") != "auth" or "token" not in msg:
            raise ValueError("invalid")
        token = msg["token"]
    except (json.JSONDecodeError, ValueError):
        await ws.send_text(json.dumps({"type": "auth", "status": "error"}))
        await ws.close()
        return

    from src.auth.tokens import hash_token
    token_hash = hash_token(token)
    from datetime import datetime

    from src.db.models import Session as SessionModel

    async with async_session_factory() as db:
        result = await db.execute(
            select(SessionModel).where(
                SessionModel.token_hash == token_hash,
                SessionModel.expires_at > datetime.now(UTC),
            )
        )
        session = result.scalar_one_or_none()
        if session is None:
            await ws.send_text(json.dumps({"type": "auth", "status": "error"}))
            await ws.close()
            return
        result = await db.execute(select(User).where(User.id == session.user_id))
        auth_user = result.scalar_one_or_none()  # type: ignore[assignment]
        if auth_user is None:
            await ws.send_text(json.dumps({"type": "auth", "status": "error"}))
            await ws.close()
            return

    auth_subject = auth_user.id
    await registry.register(auth_subject, ws)
    await ws.send_text(json.dumps({"type": "auth", "status": "ok"}))

    try:
        while True:
            await ws.receive_text()
    except WebSocketDisconnect:
        pass
    finally:
        if auth_subject is not None:
            await registry.unregister(auth_subject, ws)
