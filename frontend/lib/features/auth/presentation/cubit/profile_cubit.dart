import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:document_copilot/features/auth/data/auth_repository.dart';
import 'package:document_copilot/features/auth/models/user_model.dart';
import 'package:document_copilot/shared/utils/exception/api_exception.dart';

part 'profile_state.dart';

/// Loads the signed-in user from our backend for the account page.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileLoading());

  final AuthRepository _repository;

  Future<void> load() async {
    emit(const ProfileLoading());
    try {
      emit(ProfileLoaded(await _repository.fetchCurrentUser()));
    } on ApiException catch (e) {
      emit(ProfileFailure(e.message));
    }
  }
}
