import 'package:flutter/material.dart';

/// Text styles by font weight: `AppText.medium.textStyle(size: AppFontSize.s16)`.
abstract final class AppText {
  static const regular = AppTextStyle(FontWeight.w400);
  static const medium = AppTextStyle(FontWeight.w500);
  static const semiBold = AppTextStyle(FontWeight.w600);
  static const bold = AppTextStyle(FontWeight.w700);
}

/// One font weight; [textStyle] builds the style with size, color and decoration.
class AppTextStyle {
  const AppTextStyle(this._weight);

  final FontWeight _weight;

  /// Leave [color] null to use the theme's text color (works in dark mode too).
  TextStyle textStyle({
    double? size,
    Color? color,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: _weight,
      color: color,
      decoration: decoration,
    );
  }
}
