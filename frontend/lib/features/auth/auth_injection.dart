import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:document_copilot/features/auth/data/auth_repository.dart';
import 'package:document_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:document_copilot/features/auth/presentation/cubit/profile_cubit.dart';

/// Registers the auth feature.
void initAuthInjection(GetIt sl) {
  sl.registerLazySingleton(
    () => AuthRepository(Supabase.instance.client.auth, sl()),
  );

  // App-wide: the auth gate needs it everywhere.
  sl.registerLazySingleton(() => AuthCubit(sl()));

  // Screen Cubit: a fresh one each time the account page opens.
  sl.registerFactory(() => ProfileCubit(sl()));
}
