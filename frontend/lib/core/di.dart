import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:document_copilot/core/network/api_client.dart';

/// The app-wide service locator.
final sl = GetIt.instance;

/// Registers shared services. Each feature adds its repositories and Cubits here.
void setupDependencies() {
  sl.registerLazySingleton<Dio>(createApiClient);
}
