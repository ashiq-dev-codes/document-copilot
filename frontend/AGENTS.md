# Frontend — agent notes

This is the Flutter app for Document Copilot. It targets every Flutter platform (iOS, Android, web, macOS, Windows, Linux) with app ID `com.documentcopilot.app`; the pilot ships iOS and Android. Read [../AGENTS.md](../AGENTS.md) first — universal building rules live there. This file adds frontend-specific conventions.

## Stack

- **Flutter** (stable channel) and Dart 3. Lints from `flutter_lints`; `flutter analyze` must stay clean.
- **`flutter_bloc`** — Cubits only, no `Bloc` event classes.
- **`get_it`** for dependency injection.
- **`dio`** for HTTP, through one shared client in `lib/core/network/`.
- **`device_preview`** (3.x) to check screens on other device sizes, text scales and dark mode. Enabled with `DevicePreview.enable(enabled: kDebugMode)` as the first line of `main()`; it does nothing in release builds.
- **`corextra`** (our own package) for the network logger, the in-app network/log inspector (`CorextraDevToolsOverlay`, debug builds only), extensions and form validators. Check it before writing a new helper.
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
│   │   ├── config/config.dart     # AppConfig: environment, backend URL, Supabase project
│   │   ├── network/
│   │   │   ├── api_client.dart    # Dio: base URL, timeouts, interceptors
│   │   │   ├── auth_interceptor.dart  # Adds the Supabase token to every request
│   │   │   └── api_exception.dart # Turns a failed call into one user-facing message
│   │   ├── di.dart                # get_it registrations
│   │   ├── theme/                 # Colors, text styles
│   │   └── widgets/               # Shared widgets (buttons, inputs, loaders)
│   └── features/
│       ├── auth/                  # sign in / sign up / session
│       └── chat/                  # threads, messages, streaming, citations
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

- All settings live in `AppConfig` (`lib/core/config/config.dart`), ZERO.40 style: the backend URL per `Environment` (`local`, `production`), the Supabase URL and the Supabase **publishable** key.
- Pick the environment with `--dart-define=ENV=production`; plain `flutter run` uses `local`. `config.dart` is the only file allowed to call `String.fromEnvironment`.
- An environment without a value yet throws a clear `StateError` instead of falling back silently.
- `config.dart` is committed and compiled into the app, so anyone can read it. Only public values belong there (the Supabase publishable key is designed for this; tables are protected by RLS). Never put a secret (OpenAI key, Supabase secret/service-role key) in the app.

## Backend integration

- Talks to the FastAPI backend over JSON. Base URL comes from `AppConfig.apiBaseUrl`.
- The web build runs in a browser, so the backend must list its address in `ALLOWED_ORIGINS` (CORS). Run it on a fixed port (`flutter run -d chrome --web-port 3000`) so the address matches. Native apps don't need this.
- On a phone or emulator, `localhost` means the device itself. The `local` environment points at your computer's network IP (use `10.0.2.2` on the Android emulator); update it in `config.dart` if your Mac's IP changes.
- The Supabase access token is added to every request by `AuthInterceptor`; never pass tokens through widget constructors.
- Repositories catch `DioException` and rethrow `ApiException.fromDio(e)`, so Cubits only ever see one error type with a ready-to-show `message` (the backend's `detail`, or a friendly network message).
- Calling the local `http://` backend is allowed only for development: Android debug builds (`usesCleartextTraffic` in the debug manifest), iOS local network (`NSAllowsLocalNetworking`), and the macOS network-client entitlement. Production uses `https`.

## Testing

**No frontend test suite for now.** Verify on a device or simulator plus `flutter analyze`. Add Cubit unit tests only if a Cubit's logic becomes non-trivial.

## Anti-patterns (rejected)

- `String.fromEnvironment` outside `core/config/config.dart`.
- A second HTTP client, state-management library, or DI container.
- Code generation for models.
- Calling Dio or Supabase directly from a page or widget.
- Secrets in `config.dart` or anywhere in the app.
- Direct OpenAI calls from the app — FastAPI owns every AI call.
