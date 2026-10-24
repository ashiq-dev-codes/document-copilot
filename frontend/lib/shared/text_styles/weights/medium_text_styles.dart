import 'package:flutter/material.dart';

import '../base/app_text_styles.dart';

class MediumTextStyles extends AppTextStyles {
  const MediumTextStyles();

  @override
  TextStyle textStyle({Color? color, double? size, String? fontFamily}) {
    return TextStyle(
      fontSize: size,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      color: color ?? Colors.black,
    );
  }
}
