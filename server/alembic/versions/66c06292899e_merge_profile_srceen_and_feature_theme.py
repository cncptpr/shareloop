"""merge Profile-srceen and feature/theme

Revision ID: 66c06292899e
Revises: 31355a65fd69, 933850ea0c37
Create Date: 2026-07-05 14:29:34.551820
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '66c06292899e'
down_revision: Union[str, None] = ('31355a65fd69', '933850ea0c37')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
