"""One question or answer, as the app sees it."""

import uuid
from datetime import datetime
from typing import Literal

from app.core.schemas import ApiSchema


class MessageResponse(ApiSchema):
    id: uuid.UUID
    role: Literal["user", "assistant"]
    content: str
    created_at: datetime
