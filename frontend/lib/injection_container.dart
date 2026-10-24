import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:document_copilot/core/network/api_client.dart';
import 'package:document_copilot/features/auth/auth_injection.dart';

/// The app-wide service locator.
final sl = GetIt.instance;

/// Registers shared services, then each feature's own dependencies.
void initDependencies() {
  // Shared
  sl.registerLazySingleton<Dio>(createApiClient);

  // Features
  initAuthInjection(sl);
}
