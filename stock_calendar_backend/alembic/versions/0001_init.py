"""init: stocks / quotes / watched_symbols

Revision ID: 0001
Revises:
Create Date: 2026-05-29
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = "0001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "stocks",
        sa.Column("symbol", sa.String(), nullable=False),
        sa.Column("market", sa.String(), nullable=False),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("sector", sa.String(), nullable=True),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("symbol"),
    )
    op.create_table(
        "quotes",
        sa.Column("symbol", sa.String(), nullable=False),
        sa.Column("trade_date", sa.Date(), nullable=False),
        sa.Column("open", sa.Numeric(precision=18, scale=4), nullable=False),
        sa.Column("high", sa.Numeric(precision=18, scale=4), nullable=False),
        sa.Column("low", sa.Numeric(precision=18, scale=4), nullable=False),
        sa.Column("close", sa.Numeric(precision=18, scale=4), nullable=False),
        sa.Column("change_percent", sa.Numeric(precision=8, scale=4), nullable=False),
        sa.Column("volume", sa.BigInteger(), nullable=False),
        sa.Column("source", sa.String(), nullable=False),
        sa.Column(
            "inserted_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["symbol"], ["stocks.symbol"]),
        sa.PrimaryKeyConstraint("symbol", "trade_date"),
    )
    op.create_index("ix_quotes_trade_date", "quotes", ["trade_date"], unique=False)
    op.create_table(
        "watched_symbols",
        sa.Column("symbol", sa.String(), nullable=False),
        sa.Column(
            "last_requested_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("symbol"),
    )


def downgrade() -> None:
    op.drop_table("watched_symbols")
    op.drop_index("ix_quotes_trade_date", table_name="quotes")
    op.drop_table("quotes")
    op.drop_table("stocks")
