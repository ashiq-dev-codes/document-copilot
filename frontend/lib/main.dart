/// Starts the app: connects Supabase, then shows the first screen.
library;

import 'package:document_copilot/app.dart';
import 'package:document_copilot/core/config/config.dart';
import 'package:document_copilot/core/di.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );
  setupDependencies();

  runApp(const App());
}
