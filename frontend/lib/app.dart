import 'package:corextra/corextra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:document_copilot/core/config/config.dart';
import 'package:document_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:document_copilot/features/auth/presentation/pages/account_page.dart';
import 'package:document_copilot/features/auth/presentation/pages/sign_in_page.dart';

/// The MaterialApp: theme, debug inspector, and the auth gate as the first page.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Copilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      // A floating button opens corextra's network and log inspector (see AppConfig).
      builder: (context, child) => CorextraDevToolsOverlay(
        enabled: AppConfig.isDevToolsEnabled,
        child: child!,
      ),
      home: const _AuthGate(),
    );
  }
}

/// Shows the signed-in pages or the sign-in page, and switches when that changes.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      // Only rebuild when signed-in vs signed-out flips, not on every state.
      buildWhen: (previous, current) =>
          (previous is AuthSignedIn) != (current is AuthSignedIn),
      builder: (context, state) => switch (state) {
        AuthSignedIn(:final email) => AccountPage(email: email),
        _ => const SignInPage(),
      },
    );
  }
}
