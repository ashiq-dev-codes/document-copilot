import 'package:flutter/material.dart';

import '../base/app_text_styles.dart';

class ExtraBoldTextStyles extends AppTextStyles {
  const ExtraBoldTextStyles();

  @override
  TextStyle textStyle({Color? color, double? size, String? fontFamily}) {
    return TextStyle(
      fontSize: size,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w800,
      color: color ?? Colors.black,
    );
  }
}
