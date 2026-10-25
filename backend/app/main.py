"""FastAPI app: plugs in every feature's router."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from app.core.config import settings
from app.features.auth.routers import router as auth_router
from app.features.chat.routers import router as chat_router


class HealthResponse(BaseModel):
    """Tells Railway and the app that the server is running."""

    status: str


app = FastAPI()

# Browsers (the Flutter web build) may only call us from these addresses.
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins.split(","),
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(chat_router)


@app.get("/health")
async def health() -> HealthResponse:
    return HealthResponse(status="ok")
