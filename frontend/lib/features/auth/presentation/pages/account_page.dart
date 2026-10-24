import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:document_copilot/features/auth/models/user_model.dart';
import 'package:document_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:document_copilot/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:document_copilot/injection_container.dart';
import 'package:document_copilot/shared/constant/constant.dart';
import 'package:document_copilot/shared/text_styles/app_text.dart';
import 'package:document_copilot/shared/text_styles/sizes/app_font_size.dart';

/// Shows the signed-in user as our backend sees them, with a sign-out button.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..load(),
      child: Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) => switch (state) {
                ProfileLoading() => const CircularProgressIndicator(),
                ProfileLoaded(:final user) => _ProfileCard(user: user),
                ProfileFailure(:final message) => _LoadError(message: message),
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The user's email and id, with a badge showing the backend confirmed them.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: colors.primaryContainer,
          child: Text(
            user.email[0].toUpperCase(),
            style: AppText.bold.textStyle(
              size: AppFontSize.s30,
              color: colors.onPrimaryContainer,
            ),
          ),
        ),
        kHeight20,
        Text(
          user.email,
          style: AppText.semiBold.textStyle(size: AppFontSize.s18),
        ),
        kHeight10,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.badgeCheck, size: 18, color: colors.primary),
            kWidth5,
            Text(
              'Verified by the Document Copilot backend',
              style: AppText.medium.textStyle(
                size: AppFontSize.s14,
                color: colors.primary,
              ),
            ),
          ],
        ),
        kHeight5,
        Text(
          'User ID ${user.id}',
          style: AppText.regular.textStyle(
            size: AppFontSize.s12,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Why loading failed, with a retry button.
class _LoadError extends StatelessWidget {
  const _LoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          LucideIcons.cloudOff,
          size: 40,
          color: Theme.of(context).colorScheme.error,
        ),
        kHeight15,
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppText.medium.textStyle(size: AppFontSize.s16),
        ),
        kHeight15,
        FilledButton.tonal(
          onPressed: () => context.read<ProfileCubit>().load(),
          child: const Text('Try again'),
        ),
      ],
    );
  }
}
