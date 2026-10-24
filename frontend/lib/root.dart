import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:document_copilot/app.dart';
import 'package:document_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:document_copilot/injection_container.dart';

/// Everything wrapped around the app: app-wide behaviour and app-wide Cubits.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // .value: get_it owns these singletons, so the provider must not close them.
      providers: [BlocProvider<AuthCubit>.value(value: sl<AuthCubit>())],
      child: GestureDetector(
        // Tapping outside a text field closes the keyboard, on every page.
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: const App(),
      ),
    );
  }
}
