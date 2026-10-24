import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Connects every backend request to the signed-in user and recovers from expired sessions.
class AppInterceptor extends Interceptor {
  AppInterceptor(this._dio);

  // Used to retry a request once after refreshing the session.
  final Dio _dio;

  static const _retriedKey = 'retried_after_refresh';

  GoTrueClient get _auth => Supabase.instance.client.auth;

  /// Adds the Supabase token that the backend's `CurrentUserDep` checks.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _auth.currentSession?.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// On 401, refreshes the session and retries once; if that fails, signs out.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    // Already retried with a fresh token and still refused: the session is gone.
    if (err.requestOptions.extra[_retriedKey] == true) {
      await _signOut();
      return handler.next(err);
    }

    try {
      await _auth.refreshSession();
    } on AuthException {
      await _signOut();
      return handler.next(err);
    }

    err.requestOptions.extra[_retriedKey] = true;
    try {
      // Goes through onRequest again, so the fresh token is attached.
      handler.resolve(await _dio.fetch(err.requestOptions));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  // AuthCubit listens to Supabase, so signing out shows the sign-in page.
  Future<void> _signOut() async {
    try {
      await _auth.signOut();
    } on AuthException {
      // Already signed out on the server; the local session is cleared anyway.
    }
  }
}
