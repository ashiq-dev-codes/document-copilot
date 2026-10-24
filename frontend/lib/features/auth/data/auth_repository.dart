import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:document_copilot/features/auth/models/user_model.dart';
import 'package:document_copilot/shared/utils/exception/api_exception.dart';

/// Signs users in and out with Supabase, and asks our backend who they are.
class AuthRepository {
  const AuthRepository(this._auth, this._api);

  final GoTrueClient _auth;
  final Dio _api;

  /// The signed-in user's email, or null when signed out.
  String? get currentEmail => _auth.currentUser?.email;

  /// Emits the user's email after signing in, and null after signing out.
  Stream<String?> get emailChanges =>
      _auth.onAuthStateChange.map((state) => state.session?.user.email);

  Future<void> signIn({required String email, required String password}) =>
      _run(() => _auth.signInWithPassword(email: email, password: password));

  Future<void> signUp({required String email, required String password}) =>
      _run(() => _auth.signUp(email: email, password: password));

  Future<void> signOut() => _run(_auth.signOut);

  /// `GET /auth/me`: our backend checks the token with Supabase and returns the user.
  Future<UserModel> fetchCurrentUser() async {
    try {
      final response = await _api.get<Map<String, dynamic>>('/auth/me');
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // Turns Supabase's errors into the app's one error type.
  Future<void> _run(Future<Object?> Function() action) async {
    try {
      await action();
    } on AuthException catch (e) {
      throw ApiException(e.message);
    }
  }
}
