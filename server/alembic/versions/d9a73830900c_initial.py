"""initial

Revision ID: d9a73830900c
Revises: 
Create Date: 2026-06-29 16:02:03.465476
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import geoalchemy2


revision: str = 'd9a73830900c'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table('users',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('email', sa.String(), nullable=False),
    sa.Column('password_hash', sa.String(), nullable=False),
    sa.Column('last_online_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('email')
    )
    op.create_table('seed_meta',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('seeded_at', sa.DateTime(timezone=True), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('profiles',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('name', sa.String(), nullable=False),
    sa.Column('bio', sa.Text(), nullable=True),
    sa.Column('rating', sa.Numeric(precision=3, scale=2), nullable=True),
    sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
    sa.ForeignKeyConstraint(['id'], ['users.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('sessions',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('user_id', sa.Integer(), nullable=False),
    sa.Column('token_hash', sa.String(), nullable=False),
    sa.Column('expires_at', sa.DateTime(timezone=True), nullable=False),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.Column('refresh_token_hash', sa.String(), nullable=False),
    sa.Column('refresh_expires_at', sa.DateTime(timezone=True), nullable=False),
    sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('token_hash')
    )
    op.create_table('items',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('title', sa.String(), nullable=False),
    sa.Column('description', sa.String(), nullable=False),
    sa.Column('author_id', sa.Integer(), nullable=False),
    sa.Column('score', sa.Float(), nullable=False),
    sa.Column('location', geoalchemy2.types.Geography(geometry_type='POINT', srid=4326, dimension=2, from_text='ST_GeogFromText', name='geography'), nullable=True),
    sa.Column('city', sa.String(), nullable=True),
    sa.Column('postal_code', sa.String(), nullable=True),
    sa.Column('category', sa.String(), server_default='Sonstiges', nullable=False),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.ForeignKeyConstraint(['author_id'], ['users.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('item_images',
    sa.Column('id', sa.UUID(), nullable=False),
    sa.Column('item_id', sa.Integer(), nullable=False),
    sa.Column('original_name', sa.String(), nullable=False),
    sa.Column('mime_type', sa.String(), nullable=False),
    sa.Column('sort_order', sa.Integer(), nullable=False),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.ForeignKeyConstraint(['item_id'], ['items.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('rent_requests',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('item_id', sa.Integer(), nullable=False),
    sa.Column('requester_id', sa.Integer(), nullable=False),
    sa.Column('latest_accepted_offer_id', sa.Integer(), nullable=True),
    sa.Column('latest_open_offer_id', sa.Integer(), nullable=True),
    sa.Column('borrow_confirmed_at', sa.DateTime(timezone=True), nullable=True),
    sa.Column('returned_at', sa.DateTime(timezone=True), nullable=True),
    sa.Column('requester_read_at', sa.DateTime(timezone=True), nullable=True),
    sa.Column('owner_read_at', sa.DateTime(timezone=True), nullable=True),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.ForeignKeyConstraint(['item_id'], ['items.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['requester_id'], ['users.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('rent_offers',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('rent_request_id', sa.Integer(), nullable=False),
    sa.Column('sender_id', sa.Integer(), nullable=False),
    sa.Column('start_date', sa.DateTime(timezone=True), nullable=False),
    sa.Column('end_date', sa.DateTime(timezone=True), nullable=False),
    sa.Column('accepted_at', sa.DateTime(timezone=True), nullable=True),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.ForeignKeyConstraint(['rent_request_id'], ['rent_requests.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['sender_id'], ['users.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_foreign_key(
        'fk_rent_requests_latest_accepted_offer',
        'rent_requests', 'rent_offers',
        ['latest_accepted_offer_id'], ['id'],
        ondelete='SET NULL'
    )
    op.create_foreign_key(
        'fk_rent_requests_latest_open_offer',
        'rent_requests', 'rent_offers',
        ['latest_open_offer_id'], ['id'],
        ondelete='SET NULL'
    )
    op.create_table('messages',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('rent_request_id', sa.Integer(), nullable=False),
    sa.Column('author_id', sa.Integer(), nullable=False),
    sa.Column('content', sa.String(), nullable=False),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.ForeignKeyConstraint(['author_id'], ['users.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['rent_request_id'], ['rent_requests.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('user_ratings',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('rent_request_id', sa.Integer(), nullable=False),
    sa.Column('reviewer_id', sa.Integer(), nullable=False),
    sa.Column('reviewee_id', sa.Integer(), nullable=False),
    sa.Column('friendliness', sa.Integer(), nullable=False),
    sa.Column('punctuality', sa.Integer(), nullable=False),
    sa.Column('reliability', sa.Integer(), nullable=False),
    sa.Column('communication', sa.Integer(), nullable=True),
    sa.Column('careful_handling', sa.Integer(), nullable=True),
    sa.Column('comment', sa.Text(), nullable=True),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.CheckConstraint('careful_handling IS NULL OR careful_handling BETWEEN 1 AND 5', name='ck_user_rating_careful_handling'),
    sa.CheckConstraint('communication IS NULL OR communication BETWEEN 1 AND 5', name='ck_user_rating_communication'),
    sa.CheckConstraint('friendliness BETWEEN 1 AND 5', name='ck_user_rating_friendliness'),
    sa.CheckConstraint('punctuality BETWEEN 1 AND 5', name='ck_user_rating_punctuality'),
    sa.CheckConstraint('reliability BETWEEN 1 AND 5', name='ck_user_rating_reliability'),
    sa.ForeignKeyConstraint(['rent_request_id'], ['rent_requests.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['reviewee_id'], ['users.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['reviewer_id'], ['users.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('rent_request_id', 'reviewer_id', name='uq_user_rating_once')
    )
    op.create_table('item_ratings',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('rent_request_id', sa.Integer(), nullable=False),
    sa.Column('item_id', sa.Integer(), nullable=False),
    sa.Column('reviewer_id', sa.Integer(), nullable=False),
    sa.Column('condition', sa.Integer(), nullable=False),
    sa.Column('cleanliness', sa.Integer(), nullable=False),
    sa.Column('overall', sa.Float(), nullable=False),
    sa.Column('comment', sa.Text(), nullable=True),
    sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.CheckConstraint('cleanliness BETWEEN 1 AND 5', name='ck_item_rating_cleanliness'),
    sa.CheckConstraint('condition BETWEEN 1 AND 5', name='ck_item_rating_condition'),
    sa.CheckConstraint('overall BETWEEN 1 AND 5', name='ck_item_rating_overall'),
    sa.ForeignKeyConstraint(['item_id'], ['items.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['rent_request_id'], ['rent_requests.id'], ondelete='CASCADE'),
    sa.ForeignKeyConstraint(['reviewer_id'], ['users.id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('rent_request_id', 'reviewer_id', name='uq_item_rating_once')
    )


def downgrade() -> None:
    op.drop_table('item_ratings')
    op.drop_table('user_ratings')
    op.drop_table('messages')
    op.drop_constraint('fk_rent_requests_latest_open_offer', 'rent_requests', type_='foreignkey')
    op.drop_constraint('fk_rent_requests_latest_accepted_offer', 'rent_requests', type_='foreignkey')
    op.drop_table('rent_offers')
    op.drop_table('rent_requests')
    op.drop_table('item_images')
    op.drop_table('items')
    op.drop_table('sessions')
    op.drop_table('profiles')
    op.drop_table('seed_meta')
    op.drop_table('users')
