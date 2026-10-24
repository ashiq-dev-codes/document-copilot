/// Starts the app: connects Supabase, then shows the first screen.
library;

import 'package:device_preview/device_preview.dart';
import 'package:document_copilot/app.dart';
import 'package:document_copilot/core/config/config.dart';
import 'package:document_copilot/core/di.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Must run first: it sets up the app's binding. Debug builds only.
  DevicePreview.enable(enabled: kDebugMode);
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );
  setupDependencies();

  runApp(const App());
}
