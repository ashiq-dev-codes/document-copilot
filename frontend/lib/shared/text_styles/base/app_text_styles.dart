import 'package:flutter/material.dart';

abstract class AppTextStyles {
  const AppTextStyles();

  /// Generate a TextStyle
  TextStyle textStyle({Color? color, double? size, String? fontFamily});
}
