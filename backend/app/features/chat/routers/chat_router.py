"""Chat endpoints."""

import uuid

from fastapi import APIRouter, status

from app.core.auth import CurrentUserDep
from app.features.chat.dependencies import ChatServiceDep
from app.features.chat.schemas import (
    CreateThreadRequest,
    MessageResponse,
    ThreadResponse,
)

router = APIRouter(prefix="/chat", tags=["chat"])


@router.get("/threads")
async def list_threads(
    user: CurrentUserDep, service: ChatServiceDep
) -> list[ThreadResponse]:
    threads = await service.list_threads(user)
    return [ThreadResponse.model_validate(thread) for thread in threads]


@router.post("/threads", status_code=status.HTTP_201_CREATED)
async def create_thread(
    body: CreateThreadRequest, user: CurrentUserDep, service: ChatServiceDep
) -> ThreadResponse:
    thread = await service.create_thread(user, body.title)
    return ThreadResponse.model_validate(thread)


@router.get("/threads/{thread_id}/messages")
async def list_messages(
    thread_id: uuid.UUID, user: CurrentUserDep, service: ChatServiceDep
) -> list[MessageResponse]:
    messages = await service.list_messages(user, thread_id)
    return [MessageResponse.model_validate(message) for message in messages]
