from typing import Annotated

from fastapi import APIRouter, Depends

from app.core.auth import CurrentUser, get_current_user

router = APIRouter(prefix="/auth", tags=["auth"])


@router.get("/me")
async def me(
    user: Annotated[CurrentUser, Depends(get_current_user)],
) -> dict[str, str]:
    return {
        "id": str(user.id),
        "email": user.email,
    }
