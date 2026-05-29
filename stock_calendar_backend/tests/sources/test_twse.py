import json
from datetime import date
from decimal import Decimal
from pathlib import Path

import httpx
import respx

from app.sources.twse import (
    STOCK_DAY_ALL_URL,
    fetch_twse_daily,
    parse_twse_daily,
    parse_twse_stocks,
)

FIXTURES = Path(__file__).parent / "fixtures"


def _load(name: str) -> list:
    return json.loads((FIXTURES / name).read_text(encoding="utf-8"))


def test_parse_twse_daily_maps_fields():
    rows = parse_twse_daily(_load("twse_stock_day_all.json"))
    by_symbol = {r.symbol: r for r in rows}

    tsmc = by_symbol["2330"]
    assert tsmc.symbol == "2330"  # raw code, no .TW suffix
    assert tsmc.trade_date == date(2026, 5, 28)  # ROC 1150528 -> AD
    assert tsmc.open == Decimal("2350.00")
    assert tsmc.high == Decimal("2360.00")
    assert tsmc.low == Decimal("2270.00")
    assert tsmc.close == Decimal("2295.00")
    assert tsmc.volume == 42313277
    assert isinstance(tsmc.volume, int)
    assert tsmc.source == "twse"


def test_parse_skips_rows_with_no_data():
    # 00625K has empty-string price fields (a real listed-but-untraded security);
    # it cannot become a quote and must be skipped.
    rows = parse_twse_daily(_load("twse_stock_day_all.json"))
    symbols = {r.symbol for r in rows}
    assert "00625K" not in symbols
    assert symbols == {"0050", "2330", "00632R"}


def test_change_percent_computed():
    rows = {r.symbol: r for r in parse_twse_daily(_load("twse_stock_day_all.json"))}
    # 0050: Change=-2.05, close=100.50 -> prev=102.55 -> -2.05/102.55*100
    assert rows["0050"].change_percent == Decimal("-1.9990")
    # 00632R: Change=+0.23, close=10.73 -> prev=10.50 -> 0.23/10.50*100
    assert rows["00632R"].change_percent == Decimal("2.1905")


def test_parse_twse_stocks_extracts_symbol_name():
    stocks = {s.symbol: s for s in parse_twse_stocks(_load("twse_stock_day_all.json"))}
    # master list includes every listed security, even untraded ones (00625K)
    assert set(stocks) == {"0050", "2330", "00632R", "00625K"}
    tsmc = stocks["2330"]
    assert tsmc.market == "tw"
    assert tsmc.name == "台積電"
    assert tsmc.sector is None  # STOCK_DAY_ALL carries no sector


def test_parse_cleans_dirty_values():
    # Synthetic fixture: thousand-separator commas must be stripped; rows whose
    # price fields are "--" are treated as no-data and skipped.
    rows = parse_twse_daily(_load("twse_stock_day_all_dirty.json"))
    assert {r.symbol for r in rows} == {"9999"}  # 8888 ("--") skipped
    dirty = rows[0]
    assert dirty.volume == 1234567  # "1,234,567" -> int
    assert dirty.open == Decimal("1050.00")  # "1,050.00" -> Decimal
    assert dirty.close == Decimal("1055.00")
    # Change=5.00, close=1055 -> prev=1050 -> 5/1050*100
    assert dirty.change_percent == Decimal("0.4762")


@respx.mock
def test_fetch_twse_daily_gets_and_parses():
    payload = _load("twse_stock_day_all.json")
    respx.get(STOCK_DAY_ALL_URL).mock(return_value=httpx.Response(200, json=payload))

    with httpx.Client() as client:
        rows = fetch_twse_daily(client)

    assert {r.symbol for r in rows} == {"0050", "2330", "00632R"}
    assert all(r.source == "twse" for r in rows)
