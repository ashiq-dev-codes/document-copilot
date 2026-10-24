import 'package:corextra/corextra.dart';
import 'package:dio/dio.dart';
import 'package:document_copilot/core/config/config.dart';
import 'package:document_copilot/shared/utils/dio/app_interceptor.dart';
import 'package:flutter/foundation.dart';

/// Builds the one Dio client every feature uses to call our backend.
Dio createApiClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      // AI answers can take a while to finish streaming.
      receiveTimeout: const Duration(seconds: 120),
      contentType: Headers.jsonContentType,
    ),
  );

  dio.interceptors.addAll([
    AppInterceptor(dio),
    const AppLoggerInterceptor(enabled: kDebugMode),
    // Hides the token in the in-app network inspector.
    const CorextraDevToolsInterceptor(hiddenHeaders: {'Authorization'}),
  ]);

  return dio;
}
