import 'package:flutter/material.dart';

import '../base/app_text_styles.dart';

class ThinTextStyles extends AppTextStyles {
  const ThinTextStyles();

  @override
  TextStyle textStyle({Color? color, double? size, String? fontFamily}) {
    return TextStyle(
      fontSize: size,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w200,
      color: color ?? Colors.black,
    );
  }
}
