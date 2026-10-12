# Frontend — agent notes

This is the React Native app for Document Copilot, built with Expo. Read [../AGENTS.md](../AGENTS.md) first — universal building rules live there. This file adds frontend-specific conventions.

## Stack

- **React Native + Expo** (TypeScript, strict). Runs on iOS and Android. Use Expo's managed workflow: configure native settings through `app.json` and config plugins, never by hand-editing generated `ios/` or `android/` folders.
- **Expo Router** for navigation. Screens are files under `src/app/`.
- **React Native core components** (`View`, `Text`, `Pressable`, `FlatList`, `TextInput`, ...) styled with `StyleSheet.create`. No styling or UI-kit libraries.
- **`@supabase/supabase-js`** for auth (email only — no Google sign-in, no SSO providers). The session is stored on the device using the storage setup from Supabase's Expo guide.
- **Vercel AI SDK** (`useChat`) for chat state and streaming. Pass `fetch` from `expo/fetch`: React Native's built-in `fetch` can't read a streamed response.

## Package manager

**`pnpm` only.** Do not use `npm install` or `yarn add`. The lockfile is `pnpm-lock.yaml`. If you see `package-lock.json` or `yarn.lock` appear, that's a bug — delete it.

Add Expo and React Native packages with `pnpm expo install <name>` so the version matches the installed Expo SDK. Use `pnpm add <name>` only for plain JavaScript packages.

**Minimum release age: 7 days.** Configured via `.npmrc` (`minimum-release-age=10080` minutes). pnpm will refuse to install any package version published less than 7 days ago. This defends against typosquat / compromised-release attacks where a malicious version of a popular package goes live and gets pulled within hours.

If a fresh package is genuinely required (e.g. urgent security fix in a dep we already use), override per-install and justify in the commit message — don't lower the global threshold.

## Dependency policy

See universal policy in [../AGENTS.md](../AGENTS.md). Frontend-specific:

- **HTTP:** use the native `fetch` API through a thin client in `src/lib/http.ts` and the `api` singleton in `src/lib/api.ts`. **No axios, ky, got, superagent, redaxios.**
- **Dates:** use native `Date` and `Intl.DateTimeFormat`. No moment, dayjs, date-fns unless genuinely needed.
- **Utilities:** use native `Array` / `Object` / `Map` methods. No lodash, ramda.
- **State:** `useState` / `useReducer` / `useContext` first. Only reach for external state libraries when the pain is real.
- **Forms:** controlled `TextInput` components with `useState`. No form libraries.
- **Validation:** only add a schema library when we actually need runtime validation at boundaries.
- **UI components:** build small components from React Native core components. Check Expo's own packages before adding a third-party one.

Before adding a package, check:

1. Is there a React Native, Expo, or TS/JS API that does this?
2. Can a small component built from core components do it?
3. Is it small, well-maintained, and worth the maintenance cost?

If yes to (3), add it — but flag the decision in the commit message.

## Layout (to be created during build)

```text
frontend/
├── src/
│   ├── app/               # Expo Router screens (one file = one screen)
│   │   ├── _layout.tsx    # Root layout: auth gate + navigation
│   │   ├── (auth)/        # Sign-in, sign-up
│   │   └── (app)/         # Chat list, chat thread
│   ├── components/        # App components (chat/, ui/)
│   └── lib/               # Framework-agnostic helpers (http, api, auth, supabase, env)
├── app.json               # Expo config
├── tsconfig.json
└── package.json
```

Keep imports consistent with the `@/*` alias (e.g. `@/lib/api`, `@/components/chat/message-list`).

## Code style (frontend-specific)

- **TypeScript strict.** No `any` unless there's no alternative; prefer `unknown` and narrow.
- **Small, composable functions and components** over clever abstractions. Three similar lines > a premature generic.
- **One component = one file.** Components stay small enough to fit on one screen.
- **Styles live next to the component** in a `StyleSheet.create` block at the bottom of the same file. Shared colors and spacing live in `src/lib/theme.ts`.

## Configuration

- All env reads go through a single `src/lib/env.ts` module that validates required vars at startup. Never read `process.env.EXPO_PUBLIC_X` directly in components.
- Env vars are prefixed `EXPO_PUBLIC_`. Expo copies them into the app bundle, so anyone with the app can read them: never put a secret in one.

## Backend integration

- Talks to a separate Python backend over JSON. URL comes from `EXPO_PUBLIC_API_BASE_URL`.
- On a phone or emulator, `localhost` means the device itself. During local development, point `EXPO_PUBLIC_API_BASE_URL` at your computer's network IP (or `10.0.2.2` on the Android emulator).
- Always use `api.get/post/put/patch/delete` from `@/lib/api` — it handles base URL, JSON, Supabase bearer token, timeouts, and typed `ApiError`s (including the `isNetworkError` flag that distinguishes an unreachable backend from HTTP errors).
- Auth is Supabase email. The bearer token is injected automatically via the `api` client; never thread tokens through component props.

## Testing

**No frontend tests.** Do not write `*.test.ts` / `*.test.tsx` files or introduce a test runner. We verify the app manually on a device or simulator plus `pnpm tsc --noEmit` and `pnpm lint`. If you find yourself reaching for Jest, Detox, or Maestro — stop. That's not what this project does. Correctness for shared logic comes from keeping it simple and well-typed, not from a test suite.

## Anti-patterns (rejected)

- Reading `process.env.EXPO_PUBLIC_X` directly outside `lib/env.ts`.
- Importing an HTTP library when `fetch` would do.
- Using the built-in `fetch` for the chat stream instead of `expo/fetch`.
- Mixing client state libraries (Zustand + Jotai + Redux) for one project.
- `any` annotations to silence the type-checker.
- Styling or UI-kit libraries alongside `StyleSheet`.
- Hand-editing generated `ios/` or `android/` folders instead of using `app.json` / config plugins.
- API routes inside the app (Expo Router `+api` files) — FastAPI is the only backend.
