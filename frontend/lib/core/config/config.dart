/// App settings: which backend to call and the Supabase project to sign in with.
library;

/// Which backend the app talks to. Pick one with `--dart-define=ENV=production`.
enum Environment { local, production }

/// Every setting the app needs, in one place.
abstract final class AppConfig {
  static const _env = String.fromEnvironment('ENV', defaultValue: 'local');

  static Environment get environment => Environment.values.byName(_env);

  static String get apiBaseUrl => switch (environment) {
    // Your Mac's Wi-Fi IP: on a phone, localhost would mean the phone itself.
    Environment.local => 'http://192.168.100.162:8000',
    Environment.production => throw StateError(
      'Production API URL is added when the backend is deployed (Phase 10).',
    ),
  };

  // The publishable key is meant to ship inside apps; the tables are protected by RLS.
  static const supabaseUrl = 'https://nkhwcvjauhzmdsdphvqw.supabase.co';
  static const supabaseAnonKey =
      'sb_publishable_87DQChhVoWpOGLzgbCFYOw_xaK89bV_';
}
