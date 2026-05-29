# stock_calendar_backend

Backend for `stock.wisplu.com.tw` — stock search, closing-price quotes, range
queries, and a health check. Powers the Stock Calendar Flutter app (Step 11).

Lives as a subfolder of the Flutter monorepo. All paths in the Step 10 plan are
relative to this folder. The Python toolchain here is independent of the Flutter
app — do not use `fvm flutter` to run/verify the backend.

## Stack

FastAPI · Uvicorn + Gunicorn · SQLAlchemy 2.0 + psycopg3 · Alembic · httpx ·
APScheduler (cron) · pytest + respx. Target runtime: Python 3.12 (container).

## Setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
```

## Run (dev)

```bash
uvicorn app.main:app --reload
# health check
curl http://127.0.0.1:8000/api/v1/health
```

## Test

```bash
pytest -v
```

## Configuration

Environment variables (see `app/config.py`), loaded from `.env` if present:

| Var            | Purpose                          | Default                    |
| -------------- | -------------------------------- | -------------------------- |
| `POSTGRES_URL` | Postgres connection string       | _(empty)_                  |
| `SERVICE_NAME` | Service identifier               | `stock-calendar-backend`   |
| `ENV`          | Environment name                 | `development`              |
