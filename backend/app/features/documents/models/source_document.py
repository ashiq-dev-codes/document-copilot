import uuid
from datetime import date, datetime

from sqlalchemy import DateTime, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class SourceDocument(Base):
    __tablename__ = "source_documents"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    ticker: Mapped[str] = mapped_column(index=True)
    form: Mapped[str]
    filing_date: Mapped[date]
    report_date: Mapped[date]
    accession_number: Mapped[str] = mapped_column(unique=True)
    source_url: Mapped[str]
    content: Mapped[str]
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
