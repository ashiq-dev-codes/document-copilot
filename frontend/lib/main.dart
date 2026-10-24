/// Starts the app: connects Supabase, registers dependencies, then shows the app.
library;

import 'package:device_preview/device_preview.dart';
import 'package:document_copilot/core/config/config.dart';
import 'package:document_copilot/injection_container.dart';
import 'package:document_copilot/root.dart';
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
  initDependencies();

  runApp(const AppRoot());
}
