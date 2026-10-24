# Frontend setup

This project uses a Flutter app, so analysts can use Document Copilot on their phones and tablets (iOS and Android). All AI work happens in the backend; the app only signs in, sends questions and shows the streamed answers with their citations.

## Init (from `frontend/`)

```bash
cd frontend
flutter create . --project-name document_copilot --org com.documentcopilot --platforms ios,android,web,macos,windows,linux
flutter pub add flutter_bloc get_it dio supabase_flutter
```

`flutter create .` adds the project files around the existing `AGENTS.md`, `env.json` and `env.example.json`.

The app ID is `com.documentcopilot.app` and the display name is "Document Copilot" on every platform. `flutter create` generates its own defaults, so they were changed by hand once in: `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner.xcodeproj/project.pbxproj`, `macos/Runner/Configs/AppInfo.xcconfig`, `macos/Runner.xcodeproj/project.pbxproj`, `linux/CMakeLists.txt`, `windows/runner/Runner.rc`, `web/index.html` and `web/manifest.json`. If you add a platform later, set the same values there. The Dart package name stays `document_copilot`.

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
