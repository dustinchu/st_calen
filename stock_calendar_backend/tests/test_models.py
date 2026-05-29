from datetime import date
from decimal import Decimal

from sqlalchemy import select

from app.db import get_db
from app.models import Quote, Stock, WatchedSymbol


def test_stock_round_trip(db_engine):
    gen = get_db()
    db = next(gen)
    try:
        db.add(Stock(symbol="2330.TW", market="tw", name="台積電"))
        db.commit()
        got = db.execute(
            select(Stock).where(Stock.symbol == "2330.TW")
        ).scalar_one()
        assert got.market == "tw"
        assert got.name == "台積電"
        assert got.sector is None  # nullable, not supplied
        assert got.updated_at is not None  # server_default=now()
    finally:
        gen.close()


def test_quote_round_trip(db_engine):
    gen = get_db()
    db = next(gen)
    try:
        # FK quotes.symbol -> stocks.symbol: parent must exist (enforced on PG).
        db.add(Stock(symbol="2330.TW", market="tw", name="台積電"))
        db.add(
            Quote(
                symbol="2330.TW",
                trade_date=date(2024, 1, 2),
                open=Decimal("100.5"),
                high=Decimal("101.25"),
                low=Decimal("99.75"),
                close=Decimal("100.0"),
                change_percent=Decimal("0.5"),
                volume=1234567,
                source="twse",
            )
        )
        db.commit()
        got = db.execute(
            select(Quote).where(
                Quote.symbol == "2330.TW", Quote.trade_date == date(2024, 1, 2)
            )
        ).scalar_one()
        assert got.trade_date == date(2024, 1, 2)
        assert isinstance(got.close, Decimal)
        assert got.open == Decimal("100.5")
        assert got.high == Decimal("101.25")
        assert got.low == Decimal("99.75")
        assert got.close == Decimal("100.0")
        assert got.change_percent == Decimal("0.5")
        assert isinstance(got.volume, int)
        assert got.volume == 1234567
        assert got.source == "twse"
        assert got.inserted_at is not None  # server_default=now()
    finally:
        gen.close()


def test_watched_symbol_round_trip(db_engine):
    gen = get_db()
    db = next(gen)
    try:
        db.add(WatchedSymbol(symbol="AAPL"))
        db.commit()
        got = db.execute(
            select(WatchedSymbol).where(WatchedSymbol.symbol == "AAPL")
        ).scalar_one()
        assert got.symbol == "AAPL"
        assert got.last_requested_at is not None  # server_default=now()
    finally:
        gen.close()
