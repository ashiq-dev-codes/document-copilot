import 'package:flutter/material.dart';

import 'package:document_copilot/app.dart';

/// Everything wrapped around the app: app-wide behaviour and, per feature, its Cubits.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tapping outside a text field closes the keyboard, on every page.
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: const App(),
    );
  }
}
