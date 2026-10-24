import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.bgColor,
    this.height = 55,
    required this.child,
    this.isLoading = false,
    required this.onPressed,
  });
  final Widget child;
  final double height;
  final bool isLoading;
  final Color? bgColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 555),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: bgColor),
        child: isLoading ? CupertinoActivityIndicator(radius: 7) : child,
      ),
    );
  }
}
