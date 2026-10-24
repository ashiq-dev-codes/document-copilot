# Frontend — agent notes

This is the Flutter app for Document Copilot. It targets every Flutter platform (iOS, Android, web, macOS, Windows, Linux) with app ID `com.documentcopilot.app`; the pilot ships iOS and Android. Read [../AGENTS.md](../AGENTS.md) first — universal building rules live there. This file adds frontend-specific conventions.

## Stack

- **Flutter** (stable channel) and Dart 3. Lints from `flutter_lints`; `flutter analyze` must stay clean.
- **`flutter_bloc`** — Cubits only, no `Bloc` event classes.
- **`get_it`** for dependency injection.
- **`dio`** for HTTP, through one shared client in `lib/core/network/`.
- **`device_preview`** (3.x) to check screens on other device sizes, text scales and dark mode. Enabled with `DevicePreview.enable(enabled: kDebugMode)` as the first line of `main()`; it does nothing in release builds.
- **`lucide_icons_flutter`** for every icon in the UI.
- **`corextra`** (our own package) for the network logger, the in-app network/log inspector (`CorextraDevToolsOverlay`; on only when `AppConfig.isDevToolsEnabled`: release tester builds with `DISTRIBUTION=firebase`, never store builds, never on web, where the browser's DevTools cover it), extensions and form validators. Check it before writing a new helper.
- **`supabase_flutter`** for auth (email only — no Google sign-in, no SSO providers). It stores the session on the device.
- Streaming answers come from FastAPI as Server-Sent Events, read with Dio (`ResponseType.stream`) and turned into a Dart `Stream`. No extra streaming package.

## Dependency policy

See universal policy in [../AGENTS.md](../AGENTS.md). Frontend-specific:

- Add packages with `flutter pub add <name>`.
- **No code generation:** no `freezed`, `json_serializable` or `build_runner`. Models are hand-written with `fromJson` / `toJson`.
- **One of each:** Dio is the only HTTP client, flutter_bloc the only state management, get_it the only DI. No `http`, `riverpod`, `provider`, `get`, etc. alongside them.
- **Navigation:** plain `Navigator` with an auth gate. No router package unless deep links are needed.
- **Widgets:** build small widgets from Material. Check Flutter itself before adding a UI package.
- **Icons:** `lucide_icons_flutter` only (`LucideIcons.logOut`, `LucideIcons.mail`, ...), never Material `Icons.*`, so every screen has the same icon style.

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
│   ├── main.dart                  # Starts Supabase, calls initDependencies(), runs AppRoot
│   ├── injection_container.dart   # `sl` (get_it) + initDependencies(): shared services, then each feature's init<Name>Injection(sl)
│   ├── root.dart                  # AppRoot: everything around the app (keyboard dismiss, MultiBlocProvider for app-wide Cubits only)
│   ├── app.dart                   # App: the MaterialApp only (theme, inspector overlay, auth gate)
│   ├── core/                      # App setup, created once at startup
│   │   ├── config/config.dart     # AppConfig: environment, distribution, backend URL, Supabase project
│   │   └── network/api_client.dart  # Dio: base URL, timeouts, interceptors
│   ├── shared/                    # Reusable building blocks for every feature (ZERO.40 style)
│   │   ├── constant/constant.dart # Shared sizes and spacing (kHeight10, ...)
│   │   ├── text_styles/           # AppText (by weight), sizes/AppFontSize
│   │   ├── theme/
│   │   │   ├── app_colors.dart    # AppColors palette (feeds AppTheme)
│   │   │   └── app_theme.dart     # AppTheme.light / .dark: fields, buttons, snackbars
│   │   ├── utils/
│   │   │   ├── dio/app_interceptor.dart       # Supabase token on every request; on 401 refresh + retry once, else sign out
│   │   │   └── exception/api_exception.dart   # Turns a failed call into one user-facing message
│   │   └── widgets/               # Shared widgets, one folder per kind (snackbar/custom_snack_bar.dart)
│   └── features/
│       ├── auth/                  # sign in / sign up / session
│       └── chat/                  # threads, messages, streaming, citations
└── pubspec.yaml
```

Inside each feature (only the parts it needs):

```text
features/<name>/
├── <name>_injection.dart          # init<Name>Injection(sl) registers this feature's repository and Cubits
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
- **Adding a feature:** register its repository and Cubits in `features/<name>/<name>_injection.dart` (`init<Name>Injection(GetIt sl)`), and call it from `initDependencies()` in `injection_container.dart`.
- **How things live:**
  - Repositories and Dio are stateless and shared: `registerLazySingleton`.
  - Screen Cubits hold one screen's state: `registerFactory`, provided with `BlocProvider(create: (_) => sl<XCubit>())` on the page that uses them, so each visit starts fresh and the Cubit closes when the page leaves. No `clear()` methods.
  - App-wide Cubits (e.g. `AuthCubit`, needed by the auth gate everywhere): `registerLazySingleton`, provided once in `root.dart`'s `MultiBlocProvider`. Keep this list short.

## Code style (frontend-specific)

- **Small widgets.** Extract a widget class when a build method gets long; prefer classes over helper methods that return widgets.
- **Cubit states are `sealed` classes** (`ChatInitial`, `ChatLoading`, `ChatLoaded`, `ChatFailure`).
- **`const` constructors** wherever possible.
- **Look comes from `AppTheme`** (light and dark). Use plain `TextFormField`, `FilledButton`, etc. and let the theme style them; don't style individual widgets. A new shared look (e.g. cards) is added to `AppTheme`, not to a page.
- **Colors in features:** `Theme.of(context).colorScheme.<role>` (primary, onSurfaceVariant, error, ...), so dark mode works. `AppColors` only feeds `AppTheme`.
- **Text:** `AppText.<weight>.textStyle(size: AppFontSize.sXX)`; no inline `TextStyle(...)` in features. Leave `color` null to follow the theme.
- **Spacing:** the `kHeightXX` / `kWidthXX` constants from `shared/constant/constant.dart`.
- **Messages:** `CustomSnackBar.show / success / error(context, message)`; never call `ScaffoldMessenger` directly.
- **Before writing a widget or helper,** check `lib/shared/` (and `corextra`) first. A widget used by two or more features moves into `shared/widgets/`.
- **Package imports** (`package:document_copilot/...`), not relative imports across features.

## Configuration

- All settings live in `AppConfig` (`lib/core/config/config.dart`), ZERO.40 style: the backend URL per `Environment` (`local`, `production`), the Supabase URL and the Supabase **publishable** key.
- Pick the environment with `--dart-define=ENV=production`; plain `flutter run` uses `local`.
- Pick who a build is for with `--dart-define=DISTRIBUTION=firebase` (tester builds); the default is `store`. Store builds never show the in-app inspector. `config.dart` is the only file allowed to call `String.fromEnvironment`.
- An environment without a value yet throws a clear `StateError` instead of falling back silently.
- `config.dart` is committed and compiled into the app, so anyone can read it. Only public values belong there (the Supabase publishable key is designed for this; tables are protected by RLS). Never put a secret (OpenAI key, Supabase secret/service-role key) in the app.

## Backend integration

- Talks to the FastAPI backend over JSON. Base URL comes from `AppConfig.apiBaseUrl`.
- The web build runs in a browser, so the backend must list its address in `ALLOWED_ORIGINS` (CORS). Run it on a fixed port (`flutter run -d chrome --web-port 3000`) so the address matches. Native apps don't need this.
- On a phone or emulator, `localhost` means the device itself. The `local` environment points at your computer's network IP (use `10.0.2.2` on the Android emulator); update it in `config.dart` if your Mac's IP changes.
- The Supabase access token is added to every request by `AppInterceptor`; never pass tokens through widget constructors.
- **Supabase owns the session.** `supabase_flutter` stores it on the device, restores it on launch (auto-login) and refreshes it about every hour. Never copy the token into `AppStorage`/`SharedPreferences`: the copy goes stale after the first refresh and causes 401s.
- Repositories catch `DioException` and rethrow `ApiException.fromDio(e)`, so Cubits only ever see one error type with a ready-to-show `message` (the backend's `detail`, or a friendly network message).
- Calling the local `http://` backend is allowed only for development: Android debug builds (`usesCleartextTraffic` in the debug manifest), iOS local network (`NSAllowsLocalNetworking`), and the macOS network-client entitlement. Production uses `https`.

## Testing

**No frontend test suite for now.** Verify on a device or simulator plus `flutter analyze`. Add Cubit unit tests only if a Cubit's logic becomes non-trivial.

## Anti-patterns (rejected)

- `String.fromEnvironment` outside `core/config/config.dart`.
- A second HTTP client, state-management library, or DI container.
- Code generation for models.
- Material `Icons.*` instead of `LucideIcons.*`.
- Inline `TextStyle(...)` or direct `ScaffoldMessenger` calls in features.
- Calling Dio or Supabase directly from a page or widget.
- Secrets in `config.dart` or anywhere in the app.
- `dart:io`'s `Platform` in shared or UI code: it throws on web. Use `defaultTargetPlatform` or `kIsWeb` from `package:flutter/foundation.dart`.
- Storing the auth token yourself (Supabase already does).
- Direct OpenAI calls from the app — FastAPI owns every AI call.
