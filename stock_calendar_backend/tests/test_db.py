from sqlalchemy import Integer, String, select, text
from sqlalchemy.orm import Mapped, mapped_column

from app.db import get_db
from app.models import Base


def test_get_db_yields_usable_session(db_engine):
    gen = get_db()
    db = next(gen)
    try:
        assert db.execute(text("SELECT 1")).scalar() == 1
    finally:
        # exhausting the generator runs get_db()'s finally: db.close()
        gen.close()


def test_base_metadata_round_trip(db_engine):
    # A model declared on Base can be created, written, and read back —
    # proving Base is a working 2.0 declarative base whose metadata builds.
    class _Ping(Base):
        __tablename__ = "_ping"
        id: Mapped[int] = mapped_column(Integer, primary_key=True)
        label: Mapped[str] = mapped_column(String)

    Base.metadata.create_all(db_engine)
    try:
        gen = get_db()
        db = next(gen)
        try:
            db.add(_Ping(id=1, label="pong"))
            db.commit()
            got = db.execute(select(_Ping).where(_Ping.id == 1)).scalar_one()
            assert got.label == "pong"
        finally:
            gen.close()
    finally:
        # keep the shared Base.metadata clean for later task test modules
        Base.metadata.remove(_Ping.__table__)
