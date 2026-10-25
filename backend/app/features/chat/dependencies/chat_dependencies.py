"""Builds the chat service for each request."""

from typing import Annotated

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.features.chat.repositories import ChatRepository
from app.features.chat.services import ChatService


def get_chat_service(
    session: Annotated[AsyncSession, Depends(get_session)],
) -> ChatService:
    return ChatService(ChatRepository(session))


ChatServiceDep = Annotated[ChatService, Depends(get_chat_service)]
