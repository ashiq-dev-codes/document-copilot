"""FastAPI app: plugs in every feature's router."""

from fastapi import FastAPI

from app.features.auth.router import router as auth_router

app = FastAPI()


@app.get("/health")
async def health() -> dict[str, str]:
    return {
        "status": "ok",
    }


app.include_router(auth_router)
