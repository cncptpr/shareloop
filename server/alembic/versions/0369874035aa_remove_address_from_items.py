"""remove address from items

Revision ID: 0369874035aa
Revises: 2a1b6c8d9e0f
Create Date: 2026-07-05 12:00:00.000000
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '0369874035aa'
down_revision: Union[str, None] = '2a1b6c8d9e0f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.drop_column('items', 'address')


def downgrade() -> None:
    op.add_column('items', sa.Column('address', sa.String(), nullable=True))
