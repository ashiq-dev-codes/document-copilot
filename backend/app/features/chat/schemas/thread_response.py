"""A conversation, as the app sees it."""

import uuid
from datetime import datetime

from app.core.schemas import ApiSchema


class ThreadResponse(ApiSchema):
    id: uuid.UUID
    title: str
    created_at: datetime
