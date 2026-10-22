from sqlalchemy.orm import DeclarativeBase

from app.core.config import settings

# Supabase gives a postgresql:// URL; SQLAlchemy needs the driver name in it
# to use psycopg (v3) instead of looking for the older psycopg2.
DATABASE_URL = settings.database_url.replace(
    "postgresql://", "postgresql+psycopg://", 1
)


class Base(DeclarativeBase):
    pass
