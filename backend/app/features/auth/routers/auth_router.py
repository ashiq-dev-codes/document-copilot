"""Auth endpoints."""

from fastapi import APIRouter

from app.core.auth import CurrentUserDep
from app.features.auth.schemas import UserResponse

router = APIRouter(prefix="/auth", tags=["auth"])


@router.get("/me")
async def me(user: CurrentUserDep) -> UserResponse:
    return UserResponse(id=user.id, email=user.email)
