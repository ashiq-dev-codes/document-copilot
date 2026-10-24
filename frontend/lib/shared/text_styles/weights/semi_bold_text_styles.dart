import 'package:flutter/material.dart';

import '../base/app_text_styles.dart';

class SemiBoldTextStyles extends AppTextStyles {
  const SemiBoldTextStyles();

  @override
  TextStyle textStyle({Color? color, double? size, String? fontFamily}) {
    return TextStyle(
      fontSize: size,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      color: color ?? Colors.black,
    );
  }
}
