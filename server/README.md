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
source of truth for the DB schema. Migrations are managed with Alembic.

To create a new migration after changing models:

```
$ alembic revision --autogenerate -m "description"
$ alembic upgrade head
```

To populate the Database with example data run `$ mise run server:db:seed`.
