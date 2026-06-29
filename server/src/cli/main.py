import asyncio
from datetime import UTC

import typer
from sqlalchemy import select

from src.auth.password import hash_password
from src.auth.tokens import hash_token
from src.database import async_session_factory
from src.db.models import Session, User

app = typer.Typer()


def _run_async(coro):
    return asyncio.run(coro)


@app.command()
def create_user(email: str):
    password = typer.prompt("Password", hide_input=True)
    confirm = typer.prompt("Confirm password", hide_input=True)
    if password != confirm:
        typer.echo("Passwords do not match")
        raise typer.Exit(1)

    async def _run():
        async with async_session_factory() as db:
            result = await db.execute(select(User).where(User.email == email))
            if result.scalar_one_or_none():
                typer.echo("Email already exists")
                return
            pw_hash = hash_password(password)
            user = User(email=email, password_hash=pw_hash)
            db.add(user)
            await db.commit()
            typer.echo(f"User created: id={user.id}, email={user.email}")

    _run_async(_run())


@app.command()
def list_users():
    async def _run():
        async with async_session_factory() as db:
            result = await db.execute(select(User))
            users = result.scalars().all()
            for u in users:
                typer.echo(f"  {u.id}: {u.email} (created={u.created_at})")

    _run_async(_run())


@app.command()
def sessions():
    async def _run():
        async with async_session_factory() as db:
            result = await db.execute(
                select(Session).order_by(Session.user_id)
            )
            sessions = result.scalars().all()
            for s in sessions:
                typer.echo(
                    f"  session id={s.id}, user_id={s.user_id}, "
                    f"expires={s.expires_at}, refresh_expires={s.refresh_expires_at}"
                )

    _run_async(_run())


@app.command()
def login(email: str):
    password = typer.prompt("Password", hide_input=True)

    async def _run():
        async with async_session_factory() as db:
            result = await db.execute(select(User).where(User.email == email))
            user = result.scalar_one_or_none()
            if user is None:
                typer.echo("User not found")
                return
            from src.auth.password import verify_password
            if not verify_password(password, user.password_hash):
                typer.echo("Invalid password")
                return
            from datetime import datetime, timedelta

            from src.auth.tokens import generate_token_pair
            (access_token, access_hash), (refresh_token, refresh_hash) = generate_token_pair()
            now = datetime.now(UTC)
            session = Session(
                user_id=user.id,
                token_hash=access_hash,
                expires_at=now + timedelta(hours=1),
                refresh_token_hash=refresh_hash,
                refresh_expires_at=now + timedelta(days=30),
            )
            db.add(session)
            await db.commit()
            with open("tokens.txt", "w") as f:
                f.write(f"{access_token}\n{refresh_token}\n")
            typer.echo(f"Logged in as {user.email}, tokens saved to tokens.txt")

    _run_async(_run())


@app.command()
def validate():
    try:
        with open("tokens.txt") as f:
            access_token = f.readline().strip()
    except FileNotFoundError:
        typer.echo("No tokens.txt found, login first")
        return

    async def _run():
        async with async_session_factory() as db:
            token_hash = hash_token(access_token)
            from datetime import datetime
            result = await db.execute(
                select(Session).where(
                    Session.token_hash == token_hash,
                    Session.expires_at > datetime.now(UTC),
                )
            )
            session = result.scalar_one_or_none()
            if session is None:
                typer.echo("Token is invalid or expired")
                return
            result = await db.execute(select(User).where(User.id == session.user_id))
            user = result.scalar_one_or_none()
            if user is None:
                typer.echo("User not found")
                return
            typer.echo(f"Token valid for user: {user.email}")

    _run_async(_run())


@app.command()
def refresh():
    try:
        with open("tokens.txt") as f:
            f.readline()
            refresh_token = f.readline().strip()
    except (FileNotFoundError, IndexError):
        typer.echo("No tokens.txt found or missing refresh token")
        return

    from datetime import datetime, timedelta

    from src.auth.tokens import hash_token

    async def _run():
        async with async_session_factory() as db:
            r_hash = hash_token(refresh_token)
            result = await db.execute(
                select(Session).where(
                    Session.refresh_token_hash == r_hash,
                    Session.refresh_expires_at > datetime.now(UTC),
                )
            )
            session = result.scalar_one_or_none()
            if session is None:
                typer.echo("Refresh token invalid or expired")
                return
            from src.auth.tokens import generate_token_pair
            (new_access, new_access_hash), (new_refresh, new_refresh_hash) = generate_token_pair()
            now = datetime.now(UTC)
            session.token_hash = new_access_hash
            session.expires_at = now + timedelta(hours=1)
            session.refresh_token_hash = new_refresh_hash
            session.refresh_expires_at = now + timedelta(days=30)
            await db.commit()
            with open("tokens.txt", "w") as f:
                f.write(f"{new_access}\n{new_refresh}\n")
            typer.echo("Tokens refreshed and saved to tokens.txt")

    _run_async(_run())


@app.command()
def expire_access(email: str | None = None):
    async def _run():
        async with async_session_factory() as db:
            from datetime import datetime
            if email:
                result = await db.execute(select(User).where(User.email == email))
                user = result.scalar_one_or_none()
                if user is None:
                    typer.echo("User not found")
                    return
                result = await db.execute(select(Session).where(Session.user_id == user.id))
                for s in result.scalars().all():
                    s.expires_at = datetime.now(UTC)
            else:
                try:
                    with open("tokens.txt") as f:
                        access_token = f.readline().strip()
                except FileNotFoundError:
                    typer.echo("No tokens.txt found")
                    return
                t_hash = hash_token(access_token)
                result = await db.execute(select(Session).where(Session.token_hash == t_hash))
                s = result.scalar_one_or_none()
                if s:
                    s.expires_at = datetime.now(UTC)
            await db.commit()
            typer.echo("Access token(s) expired")

    _run_async(_run())


if __name__ == "__main__":
    app()
