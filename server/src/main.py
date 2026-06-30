import asyncio
import json
import logging
import os
from datetime import UTC

from alembic.config import Config
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from sqlalchemy import select, text
from starlette.middleware.cors import CORSMiddleware

from alembic import command
from src.config import settings
from src.database import async_session_factory
from src.db.models import SeedMeta, User
from src.handlers import auth, images, items, ratings, renting
from src.handlers.seeding import router as seeding_router
from src.notifications.registry import registry
from src.seeding.reader import load_and_validate
from src.seeding.state import set_seeding_available

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("shareloop")

def _check_uploads_writable():
    probe = os.path.join(settings.uploads_dir, ".write_probe")
    try:
        with open(probe, "w") as f:
            f.write("probe")
        os.remove(probe)
    except OSError:
        logger.error(
            "Uploads dir '%s' is not writable – file uploads and seeding will fail",
            settings.uploads_dir,
        )


app = FastAPI(title="Shareloop API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(items.router)
app.include_router(ratings.router)
app.include_router(renting.router)
app.include_router(images.router)
app.include_router(seeding_router)


@app.on_event("startup")
async def startup():
    os.makedirs(settings.uploads_dir, exist_ok=True)
    _check_uploads_writable()
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    await run_alembic_migrations()
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


async def run_alembic_migrations():
    alembic_cfg = Config("alembic.ini")
    database_url = settings.database_url.replace("postgres://", "postgresql+asyncpg://")
    alembic_cfg.set_main_option("sqlalchemy.url", database_url)
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(None, command.upgrade, alembic_cfg, "head")


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
