/// App settings: which backend to call and the Supabase project to sign in with.
library;

import 'package:flutter/foundation.dart';

/// Which backend the app talks to. Pick one with `--dart-define=ENV=production`.
enum Environment { local, production }

/// Who the build is for. Pick one with `--dart-define=DISTRIBUTION=firebase`.
enum Distribution {
  /// App Store / Play Store builds for real users (the default).
  store,

  /// Firebase App Distribution builds for testers.
  firebase,
}

/// Every setting the app needs, in one place.
abstract final class AppConfig {
  // The publishable key is meant to ship inside apps; the tables are protected by RLS.
  static const supabaseUrl = 'https://nkhwcvjauhzmdsdphvqw.supabase.co';
  static const supabasePublishableKey =
      'sb_publishable_87DQChhVoWpOGLzgbCFYOw_xaK89bV_';

  static const _env = String.fromEnvironment('ENV', defaultValue: 'local');

  static const _distribution = String.fromEnvironment(
    'DISTRIBUTION',
    defaultValue: 'store',
  );

  static Environment get environment => Environment.values.byName(_env);

  static Distribution get distribution =>
      Distribution.values.byName(_distribution);

  /// corextra's in-app network and log inspector, ZERO.40 style: only in release
  /// tester builds (store builds never show it), and never on web, where the
  /// browser's own DevTools already show network calls and logs.
  static bool get isDevToolsEnabled =>
      kReleaseMode && distribution == Distribution.firebase && !kIsWeb;

  static String get apiBaseUrl => switch (environment) {
    Environment.local => _localApiUrl,
    Environment.production => throw StateError(
      'Production API URL is added when the backend is deployed (Phase 10).',
    ),
  };

  // Web and desktop run on this Mac, so localhost always works there. A phone or
  // tablet needs the Mac's Wi-Fi IP (update it when you change networks).
  static String get _localApiUrl =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.macOS
      ? 'http://localhost:8000'
      : 'http://192.168.2.30:8000';
}
