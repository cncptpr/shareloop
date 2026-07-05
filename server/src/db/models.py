import uuid as uuid_pkg
from datetime import datetime

from geoalchemy2 import Geography
from sqlalchemy import (
    CheckConstraint,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    Numeric,
    String,
    Text,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    email: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String, nullable=False)
    last_online_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    profile: Mapped["Profile"] = relationship(back_populates="user", uselist=False)
    sessions: Mapped[list["Session"]] = relationship(back_populates="user")


class Profile(Base):
    __tablename__ = "profiles"

    id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    name: Mapped[str] = mapped_column(String, nullable=False)
    bio: Mapped[str | None] = mapped_column(Text, nullable=True)
    rating: Mapped[float | None] = mapped_column(Numeric(3, 2), nullable=True)
    avatar_uuid: Mapped[uuid_pkg.UUID | None] = mapped_column(
        UUID(as_uuid=True), nullable=True
    )
    updated_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=True
    )

    user: Mapped["User"] = relationship(back_populates="profile")


class Session(Base):
    __tablename__ = "sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    token_hash: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    refresh_token_hash: Mapped[str] = mapped_column(String, default="", nullable=False)
    refresh_expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    user: Mapped["User"] = relationship(back_populates="sessions")


class Item(Base):
    __tablename__ = "items"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    title: Mapped[str] = mapped_column(String, nullable=False)
    description: Mapped[str] = mapped_column(String, nullable=False)
    author_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    score: Mapped[float] = mapped_column(Float, nullable=False)
    location: Mapped[str | None] = mapped_column(Geography("POINT", srid=4326), nullable=True)
    city: Mapped[str | None] = mapped_column(String, nullable=True)
    postal_code: Mapped[str | None] = mapped_column(String, nullable=True)
    category: Mapped[str] = mapped_column(String, nullable=False, server_default="Sonstiges")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    images: Mapped[list["ItemImage"]] = relationship(back_populates="item", cascade="all, delete-orphan")
    ratings: Mapped[list["ItemRating"]] = relationship(back_populates="item", cascade="all, delete-orphan")


class ItemImage(Base):
    __tablename__ = "item_images"

    id: Mapped[uuid_pkg.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    item_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("items.id", ondelete="CASCADE"), nullable=False
    )
    original_name: Mapped[str] = mapped_column(String, nullable=False)
    mime_type: Mapped[str] = mapped_column(String, nullable=False)
    sort_order: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    item: Mapped["Item"] = relationship(back_populates="images")


class RentRequest(Base):
    __tablename__ = "rent_requests"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    item_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("items.id", ondelete="CASCADE"), nullable=False
    )
    requester_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    latest_accepted_offer_id: Mapped[int | None] = mapped_column(
        Integer, ForeignKey("rent_offers.id", ondelete="SET NULL"), nullable=True
    )
    latest_open_offer_id: Mapped[int | None] = mapped_column(
        Integer, ForeignKey("rent_offers.id", ondelete="SET NULL"), nullable=True
    )
    borrow_confirmed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    returned_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    requester_read_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    owner_read_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    messages: Mapped[list["Message"]] = relationship(back_populates="rent_request")
    user_ratings: Mapped[list["UserRating"]] = relationship(back_populates="rent_request")
    item_ratings: Mapped[list["ItemRating"]] = relationship(back_populates="rent_request")
    offers: Mapped[list["RentOffer"]] = relationship(
        back_populates="rent_request",
        primaryjoin="RentOffer.rent_request_id == RentRequest.id",
    )


class Message(Base):
    __tablename__ = "messages"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    rent_request_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("rent_requests.id", ondelete="CASCADE"), nullable=False
    )
    author_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    content: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    rent_request: Mapped["RentRequest"] = relationship(back_populates="messages")


class SeedMeta(Base):
    __tablename__ = "seed_meta"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    seeded_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class RentOffer(Base):
    __tablename__ = "rent_offers"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    rent_request_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("rent_requests.id", ondelete="CASCADE"), nullable=False
    )
    sender_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    start_date: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_date: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    accepted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    rent_request: Mapped["RentRequest"] = relationship(
        back_populates="offers",
        primaryjoin="RentOffer.rent_request_id == RentRequest.id",
    )


class Follow(Base):
    __tablename__ = "follows"

    follower_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    followed_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )


class UserRating(Base):
    __tablename__ = "user_ratings"
    __table_args__ = (
        UniqueConstraint("rent_request_id", "reviewer_id", name="uq_user_rating_once"),
        CheckConstraint("friendliness BETWEEN 1 AND 5", name="ck_user_rating_friendliness"),
        CheckConstraint("punctuality BETWEEN 1 AND 5", name="ck_user_rating_punctuality"),
        CheckConstraint("reliability BETWEEN 1 AND 5", name="ck_user_rating_reliability"),
        CheckConstraint(
            "communication IS NULL OR communication BETWEEN 1 AND 5",
            name="ck_user_rating_communication",
        ),
        CheckConstraint(
            "careful_handling IS NULL OR careful_handling BETWEEN 1 AND 5",
            name="ck_user_rating_careful_handling",
        ),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    rent_request_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("rent_requests.id", ondelete="CASCADE"), nullable=False
    )
    reviewer_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    reviewee_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    friendliness: Mapped[int] = mapped_column(Integer, nullable=False)
    punctuality: Mapped[int] = mapped_column(Integer, nullable=False)
    reliability: Mapped[int] = mapped_column(Integer, nullable=False)
    communication: Mapped[int | None] = mapped_column(Integer, nullable=True)
    careful_handling: Mapped[int | None] = mapped_column(Integer, nullable=True)
    comment: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    rent_request: Mapped["RentRequest"] = relationship(back_populates="user_ratings")


class ItemRating(Base):
    __tablename__ = "item_ratings"
    __table_args__ = (
        UniqueConstraint("rent_request_id", "reviewer_id", name="uq_item_rating_once"),
        CheckConstraint("condition BETWEEN 1 AND 5", name="ck_item_rating_condition"),
        CheckConstraint("cleanliness BETWEEN 1 AND 5", name="ck_item_rating_cleanliness"),
        CheckConstraint("overall BETWEEN 1 AND 5", name="ck_item_rating_overall"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    rent_request_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("rent_requests.id", ondelete="CASCADE"), nullable=False
    )
    item_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("items.id", ondelete="CASCADE"), nullable=False
    )
    reviewer_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    condition: Mapped[int] = mapped_column(Integer, nullable=False)
    cleanliness: Mapped[int] = mapped_column(Integer, nullable=False)
    overall: Mapped[float] = mapped_column(Float, nullable=False)
    comment: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    rent_request: Mapped["RentRequest"] = relationship(back_populates="item_ratings")
    item: Mapped["Item"] = relationship(back_populates="ratings")
