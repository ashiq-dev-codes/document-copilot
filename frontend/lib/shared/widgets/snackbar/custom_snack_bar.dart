import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(
    BuildContext context,
    String title, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 1,
        duration: duration,
        content: Text(title),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  static void message(BuildContext context, String title) {
    show(context, title, duration: const Duration(seconds: 5));
  }

  static void success(BuildContext context, String title) {
    show(context, title, backgroundColor: Colors.green);
  }

  static void error(BuildContext context, String title) {
    show(
      context,
      title,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 7),
    );
  }
}
