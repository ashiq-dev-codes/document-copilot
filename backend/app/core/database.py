"""Database connection: the table base class and a session per request."""

from collections.abc import AsyncIterator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.core.config import settings

# Supabase gives a postgresql:// URL; SQLAlchemy needs the driver name in it
# to use psycopg (v3) instead of looking for the older psycopg2.
DATABASE_URL = settings.database_url.replace(
    "postgresql://", "postgresql+psycopg://", 1
)


class Base(DeclarativeBase):
    """Parent of every table; Alembic reads all tables from it."""


engine = create_async_engine(DATABASE_URL)
SessionLocal = async_sessionmaker(engine, expire_on_commit=False)


async def get_session() -> AsyncIterator[AsyncSession]:
    """Opens a database session for one request and closes it afterwards."""
    async with SessionLocal() as session:
        yield session
