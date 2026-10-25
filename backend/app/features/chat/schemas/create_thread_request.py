"""The body of POST /chat/threads."""

from pydantic import Field

from app.core.schemas import ApiSchema


class CreateThreadRequest(ApiSchema):
    title: str = Field(min_length=1, max_length=200)
