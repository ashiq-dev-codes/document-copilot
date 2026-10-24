import 'package:flutter/material.dart';

import '../base/app_text_styles.dart';

class RegularTextStyles extends AppTextStyles {
  const RegularTextStyles();

  @override
  TextStyle textStyle({Color? color, double? size, String? fontFamily}) {
    return TextStyle(
      fontSize: size,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      color: color ?? Colors.black,
    );
  }
}
