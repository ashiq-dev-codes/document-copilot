import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_template/shared/theme/app_colors.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    this.borderColor,
    this.height = 55,
    required this.child,
    this.isLoading = false,
    required this.onPressed,
  });
  final Widget child;
  final double height;
  final bool isLoading;
  final Color? borderColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 555),
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(5),
          ),
          side: BorderSide(
            width: 1,
            color: onPressed == null
                ? Colors.grey.shade300
                : borderColor ?? AppColors.primary,
          ),
        ),
        child: isLoading ? CupertinoActivityIndicator(radius: 7) : child,
      ),
    );
  }
}
