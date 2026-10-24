import 'package:flutter/material.dart';

import '../base/app_text_styles.dart';

class BlackTextStyles extends AppTextStyles {
  const BlackTextStyles();

  @override
  TextStyle textStyle({Color? color, double? size, String? fontFamily}) {
    return TextStyle(
      fontSize: size,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w900,
      color: color ?? Colors.black,
    );
  }
}
