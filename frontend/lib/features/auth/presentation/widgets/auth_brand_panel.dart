import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:document_copilot/shared/constant/constant.dart';
import 'package:document_copilot/shared/text_styles/app_text.dart';
import 'package:document_copilot/shared/text_styles/sizes/app_font_size.dart';

/// The left side of the auth screens on wide layouts: what the app is and why to use it.
class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final onBrand = colors.onPrimary;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.tertiary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.fileSearch, color: onBrand, size: 26),
              kWidth10,
              Text(
                'Document Copilot',
                style: AppText.semiBold.textStyle(
                  size: AppFontSize.s18,
                  color: onBrand,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Research company filings in minutes, not hours.',
            style: AppText.bold.textStyle(
              size: AppFontSize.s40,
              color: onBrand,
            ),
          ),
          kHeight20,
          Text(
            'Ask in plain English. Get answers straight from the 10-Ks, '
            'with the source page for every claim.',
            style: AppText.regular.textStyle(
              size: AppFontSize.s16,
              color: onBrand.withValues(alpha: 0.85),
            ),
          ),
          kHeight40,
          _Feature(
            icon: LucideIcons.zap,
            text: 'Answers in seconds, not hours of reading',
            color: onBrand,
          ),
          kHeight15,
          _Feature(
            icon: LucideIcons.messageSquareQuote,
            text: 'Every claim cites its filing and page',
            color: onBrand,
          ),
          kHeight15,
          _Feature(
            icon: LucideIcons.shieldCheck,
            text: "Says so when the filings don't have the answer",
            color: onBrand,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// One reason to use the app: an icon in a soft circle and a short line.
class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        kWidth15,
        Expanded(
          child: Text(
            text,
            style: AppText.medium.textStyle(
              size: AppFontSize.s16,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
