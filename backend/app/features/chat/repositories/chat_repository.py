"""Database queries for threads and messages."""

import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.features.chat.models import ChatMessage, ChatThread


class ChatRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def list_threads(self, user_id: uuid.UUID) -> list[ChatThread]:
        rows = await self._session.scalars(
            select(ChatThread)
            .where(ChatThread.user_id == user_id)
            .order_by(ChatThread.created_at.desc())
        )
        return list(rows)

    async def get_thread(self, thread_id: uuid.UUID) -> ChatThread | None:
        return await self._session.get(ChatThread, thread_id)

    async def create_thread(self, user_id: uuid.UUID, title: str) -> ChatThread:
        thread = ChatThread(user_id=user_id, title=title)
        self._session.add(thread)
        await self._session.commit()
        await self._session.refresh(thread)  # loads created_at, set by the database
        return thread

    async def list_messages(self, thread_id: uuid.UUID) -> list[ChatMessage]:
        rows = await self._session.scalars(
            select(ChatMessage)
            .where(ChatMessage.thread_id == thread_id)
            .order_by(ChatMessage.created_at)
        )
        return list(rows)
