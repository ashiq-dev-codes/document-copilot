import 'package:corextra/corextra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:document_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:document_copilot/shared/text_styles/app_font_size.dart';
import 'package:document_copilot/shared/text_styles/app_text.dart';
import 'package:document_copilot/shared/widgets/snackbar/custom_snack_bar.dart';

/// Email and password form to sign in or create an account.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit({required bool createAccount}) {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    final email = _email.text.trim();
    createAccount
        ? cubit.signUp(email, _password.text)
        : cubit.signIn(email, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthFailure) {
                    CustomSnackBar.error(context, state.message);
                  }
                },
                builder: (context, state) {
                  final busy = state is AuthSubmitting;
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Document Copilot',
                          textAlign: TextAlign.center,
                          style: AppText.bold.textStyle(size: AppFontSize.s28),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(LucideIcons.mail),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: FormValidators.email,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(LucideIcons.lock),
                          ),
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          validator: FormValidators.password,
                          onFieldSubmitted: (_) =>
                              _submit(createAccount: false),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: busy
                              ? null
                              : () => _submit(createAccount: false),
                          child: busy
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Sign in'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => _submit(createAccount: true),
                          child: const Text('Create account'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
