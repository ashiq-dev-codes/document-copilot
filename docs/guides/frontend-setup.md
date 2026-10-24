# Frontend setup

This project uses a Flutter app, so analysts can use Document Copilot on their phones and tablets (iOS and Android). All AI work happens in the backend; the app only signs in, sends questions and shows the streamed answers with their citations.

## Init (from `frontend/`)

```bash
cd frontend
flutter create . --project-name document_copilot --org com.documentcopilot --platforms ios,android
flutter pub add flutter_bloc get_it dio supabase_flutter
```

`flutter create .` adds the project files around the existing `AGENTS.md`, `env.json` and `env.example.json`.

The app ID is `com.documentcopilot.app` on both platforms (Android `applicationId` in `android/app/build.gradle.kts`, iOS bundle identifier in Xcode). `flutter create` generates `com.documentcopilot.document_copilot`, so it was changed by hand once; the Dart package name stays `document_copilot`.

## Settings

Copy `env.example.json` to `env.json` (gitignored) and fill in the values:

```json
{
  "API_BASE_URL": "http://192.168.1.20:8000",
  "SUPABASE_URL": "https://your-project-ref.supabase.co",
  "SUPABASE_ANON_KEY": "your-publishable-key"
}
```

On a phone or emulator, `localhost` means the device itself. Set `API_BASE_URL` to your computer's network IP, or `http://10.0.2.2:8000` on the Android emulator.

## Run

```bash
cd frontend
flutter run --dart-define-from-file=env.json
```

## Check

```bash
flutter analyze
```
