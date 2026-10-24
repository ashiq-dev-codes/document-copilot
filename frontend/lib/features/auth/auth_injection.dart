import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:document_copilot/features/auth/data/auth_repository.dart';
import 'package:document_copilot/features/auth/presentation/cubit/auth_cubit.dart';

/// Registers the auth feature. AuthCubit is app-wide, so it is a singleton.
void initAuthInjection(GetIt sl) {
  sl.registerLazySingleton(() => AuthRepository(Supabase.instance.client.auth));
  sl.registerLazySingleton(() => AuthCubit(sl()));
}
