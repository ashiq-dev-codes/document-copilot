import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:document_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:document_copilot/shared/text_styles/app_font_size.dart';
import 'package:document_copilot/shared/text_styles/app_text.dart';

/// Shows who is signed in, with a sign-out button.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Copilot'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(LucideIcons.logOut),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Signed in as $email',
          style: AppText.medium.textStyle(size: AppFontSize.s16),
        ),
      ),
    );
  }
}
