import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:document_copilot/shared/constant/constant.dart';
import 'package:document_copilot/shared/text_styles/app_text.dart';
import 'package:document_copilot/shared/text_styles/sizes/app_font_size.dart';

/// The brand mark, a title and one line about the app, at the top of the auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            LucideIcons.fileSearch,
            size: 30,
            color: colors.onPrimaryContainer,
          ),
        ),
        kHeight25,
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.bold.textStyle(size: AppFontSize.s24),
        ),
        kHeight10,
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppText.regular.textStyle(
            size: AppFontSize.s14,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
