import uuid

from pgvector.sqlalchemy import Vector
from sqlalchemy import Computed, ForeignKey, Index
from sqlalchemy.dialects.postgresql import TSVECTOR
from sqlalchemy.orm import Mapped, mapped_column

from app.core.config import settings
from app.core.database import Base


class DocumentChunk(Base):
    __tablename__ = "document_chunks"
    __table_args__ = (
        # Fast "nearest meaning" search over embeddings.
        Index(
            "ix_document_chunks_embedding",
            "embedding",
            postgresql_using="hnsw",
            postgresql_ops={"embedding": "vector_cosine_ops"},
        ),
        # Fast keyword search over the generated search_vector.
        Index(
            "ix_document_chunks_search_vector",
            "search_vector",
            postgresql_using="gin",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    document_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("source_documents.id", ondelete="CASCADE"), index=True
    )
    chunk_index: Mapped[int]
    page: Mapped[int | None]
    section: Mapped[str | None]
    content: Mapped[str]
    embedding: Mapped[list[float]] = mapped_column(
        Vector(settings.openai_embedding_dimensions)
    )
    # Postgres fills this from content on every insert/update, for full-text search.
    search_vector: Mapped[str] = mapped_column(
        TSVECTOR, Computed("to_tsvector('english', content)", persisted=True)
    )
