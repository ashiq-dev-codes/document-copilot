"""App settings, read from backend/.env and checked at startup."""

from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

# backend/.env, found from this file's location (app/core/config.py) so it works from any folder.
ENV_FILE = Path(__file__).resolve().parents[2] / ".env"


class Settings(BaseSettings):
    """Every setting the backend needs; the app won't start if one is missing."""

    model_config = SettingsConfigDict(env_file=ENV_FILE)

    # Supabase
    supabase_url: str
    supabase_anon_key: str
    supabase_service_role_key: str
    database_url: str

    # OpenAI
    openai_api_key: str
    openai_embedding_model: str
    openai_embedding_dimensions: int

    # Server: comma-separated list of origins allowed to call the API.
    allowed_origins: str


settings = Settings()
