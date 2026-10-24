import 'package:flutter/foundation.dart';

/// Pick with `--dart-define=ENV=production`.
enum Environment { local, production }

/// Pick with `--dart-define=DISTRIBUTION=firebase` for tester builds.
enum Distribution { store, firebase }

/// Every setting the app needs, in one place.
abstract final class AppConfig {
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

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.local:
        // Web and macOS run on this Mac; phones reach it by its Wi-Fi IP.
        return kIsWeb || defaultTargetPlatform == TargetPlatform.macOS
            ? 'http://localhost:8000'
            : 'http://192.168.2.30:8000';

      case Environment.production:
        throw StateError('Set the production API URL when deploying.');
    }
  }

  /// Tester release builds only; never in store builds or on web.
  static bool get isDevToolsEnabled =>
      distribution == Distribution.firebase && kReleaseMode && !kIsWeb;
}
