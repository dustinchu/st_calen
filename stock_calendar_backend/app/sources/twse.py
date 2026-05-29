"""TWSE (Taiwan Stock Exchange) adapter.

Source: TWSE OpenAPI STOCK_DAY_ALL — same-day OHLC + volume for every listed
security, plus the symbol/name master. Split into pure parse functions (TDD'd
against a real sample fixture) and a thin httpx fetch.

Notes on the real payload (verified 2026-05-29):
- `Date` is ROC/民國 format "1150528" (115+1911 = 2026) -> AD date.
- `Change` is the price *amount* (漲跌價差), e.g. "-2.0500"; we derive
  change_percent = Change / prev_close * 100 where prev_close = close - Change.
- Untraded securities carry empty-string price fields ("") and must be skipped
  for quotes; we still keep them in the stock master (they have Code + Name).
- This endpoint does not emit "--" or thousand-separator commas today, but we
  clean both defensively (other TWSE endpoints do).
"""

from datetime import date
from decimal import ROUND_HALF_UP, Decimal, InvalidOperation

import httpx

from app.sources.types import QuoteRow, StockRow

STOCK_DAY_ALL_URL = (
    "https://openapi.twse.com.tw/v1/exchangeReport/STOCK_DAY_ALL"
)

_PERCENT_QUANT = Decimal("0.0001")  # matches quotes.change_percent Numeric(8,4)


def _roc_to_date(raw: str) -> date:
    """Convert ROC date string 'YYYMMDD' (民國年) to a Gregorian date."""
    s = raw.strip()
    year = int(s[:-4]) + 1911
    month = int(s[-4:-2])
    day = int(s[-2:])
    return date(year, month, day)


def _to_decimal(raw: str) -> Decimal | None:
    """Parse a TWSE numeric string, returning None for no-data values.

    Strips thousand-separator commas; treats '', '--' (and parse failures) as
    no data.
    """
    s = raw.strip().replace(",", "")
    if not s or s == "--":
        return None
    try:
        return Decimal(s)
    except InvalidOperation:
        return None


def _to_int(raw: str) -> int | None:
    d = _to_decimal(raw)
    return int(d) if d is not None else None


def _change_percent(close: Decimal, change: Decimal) -> Decimal:
    """change_percent = change / prev_close * 100, prev_close = close - change.

    Guards against a non-positive prev close (would mean a bad/division-by-zero
    base); change_percent is NOT NULL, so we fall back to 0.
    """
    prev_close = close - change
    if prev_close <= 0:
        return Decimal("0")
    return (change / prev_close * 100).quantize(_PERCENT_QUANT, rounding=ROUND_HALF_UP)


def parse_twse_daily(raw: list[dict]) -> list[QuoteRow]:
    """Map STOCK_DAY_ALL rows to QuoteRow, skipping no-data rows."""
    rows: list[QuoteRow] = []
    for item in raw:
        open_ = _to_decimal(item["OpeningPrice"])
        high = _to_decimal(item["HighestPrice"])
        low = _to_decimal(item["LowestPrice"])
        close = _to_decimal(item["ClosingPrice"])
        volume = _to_int(item["TradeVolume"])
        if None in (open_, high, low, close, volume):
            continue  # untraded / dirty row -> no quote
        change = _to_decimal(item["Change"]) or Decimal("0")
        rows.append(
            QuoteRow(
                symbol=item["Code"].strip(),
                trade_date=_roc_to_date(item["Date"]),
                open=open_,
                high=high,
                low=low,
                close=close,
                change_percent=_change_percent(close, change),
                volume=volume,
                source="twse",
            )
        )
    return rows


def parse_twse_stocks(raw: list[dict]) -> list[StockRow]:
    """Extract the symbol/name master (market=tw) from the same payload.

    Includes every listed security with a code and name, even untraded ones.
    STOCK_DAY_ALL carries no sector, so sector stays None (filled later from
    t187ap03_L in the stock-master task).
    """
    rows: list[StockRow] = []
    for item in raw:
        symbol = item["Code"].strip()
        name = item["Name"].strip()
        if not symbol or not name:
            continue
        rows.append(StockRow(symbol=symbol, market="tw", name=name))
    return rows


def fetch_twse_daily(client: httpx.Client) -> list[QuoteRow]:
    resp = client.get(STOCK_DAY_ALL_URL)
    resp.raise_for_status()
    return parse_twse_daily(resp.json())
