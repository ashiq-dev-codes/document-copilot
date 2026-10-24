import 'package:flutter/material.dart';

import '../base/app_text_styles.dart';

class ExtraLightTextStyles extends AppTextStyles {
  const ExtraLightTextStyles();

  @override
  TextStyle textStyle({Color? color, double? size, String? fontFamily}) {
    return TextStyle(
      fontSize: size,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w100,
      color: color ?? Colors.black,
    );
  }
}
