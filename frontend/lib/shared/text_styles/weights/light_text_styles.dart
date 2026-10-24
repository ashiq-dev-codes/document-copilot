import 'package:flutter/material.dart';

import '../base/app_text_styles.dart';

class LightTextStyles extends AppTextStyles {
  const LightTextStyles();

  @override
  TextStyle textStyle({Color? color, double? size, String? fontFamily}) {
    return TextStyle(
      fontSize: size,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w300,
      color: color ?? Colors.black,
    );
  }
}
