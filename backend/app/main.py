"""FastAPI app: plugs in every feature's router."""

from fastapi import FastAPI
from pydantic import BaseModel

from app.features.auth.router import router as auth_router


class HealthResponse(BaseModel):
    """Tells Railway and the app that the server is running."""

    status: str


app = FastAPI()
app.include_router(auth_router)


@app.get("/health")
async def health() -> HealthResponse:
    return HealthResponse(status="ok")
