"""Chat use cases: a user only ever sees their own conversations."""

import uuid

from app.core.auth import CurrentUser
from app.features.chat.exceptions import ThreadForbidden, ThreadNotFound
from app.features.chat.models import ChatMessage, ChatThread
from app.features.chat.repositories import ChatRepository


class ChatService:
    def __init__(self, repository: ChatRepository) -> None:
        self._repository = repository

    async def list_threads(self, user: CurrentUser) -> list[ChatThread]:
        return await self._repository.list_threads(user.id)

    async def create_thread(self, user: CurrentUser, title: str) -> ChatThread:
        return await self._repository.create_thread(user.id, title)

    async def list_messages(
        self, user: CurrentUser, thread_id: uuid.UUID
    ) -> list[ChatMessage]:
        await self.get_own_thread(user, thread_id)
        return await self._repository.list_messages(thread_id)

    async def get_own_thread(
        self, user: CurrentUser, thread_id: uuid.UUID
    ) -> ChatThread:
        """Returns the thread, or raises 404 / 403 if it's missing or someone else's."""
        thread = await self._repository.get_thread(thread_id)
        if thread is None:
            raise ThreadNotFound()
        if thread.user_id != user.id:
            raise ThreadForbidden()
        return thread
