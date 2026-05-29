"""Internal row types shared by external-source adapters.

DB-agnostic, frozen dataclasses. Prices and percentages are Decimal to stay
faithful to the Numeric columns they feed (quotes.open/high/low/close are
Numeric(18,4), change_percent is Numeric(8,4)); float would lose precision.
"""

from dataclasses import dataclass
from datetime import date
from decimal import Decimal


@dataclass(frozen=True)
class QuoteRow:
    symbol: str
    trade_date: date
    open: Decimal
    high: Decimal
    low: Decimal
    close: Decimal
    change_percent: Decimal
    volume: int
    source: str


@dataclass(frozen=True)
class StockRow:
    symbol: str
    market: str
    name: str
    sector: str | None = None
