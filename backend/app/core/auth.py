"""Checks the Supabase login token on protected endpoints."""

import uuid
from dataclasses import dataclass
from typing import Annotated

import httpx
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.config import settings

SUPABASE_USER_URL = f"{settings.supabase_url}/auth/v1/user"

# Reads the "Authorization: Bearer <token>" header.
# auto_error=False so a missing header gets our own clear 401 message.
bearer_scheme = HTTPBearer(auto_error=False)


@dataclass(frozen=True)
class CurrentUser:
    """The signed-in user making the request."""

    id: uuid.UUID
    email: str


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)],
) -> CurrentUser:
    """Returns the signed-in user, or stops the request with an error."""
    if credentials is None:
        raise _unauthorized("Missing bearer token")

    response = await _fetch_supabase_user(credentials.credentials)

    if response.status_code == status.HTTP_200_OK:
        data = response.json()
        return CurrentUser(id=uuid.UUID(data["id"]), email=data["email"])
    if response.status_code >= 500:
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, "Auth service unavailable")
    raise _unauthorized("Invalid or expired token")


# Helpers


# Add `user: CurrentUserDep` to any endpoint that needs a signed-in user.
CurrentUserDep = Annotated[CurrentUser, Depends(get_current_user)]


async def _fetch_supabase_user(token: str) -> httpx.Response:
    """Asks Supabase Auth which user owns this token."""
    async with httpx.AsyncClient(timeout=10) as client:
        return await client.get(
            SUPABASE_USER_URL,
            headers={
                "apikey": settings.supabase_anon_key,
                "Authorization": f"Bearer {token}",
            },
        )


def _unauthorized(message: str) -> HTTPException:
    return HTTPException(status.HTTP_401_UNAUTHORIZED, message)
