import 'package:corextra/corextra.dart';
import 'package:dio/dio.dart';

/// A failed backend call, with a message that is safe to show the user.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  /// Uses the backend's `{"detail": "..."}` message when there is one,
  /// otherwise a friendly message for network problems (timeouts, no connection).
  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    final detail = data is Map ? data['detail'] : null;
    return ApiException(
      detail is String ? detail : DioErrorHandler.getErrorMessage(error),
      statusCode: error.response?.statusCode,
    );
  }

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
