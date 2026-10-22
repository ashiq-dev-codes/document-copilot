# Frontend — agent notes

This is the Flutter app for Document Copilot (iOS and Android). Read [../AGENTS.md](../AGENTS.md) first — universal building rules live there. This file adds frontend-specific conventions.

## Stack

- **Flutter** (stable channel) and Dart 3. Lints from `flutter_lints`; `flutter analyze` must stay clean.
- **`flutter_bloc`** — Cubits only, no `Bloc` event classes.
- **`get_it`** for dependency injection.
- **`dio`** for HTTP, through one shared client in `lib/core/network/`.
- **`supabase_flutter`** for auth (email only — no Google sign-in, no SSO providers). It stores the session on the device.
- Streaming answers come from FastAPI as Server-Sent Events, read with Dio (`ResponseType.stream`) and turned into a Dart `Stream`. No extra streaming package.

## Dependency policy

See universal policy in [../AGENTS.md](../AGENTS.md). Frontend-specific:

- Add packages with `flutter pub add <name>`.
- **No code generation:** no `freezed`, `json_serializable` or `build_runner`. Models are hand-written with `fromJson` / `toJson`.
- **One of each:** Dio is the only HTTP client, flutter_bloc the only state management, get_it the only DI. No `http`, `riverpod`, `provider`, `get`, etc. alongside them.
- **Navigation:** plain `Navigator` with an auth gate. No router package unless deep links are needed.
- **Widgets:** build small widgets from Material. Check Flutter itself before adding a UI package.

Before adding a package, check:

1. Is there a Flutter or Dart SDK API that does this?
2. Can a small widget or function do it?
3. Is it small, well-maintained, and worth the maintenance cost?

If yes to (3), add it — but flag the decision in the commit message.

## Layout (to be created during build)

Follows the simple, feature-first architecture in [../AGENTS.md](../AGENTS.md#architecture-simple-feature-first-ddd-lite).

```text
frontend/
├── lib/
│   ├── main.dart                  # Reads config, registers dependencies, runs the app
│   ├── app.dart                   # MaterialApp, theme, auth gate
│   ├── core/                      # Shared plumbing only, no feature logic
│   │   ├── config/env.dart        # Validated --dart-define settings
│   │   ├── network/api_client.dart  # Dio: base URL, Supabase bearer token, timeouts, errors
│   │   ├── di.dart                # get_it registrations
│   │   ├── theme/                 # Colors, text styles
│   │   └── widgets/               # Shared widgets (buttons, inputs, loaders)
│   └── features/
│       ├── auth/                  # sign in / sign up / session
│       └── chat/                  # threads, messages, streaming, citations
├── env.example.json               # Template for env.json (committed)
├── env.json                       # Real values (gitignored)
└── pubspec.yaml
```

Inside each feature (only the parts it needs):

```text
features/<name>/
├── data/
│   └── <name>_repository.dart     # Calls the backend through core/network/api_client.dart
├── models/                        # One model per file, hand-written fromJson / toJson
└── presentation/
    ├── cubit/                     # <thing>_cubit.dart + <thing>_state.dart (sealed states)
    ├── pages/                     # One page per file (chat_thread_page.dart)
    └── widgets/                   # Widgets used only by this feature
```

- Pages read Cubits; Cubits call the repository; only `data/` calls `api_client.dart`.
- No abstract repository + impl pair by default: tests can `implements` the concrete class.
- Register each feature's repository and Cubits in `core/di.dart`.

## Code style (frontend-specific)

- **Small widgets.** Extract a widget class when a build method gets long; prefer classes over helper methods that return widgets.
- **Cubit states are `sealed` classes** (`ChatInitial`, `ChatLoading`, `ChatLoaded`, `ChatFailure`).
- **`const` constructors** wherever possible.
- **Package imports** (`package:document_copilot/...`), not relative imports across features.

## Configuration

- All settings come from `--dart-define-from-file=env.json` and are read only in `lib/core/config/env.dart`, which throws at startup if one is missing. Never call `String.fromEnvironment` anywhere else.
- `env.json` is gitignored; `env.example.json` lists the keys: `API_BASE_URL`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`.
- These values are compiled into the app, so anyone with the app can read them: never put a secret (OpenAI key, Supabase service-role key) in one.

## Backend integration

- Talks to the FastAPI backend over JSON. Base URL comes from `API_BASE_URL`.
- On a phone or emulator, `localhost` means the device itself. During local development, point `API_BASE_URL` at your computer's network IP (or `10.0.2.2` on the Android emulator).
- The Supabase access token is added to every request by an interceptor in `api_client.dart`; never pass tokens through widget constructors.

## Testing

**No frontend test suite for now.** Verify on a device or simulator plus `flutter analyze`. Add Cubit unit tests only if a Cubit's logic becomes non-trivial.

## Anti-patterns (rejected)

- `String.fromEnvironment` outside `core/config/env.dart`.
- A second HTTP client, state-management library, or DI container.
- Code generation for models.
- Calling Dio or Supabase directly from a page or widget.
- Secrets in `env.json` or anywhere in the app.
- Direct OpenAI calls from the app — FastAPI owns every AI call.
