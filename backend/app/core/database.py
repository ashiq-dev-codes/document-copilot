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
    pass


engine = create_async_engine(DATABASE_URL)
SessionLocal = async_sessionmaker(engine, expire_on_commit=False)


async def get_session() -> AsyncIterator[AsyncSession]:
    async with SessionLocal() as session:
        yield session
