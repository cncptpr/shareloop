"""add address to items

Revision ID: 2a1b6c8d9e0f
Revises: 3bb5555fb8a7
Create Date: 2026-07-04 19:00:00.000000
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = '2a1b6c8d9e0f'
down_revision: Union[str, None] = '3bb5555fb8a7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('items', sa.Column('address', sa.String(), nullable=True))


def downgrade() -> None:
    op.drop_column('items', 'address')
