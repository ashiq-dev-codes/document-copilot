import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authorization token to request headers if available
    if (AppConfig.token != null) {
      // Log request token
      debugLog('onRequest Token: ${AppConfig.token}');
      options.headers['Authorization'] = 'Bearer ${AppConfig.token}';
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      final token = data['token'] ?? (nested is Map ? nested['token'] : null);
      if (token != null) {
        final tokenString = token.toString();
        AppConfig.token = tokenString;
        await AppStorage.setToken(tokenString);

        debugLog('onResponse Token: ${AppConfig.token}');
      }
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Reports the error to Sentry
    SentryTracker.recordDioError(err);

    if (err.response != null) {
      final response = err.response!;
      final responseData = response.data;
      final responseStatusCode = response.statusCode;
      final requestPath = response.requestOptions.path;

      // Session errors are matched by message, but only on 401/403: a 404
      // like "Booking not found or unauthorized." must not log the user out.
      if (!requestPath.contains('autoLogin') &&
          (responseStatusCode == 401 || responseStatusCode == 403)) {
        switch (ApiErrorEnum.fromMessage(_errorText(responseData))) {
          case ApiErrorEnum.inactiveUser:
            DioExtras.handleInactiveUser();

          case ApiErrorEnum.unauthorized:
            DioExtras.refreshToken();

          case null:
            break;
        }
      }

      // Handle different error statuses and throw appropriate exceptions
      String errorMessage =
          err.error?.toString() ??
          'An unexpected error occurred. Please contact the admin for assistance';

      if (responseStatusCode == null) throw errorMessage;

      // Extract relevant data from the response
      dynamic message = (responseData is Map)
          ? _extractErrorMessage(responseData) ??
                response.statusMessage ??
                err.message
          : null;

      switch (responseStatusCode) {
        case 400:
          // Special case for program enrollment
          if (requestPath.contains(
                'mob_app/auth/program_enrollment/createUpdate',
              ) ==
              true) {
            final unavailable = responseData['errors']?['unavailable'];
            if (unavailable is List && unavailable.isNotEmpty) {
              _throwCustomDioError(
                err,
                response,
                unavailable.firstOrNull?['reason']?.toString() ??
                    message ??
                    'We couldn’t process your request. Please try again.',
              );
            }
            _throwCustomDioError(
              err,
              response,
              message ?? 'We couldn’t process your request. Please try again.',
            );
          } else {
            _throwCustomDioError(
              err,
              response,
              message ?? 'We couldn’t process your request. Please try again.',
            );
          }

          _throwCustomDioError(
            err,
            response,
            message ?? 'We couldn’t process your request. Please try again.',
          );
        case 401:
          _throwCustomDioError(
            err,
            response,
            message ?? 'You are not authorized. Please login to continue.',
          );
        case 403:
          _throwCustomDioError(
            err,
            response,
            message ?? 'Access denied. You don’t have permission to perform this action.',
          );
        case 404:
          _throwCustomDioError(
            err,
            response,
            message ?? 'The requested item could not be found.',
          );
        case 413:
          _throwCustomDioError(err, response, message ?? 'Payload Too Large');
        case 422:
          _throwCustomDioError(
            err,
            response,
            message ?? 'Some details are missing or incorrect. Please review and submit again.',
          );
        default:
          if (responseStatusCode >= 500) {
            _throwCustomDioError(err, response, 'Internal Server Error');
          }
          _throwCustomDioError(err, response, message ?? errorMessage);
      }
    } else {
      // No response, handle Dio-specific errors
      DioErrorHandler.handleError(err);
    }

    super.onError(err, handler);
  }
}

dynamic _extractErrorMessage(Map responseData) {
  // Step 1: attempt to get the most relevant error message field
  var responseMessage =
      responseData['message'] ??
      responseData['data'] ??
      responseData['error'] ??
      responseData['detail'];

  // If the message itself is a Map, extract its 'message' field
  if (responseMessage is Map) {
    responseMessage = responseMessage['message'] ?? responseMessage.toString();
  }

  // Step 2: handle validation-style "errors" field
  if (responseData['errors'] != null) {
    final errors = responseData['errors'];

    if (errors is Map) {
      final messages = <String>[];

      errors.forEach((_, value) {
        if (value is List) {
          messages.addAll(value.map((e) => e.toString()));
        } else if (value != null) {
          messages.add(value.toString());
        }
      });

      if (messages.isNotEmpty) {
        // Prefer user-friendly messages over raw responseMessage
        return messages.join("\n");
      }
    }

    if (errors is String) {
      return errors;
    }
  }

  // Step 3: Default fallback to the original response message
  return responseMessage?.toString();
}

/// Joins every field a backend may put an error message in; tolerates
/// plain-text bodies, which a `Map` lookup would crash on.
String _errorText(dynamic responseData) {
  if (responseData is String) return responseData;
  if (responseData is! Map) return '';

  final nested = responseData['data'];
  return [
    responseData['message'],
    responseData['error'],
    responseData['detail'],
    if (nested is Map) nested['message'],
    if (nested is String) nested,
  ].whereType<Object>().join(' ');
}

/// Provides a default error message for DioException.
void _throwCustomDioError(
  DioException err,
  Response response,
  Object errorMessage,
) {
  final responseData = response.data;
  throw DioException(
    type: err.type,
    error: errorMessage,
    requestOptions: err.requestOptions,
    response: Response(
      statusCode: response.statusCode,
      requestOptions: response.requestOptions,
      data: responseData is Map ? responseData : null,
    ),
  );
}

extension DioMessage on DioException {
  String get dioMessage => (error == null
      ? "An unexpected error occurred. Please contact the admin for assistance"
      : (error.toString()));
}
