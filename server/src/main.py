import asyncio
import json
import os
from datetime import UTC

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from sqlalchemy import select, text

from src.config import settings
from src.database import async_session_factory, engine
from src.db.models import Base, User
from src.handlers import auth, images, items, renting
from src.notifications.registry import registry

app = FastAPI(title="Shareloop API", version="1.0.0")

app.include_router(auth.router)
app.include_router(items.router)
app.include_router(renting.router)
app.include_router(images.router)


@app.on_event("startup")
async def startup():
    os.makedirs(settings.uploads_dir, exist_ok=True)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    await apply_migrations()


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
