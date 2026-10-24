part of 'profile_cubit.dart';

/// The account page's data from `GET /auth/me`.
sealed class ProfileState {
  const ProfileState();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);

  final UserModel user;
}

/// The backend call failed; [message] is ready to show the user.
final class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message);

  final String message;
}
