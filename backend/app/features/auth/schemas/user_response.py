"""The user data the API sends to the app."""

import uuid

from pydantic import BaseModel


class UserResponse(BaseModel):
    """The signed-in user, as returned by GET /auth/me."""

    id: uuid.UUID
    email: str
