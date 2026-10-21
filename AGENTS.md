# Agent Instructions

This file is the source of truth for any coding agent (Claude Code, Cursor, Codex, etc.) working in this repo. Read it before touching code.

## Stack

- **Backend:** Python + FastAPI
- **Frontend:** React Native (Expo) + TypeScript
- **Database:** Supabase Postgres (users, chats, source documents, chunks)
- **Migrations:** SQLAlchemy models + Alembic from the backend
- **Retrieval:** Supabase `pgvector` + Postgres full-text search
- **Auth:** Supabase Auth
- **Hosting:** Railway (backend service); the app is built and shipped with Expo (EAS)
- **LLM + embeddings:** OpenAI

Stack is locked unless explicitly changed. Don't propose alternatives without a stated reason.

## Repo layout

```text
document-copilot/
├── AGENTS.md           # this file
├── README.md
├── data/               # local corpus + download script (payloads gitignored)
├── docs/               # specs, briefs, design notes
├── backend/            # FastAPI service (see backend/AGENTS.md)
└── frontend/           # React Native app, Expo (see frontend/AGENTS.md)
```

## Architecture: simple, feature-first (DDD-lite)

Both services organize code **by feature** (documents, retrieval, assistant, chat, auth), with shared plumbing kept separate. Each service uses the file names its own community expects (FastAPI on the backend, feature-based React on the frontend); the layers underneath are the same. Per-service folder trees live in `backend/AGENTS.md` and `frontend/AGENTS.md`.

| Layer | Job | Backend (FastAPI) | Frontend (React Native) |
| --- | --- | --- | --- |
| Presentation | HTTP or UI only, kept thin | `router.py` | `screens/`, `components/` |
| Logic | The feature's use cases and business rules | `service.py`, plus pure rule modules (`chunker.py`, `fusion.py`, `grounding.py`) | `hooks/` |
| Data access | Talks to the outside world (database, OpenAI, backend API) | `repository.py` | `api/` |
| Models | The shapes of the data | `schemas.py` (Pydantic), `models.py` (SQLAlchemy tables) | `types.ts` |

Rules:

- **One direction:** presentation → logic → data access. Data access never imports presentation.
- **Pure rules stay pure:** chunking, rank fusion and citation checks take data in and return data out, with no I/O, so they're unit-testable without a database or the LLM.
- **No interfaces or abstract base classes by default.** Python duck typing and TypeScript structural typing let a test pass a fake object with the same methods. Add a `Protocol` / interface only when a second real implementation exists.
- **Only the files a feature needs.** No empty files or placeholder folders.
- **Features don't import each other's data access** (`repository.py`, `api/`). Use the other feature's service or hooks instead.
- **Shared plumbing only** in `backend/app/core/` and `frontend/src/lib/` (config, database and HTTP clients, auth, theme). No feature logic there.

## Dependency policy

**Default: write it yourself. Reach for a library only when the alternative would be non-trivial, error-prone, or reinvention of a standard.** Every dependency is a liability — bundle size, supply-chain risk, future upgrade work.

OK to depend on:

- Things that are genuinely hard to get right (HTTP clients, ASGI servers, SQL drivers, parsers, LLM SDKs, ORM, migrations, auth SDKs).
- The declared stack (FastAPI, React Native, Expo, Supabase clients, OpenAI SDK, etc.).

Not OK:

- Helper libraries that wrap 5–20 lines of stdlib or platform APIs.
- Frameworks where a function would do.
- "Nicer API" layers on top of an already-present dependency.

Before adding a runtime dep, answer in the commit message:

1. What exactly does it do that we can't write in <30 lines of clear code?
2. How often does it get used?
3. What's its maintenance / transitive-dep footprint?

Per-stack specifics live in `backend/AGENTS.md` and `frontend/AGENTS.md`.

## Configuration

A single settings module is the source of truth for environment per service (`backend/app/core/config.py`, `frontend/src/lib/env.ts`). Do not call `os.getenv` / read `process.env` directly in app code. Do not call `load_dotenv` anywhere. If a third-party SDK reads env vars directly, mirror them in the settings module — don't sprinkle `setdefault` elsewhere.

Fail fast on startup if required config is missing. No silent fallbacks that hide real config errors.

## Code style (universal)

- **Small, obvious functions.** A 15-line function with clear names beats a three-class abstraction.
- **No premature abstraction.** Three similar lines is better than a badly-named base class. Extract when there's a third caller, not a hypothetical one.
- **No error handling for cases that can't happen.** Trust internal callers and framework guarantees. Validate only at boundaries: HTTP input, external APIs, DB writes, untrusted parsing.
- **No backwards-compat shims** unless explicitly asked for.
- **No feature flags** added speculatively.
- **Comments:** explain *why* when non-obvious, never *what*. Remove stale TODOs.
- **Keep files focused.** Prefer small modules.
