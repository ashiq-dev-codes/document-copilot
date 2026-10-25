"""The user data the API sends to the app."""

import uuid

from app.core.schemas import ApiSchema


class UserResponse(ApiSchema):
    """The signed-in user, as returned by GET /auth/me."""

    id: uuid.UUID
    email: str
