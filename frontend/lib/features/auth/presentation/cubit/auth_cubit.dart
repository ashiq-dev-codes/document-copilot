import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:document_copilot/core/network/api_exception.dart';
import 'package:document_copilot/features/auth/data/auth_repository.dart';

part 'auth_state.dart';

/// The app-wide sign-in state. Follows Supabase, so a saved session signs in on launch.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(_stateFor(_repository.currentEmail)) {
    _subscription = _repository.emailChanges.listen(
      (email) => emit(_stateFor(email)),
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<String?> _subscription;

  Future<void> signIn(String email, String password) =>
      _submit(() => _repository.signIn(email: email, password: password));

  Future<void> signUp(String email, String password) =>
      _submit(() => _repository.signUp(email: email, password: password));

  Future<void> signOut() => _submit(_repository.signOut);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }

  // On success, emailChanges emits the new state; only failures are emitted here.
  Future<void> _submit(Future<void> Function() action) async {
    emit(const AuthSubmitting());
    try {
      await action();
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    }
  }

  static AuthState _stateFor(String? email) =>
      email == null ? const AuthSignedOut() : AuthSignedIn(email);
}
