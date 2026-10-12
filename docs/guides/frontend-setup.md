# Frontend setup

This project uses a React Native app built with Expo, so analysts can use Document Copilot on their phones (iOS and Android). Expo handles the native build tooling, which keeps the frontend focused on authenticated app flows and a clean connection to the FastAPI backend. All AI work happens in the backend; the app only signs in, sends questions and shows the streamed answers.

## Before you start

- Install the **Expo Go** app on your phone (App Store / Play Store), or set up an iOS Simulator (Xcode) or Android emulator (Android Studio).
- Your phone and computer must be on the same Wi-Fi network.

## Init (from `frontend/`)

```bash
cd frontend
pnpm create expo-app@latest .
pnpm expo install @supabase/supabase-js
pnpm add ai @ai-sdk/react
```

The default Expo template includes TypeScript and Expo Router. If `create-expo-app` refuses because the folder isn't empty, move `frontend/AGENTS.md` out temporarily and put it back afterwards.

Then follow Supabase's Expo guide: install the session storage package it uses and set up the client in `src/lib/supabase.ts`.

## Run

```bash
cd frontend
pnpm install
pnpm expo start
```

Scan the QR code with Expo Go, or press `i` (iOS Simulator) or `a` (Android emulator).

On a phone or emulator, `localhost` means the device itself. Set `EXPO_PUBLIC_API_BASE_URL` to your computer's network IP (for example `http://192.168.1.20:8000`), or `http://10.0.2.2:8000` on the Android emulator.

## Check

```bash
pnpm tsc --noEmit
pnpm lint
```
