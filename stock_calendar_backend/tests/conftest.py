import os

import pytest
from sqlalchemy import create_engine
from sqlalchemy.pool import StaticPool

from app import db as db_module
from app.models import Base


def _make_test_engine():
    """Build the engine tests run against.

    Set TEST_DATABASE_URL (e.g. postgresql+psycopg://admin:pw@host:5432/stock)
    to run the suite against a real Postgres — required for true ON CONFLICT /
    timestamptz coverage in later tasks. With it unset we fall back to an
    in-memory SQLite shared across sessions (StaticPool keeps one connection,
    so a schema created on it survives), which keeps the suite runnable offline.
    """
    url = os.getenv("TEST_DATABASE_URL")
    if url:
        return create_engine(url, pool_pre_ping=True, future=True)
    return create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        future=True,
    )


@pytest.fixture
def db_engine():
    """A ready-to-use engine with the schema built, wired into app.db.

    Points app.db's lazy engine + SessionLocal at the test engine so get_db()
    yields sessions bound to it.
    """
    engine = _make_test_engine()
    Base.metadata.create_all(engine)

    db_module._engine = engine
    db_module.SessionLocal.configure(bind=engine)

    yield engine

    Base.metadata.drop_all(engine)
    engine.dispose()
    db_module._engine = None
