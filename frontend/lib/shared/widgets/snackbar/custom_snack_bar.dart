import 'package:flutter/material.dart';

/// The app's one snackbar style: `CustomSnackBar.error(context, e.message)`.
abstract final class CustomSnackBar {
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static void success(BuildContext context, String message) {
    show(context, message, backgroundColor: Colors.green.shade700);
  }

  /// Errors stay longer, so there's time to read them.
  static void error(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 6),
    );
  }
}
