# Backend — agent notes

This is the FastAPI service for Document Copilot. Read [../AGENTS.md](../AGENTS.md) first — universal building rules live there. This file adds backend-specific conventions.

## Stack

- Python 3.12+
- FastAPI + uvicorn
- Pydantic v2 + pydantic-settings
- `httpx` for outbound HTTP
- `pytest` for tests
- Supabase Python client (DB + auth)
- SQLAlchemy models + Alembic migrations for database schema changes
- OpenAI SDK for LLM & embeddings
- Supabase `pgvector` for semantic search and Postgres full-text search for keyword retrieval. Hybrid search should run vector and full-text queries separately, then fuse ranked results in Python with Reciprocal Rank Fusion.
- `structlog` for logging
- `uv` for dependency + project management

## Dependency policy

See universal policy in [../AGENTS.md](../AGENTS.md). Backend-specific:

- **Prefer stdlib:** `pathlib`, `datetime`, `uuid`, `enum`, `dataclasses`, `asyncio`, `collections`, `itertools`, `json`, `urllib`.
- **Not OK without justification:** `python-dateutil`, `toolz`, `funcy`, `more-itertools`, small JSON/string micro-libs, "ergonomic" wrappers on top of declared SDKs.
- Dev deps (test/lint/build) have a looser bar but still pick widely-used, low-footprint tools (`pytest`, `ruff`, `httpx`).

## Layout (to be created during build)

Follows the simple, feature-first architecture in [../AGENTS.md](../AGENTS.md#architecture-simple-feature-first-ddd-lite), using standard FastAPI file names.

```text
backend/
├── alembic/
│   ├── env.py               # Imports every feature's models package for autogenerate
│   └── versions/            # Reviewed migration files
├── alembic.ini
├── app/
│   ├── main.py              # FastAPI entrypoint: CORS, routers, health check
│   ├── core/                # Shared plumbing only, no feature logic
│   │   ├── config.py        # Pydantic settings — single source of truth for env
│   │   ├── database.py      # SQLAlchemy Base/engine + Supabase clients
│   │   └── auth.py          # Supabase JWT verification + get_current_user dependency
│   └── features/            # One folder per feature
│       ├── documents/       # Source filings + chunks: parse, chunk, embed, store
│       ├── retrieval/       # Hybrid search: pgvector + full-text + RRF fusion
│       ├── assistant/       # PydanticAI agent, instructions, grounding checks
│       └── chat/            # Threads, messages, citations, one chat turn, streaming
├── ingest/                  # One-off CLI entry points that call feature services
├── tests/                   # Mirrors app/: tests/features/retrieval/test_fusion.py
└── pyproject.toml
```

Inside each feature, **every layer is its own folder** (only the folders it needs):

```text
app/features/<feature>/
├── routers/         # chat_router.py: FastAPI APIRouter, thin, validates input, calls the service
├── schemas/         # Pydantic models, one per file (thread_response.py)
├── models/          # SQLAlchemy tables, one per file (chat_thread.py)
├── services/        # chat_service.py: use cases, the feature's logic (like a Cubit)
├── repositories/    # chat_repository.py: database queries for this feature's tables
├── dependencies/    # chat_dependencies.py: Depends functions that build the service and repository
├── exceptions/      # chat_exceptions.py: the feature's HTTP errors (ThreadNotFound -> 404)
└── rules/           # Pure business rules, one per file: chunker.py, fusion.py, grounding.py
```

- **Every layer is a folder, even with one file in it.** Files are named `<feature>_<layer>.py` (`chat_service.py`); `models/` and `schemas/` are named after the class (`chat_thread.py`). One class per file.
- **Each folder's `__init__.py` re-exports its public names** and lists them in `__all__`, so imports stay short: `from app.features.chat.services import ChatService`.
- Pydantic for data crossing a boundary (HTTP, LLM output, settings); dataclasses for internal data.
- The service receives its repository as a constructor argument, so a unit test can pass a fake one. No `Protocol` unless two real implementations exist.
- Unit tests target `rules/` and `services/`; `repositories/` are covered by integration tests.

## Code style (backend-specific)

- **Type hints on public functions and module-level things.** Don't annotate every local.
- **Async by default in request-path code.** Don't run blocking I/O on the event loop. Tempfile + small synchronous file reads are OK (they're fast); network calls must be async.
- **Use `async def` for all route handlers** and any I/O service function.
- **Validate at boundaries only.** HTTP input is validated by Pydantic models. External API responses are validated when parsed. Internal callers are trusted.
- **JSON is camelCase.** Every schema extends `ApiSchema` (`app/core/schemas.py`): Python fields stay snake_case, the app sees camelCase (`created_at` -> `createdAt`), and schemas can be built from rows with `Model.model_validate(row)`.
- **Typed responses, no envelope.** Every endpoint returns a Pydantic model from the feature's `schemas/` folder (e.g. `-> UserResponse`), never a bare `dict`. The HTTP status code says success or failure.
- **Errors:** `raise HTTPException(status_code, "message")`; the app reads `{"detail": "..."}`. Add a machine-readable `code` only when the app must react differently to different errors.
- **Protected endpoints** take `user: CurrentUserDep` (from `app.core.auth`); never read the `Authorization` header by hand.

## Configuration

- `app.core.config.settings` is the single source of truth. Import settings where needed; never call `os.getenv` in app code, never call `load_dotenv`.
- If a third-party SDK reads `os.environ` directly, add the mirror in `core/config.py` — don't sprinkle `setdefault` elsewhere.
- Fail fast on startup when required env vars are missing.

## Database migrations

- Alembic is the source of truth for schema changes. Do not change production tables manually in the Supabase dashboard.
- SQLAlchemy models live in each feature's `models/` folder, one table per file, and describe normal tables and columns. The folder's `__init__.py` imports every table and lists it in `__all__`, so `import app.features.<feature>.models` registers them all. Alembic autogenerate creates candidate migrations, but every generated migration must be reviewed before applying.
- Generated `tsvector` columns (`Computed(...)`) and HNSW/GIN indexes (`Index(..., postgresql_using=...)`) go in the models, so autogenerate doesn't try to drop them later.
- Things autogenerate can't see belong in explicit migration operations: `create extension vector`, RLS enablement, RLS policies, and grants.
- Alembic must use the direct/session database connection, not the Supabase transaction pooler URL.
- Run migrations from `backend/` with `uv run alembic upgrade head`.

## Tests

- **Prefer unit over integration.** Mock at the service boundary.
- Fast suite (`pytest -m "not integration"`) must stay green and hit no network / no DB.
- Integration tests go behind `@pytest.mark.integration` and may require live OpenAI / Supabase credentials.
- Tests mirror the app layout (`app/features/retrieval/rules/fusion.py` → `tests/features/retrieval/test_fusion.py`).
- Required test coverage: ingestion logic, retrieval, citation extraction, grounding enforcement.

## Anti-patterns (rejected)

- `os.getenv` / `load_dotenv` in modules.
- Wrapping FastAPI responses in custom envelope classes.
- Over-catching `Exception` just to log and re-raise; let it propagate.
- Shared state through globals instead of FastAPI `app.state` or DI.
- Silent fallbacks that hide real config errors.
- Mocking the LLM in unit tests without also testing the grounding contract — the prompt is the product.
