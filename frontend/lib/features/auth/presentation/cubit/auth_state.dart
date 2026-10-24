part of 'auth_cubit.dart';

/// Where the user is in signing in.
sealed class AuthState {
  const AuthState();
}

/// Not signed in: the sign-in page is shown.
final class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

/// A sign-in, sign-up or sign-out request is running.
final class AuthSubmitting extends AuthState {
  const AuthSubmitting();
}

/// Signed in as [email].
final class AuthSignedIn extends AuthState {
  const AuthSignedIn(this.email);

  final String email;
}

/// The last request failed; [message] is ready to show the user.
final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;
}
