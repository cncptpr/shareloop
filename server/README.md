# Server

Backend for [shareloop](/README.md). See [Docker setup](/docs/Docker.md) to run the full stack without a local Python env.

## Requirements

- A running [Postgres + PostGIS](/docs/Docker.md) instance
- Python >= 3.12, [uv](https://docs.astral.sh/uv/) (both handled by mise)

## Setup

```bash
uv sync
uv sync --extra dev   # for linting / type checking
```

## Running

```bash
mise run server:dev
```

The API is documented in `../api/shareloop.openapi.yaml`. Regenerate the Pydantic models with `mise run server:api:gen`.

## Database

Schema is defined in `src/db/models.py` (SQLAlchemy ORM). Migrations run automatically at startup via Alembic.

| Action | Command |
|---|---|
| Apply pending migrations | `mise run server:db:migrate` |
| New migration from model changes | `mise run server:db:migration:new -- -m "description"` |
| Empty migration (manual SQL) | `mise run server:db:migration:create -- -m "description"` |
| Stamp DB at current revision | `mise run server:db:stamp` |

**Workflow:** edit `src/db/models.py` → `mise run server:db:migration:new -- -m "..."` → review → `mise run server:db:migrate` → commit.
