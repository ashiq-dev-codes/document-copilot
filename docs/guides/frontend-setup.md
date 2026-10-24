# Frontend setup

This project uses a Flutter app for every Flutter platform (iOS, Android, web, macOS, Windows, Linux); the pilot ships iOS and Android. All AI work happens in the backend; the app only signs in, sends questions and shows the streamed answers with their citations.

## Init (from `frontend/`)

```bash
cd frontend
flutter create . --project-name document_copilot --org com.documentcopilot --platforms ios,android,web,macos,windows,linux
flutter pub add flutter_bloc get_it dio supabase_flutter
```

The app ID is `com.documentcopilot.app` and the display name is "Document Copilot" on every platform. `flutter create` generates its own defaults, so they were changed by hand once in: `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner.xcodeproj/project.pbxproj`, `macos/Runner/Configs/AppInfo.xcconfig`, `macos/Runner.xcodeproj/project.pbxproj`, `linux/CMakeLists.txt`, `windows/runner/Runner.rc`, `web/index.html` and `web/manifest.json`. If you add a platform later, set the same values there. The Dart package name stays `document_copilot`.

## Settings

All settings live in `lib/core/config/config.dart` (`AppConfig`):

- **Backend URL per environment.** `local` is your Mac's network IP, because on a phone or emulator `localhost` means the device itself (use `http://10.0.2.2:8000` on the Android emulator). Update it if your Mac's IP changes. `production` is added when the backend is deployed.
- **Supabase URL and publishable key.** Both are public by design and safe to commit; the tables are protected by RLS. Never put a secret key in the app.

## Run

```bash
cd frontend
flutter run                                  # local backend
flutter run --dart-define=ENV=production     # deployed backend (after Phase 10)
```

## Check

```bash
flutter analyze
```
