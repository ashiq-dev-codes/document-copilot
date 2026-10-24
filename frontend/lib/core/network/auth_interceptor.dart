import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Adds the signed-in user's Supabase token to every backend request.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // supabase_flutter refreshes the session itself, so this is always the current token.
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
