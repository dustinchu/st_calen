from collections.abc import Iterator

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.config import settings

# Engine is built lazily on first use so importing this module never connects
# and never fails when POSTGRES_URL is unset (e.g. during unit tests). Fill in
# the real connection via the POSTGRES_URL env / .env (the deploy interface).
_engine: Engine | None = None

SessionLocal = sessionmaker(
    autoflush=False,
    autocommit=False,
    expire_on_commit=False,
    class_=Session,
)


def get_engine() -> Engine:
    global _engine
    if _engine is None:
        _engine = create_engine(settings.postgres_url, pool_pre_ping=True, future=True)
        SessionLocal.configure(bind=_engine)
    return _engine


def get_db() -> Iterator[Session]:
    """FastAPI dependency: yield a Session, always closing it afterwards."""
    get_engine()  # ensure SessionLocal is bound
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
