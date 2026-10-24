import uuid
from dataclasses import dataclass
from typing import Annotated

import httpx
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.config import settings

# Reads "Authorization: Bearer <token>"; auto_error=False so we return our own 401 message.
bearer_scheme = HTTPBearer(auto_error=False)


@dataclass(frozen=True)
class CurrentUser:
    id: uuid.UUID
    email: str


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)],
) -> CurrentUser:
    if credentials is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Missing bearer token")

    # Supabase Auth decides whether the token is real and not expired.
    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.get(
            f"{settings.supabase_url}/auth/v1/user",
            headers={
                "apikey": settings.supabase_anon_key,
                "Authorization": f"Bearer {credentials.credentials}",
            },
        )

    if response.status_code == status.HTTP_200_OK:
        user = response.json()
        return CurrentUser(id=uuid.UUID(user["id"]), email=user["email"])
    if response.status_code < 500:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid or expired token")
    raise HTTPException(status.HTTP_502_BAD_GATEWAY, "Auth service unavailable")


# Add `user: CurrentUserDep` to any endpoint to require a signed-in user.
CurrentUserDep = Annotated[CurrentUser, Depends(get_current_user)]
