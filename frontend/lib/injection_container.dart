import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:document_copilot/core/network/api_client.dart';

/// The app-wide service locator.
final sl = GetIt.instance;

/// Registers shared services, then each feature's own dependencies.
void initDependencies() {
  // Shared
  sl.registerLazySingleton<Dio>(createApiClient);

  // Features: add `init<Name>Injection(sl);` for each feature.
}
