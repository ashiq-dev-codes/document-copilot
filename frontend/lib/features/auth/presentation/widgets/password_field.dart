import 'package:corextra/corextra.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A password input with a show/hide toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.helperText,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final String? helperText;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      autofillHints: const [AutofillHints.password],
      textInputAction: TextInputAction.done,
      validator: FormValidators.password,
      onFieldSubmitted: (_) => widget.onSubmitted(),
      decoration: InputDecoration(
        labelText: 'Password',
        helperText: widget.helperText,
        prefixIcon: const Icon(LucideIcons.lockKeyhole),
        suffixIcon: IconButton(
          tooltip: _hidden ? 'Show password' : 'Hide password',
          icon: Icon(_hidden ? LucideIcons.eye : LucideIcons.eyeOff),
          onPressed: () => setState(() => _hidden = !_hidden),
        ),
      ),
    );
  }
}
