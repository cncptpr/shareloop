# Server

This is the backend for [shareloop](/README.md).

If you are not actively developing this, [starting the server as
a Docker container](/docs/Docker.md) should be enough.

## Requirements

- Python >= 3.12
- a running [Postgres Database](/docs/Docker.md)

## Environment setup

Create and activate a virtual environment (choose one):

```bash
# Using pyenv + pyenv-virtualenv
pyenv install 3.12
pyenv virtualenv 3.12 shareloop
pyenv local shareloop   # run in server/

# Or using the built-in venv module
python3 -m venv .venv
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
pip install mypy ruff types-psycopg2   # dev dependencies
```

## Getting started

Run `$ mise run server:dev` or `$ uvicorn src.main:app --reload --host 0.0.0.0 --port 4000`
in `server` (current dir) to start the server. The server will be available under port 4000.

The server will host an api as described by the OpenAPI spec in `../api/`.
Regenerate the Pydantic models from the spec by running
`$ mise run server:api:gen`.

## Database

SQLAlchemy ORM models are defined in `src/db/models.py` — this is the single
source of truth for the DB schema. Migrations are managed with **Alembic**
(configured in `alembic.ini` + `alembic/env.py`).

Migrations run **automatically on every server startup** via `alembic upgrade head`
in `src/main.py:run_alembic_migrations()`.

### Migration Commands

| Action | Command |
|---|---|
| Apply all pending migrations | `mise run server:db:migrate` |
| Create a new migration from model changes | `mise run server:db:migration:new -- -m "description"` |
| Create an empty migration (manual SQL) | `mise run server:db:migration:create -- -m "description"` |
| Stamp current DB as at a given revision | `mise run server:db:stamp` |

### Workflow

1. Edit `src/db/models.py`
2. Run `mise run server:db:migration:new -- -m "what changed"`
3. Review the generated file in `alembic/versions/`
4. Run `mise run server:db:migrate` to apply it
5. Commit the migration file

