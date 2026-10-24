import 'package:flutter/material.dart';

import '../base/app_text_styles.dart';

class BoldTextStyles extends AppTextStyles {
  const BoldTextStyles();

  @override
  TextStyle textStyle({Color? color, double? size, String? fontFamily}) {
    return TextStyle(
      fontSize: size,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      color: color ?? Colors.black,
    );
  }
}
