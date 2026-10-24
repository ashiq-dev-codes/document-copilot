import 'package:corextra/corextra.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:document_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:document_copilot/features/auth/presentation/widgets/auth_header.dart';
import 'package:document_copilot/features/auth/presentation/widgets/auth_layout.dart';
import 'package:document_copilot/features/auth/presentation/widgets/password_field.dart';
import 'package:document_copilot/shared/constant/constant.dart';
import 'package:document_copilot/shared/text_styles/app_text.dart';
import 'package:document_copilot/shared/text_styles/sizes/app_font_size.dart';
import 'package:document_copilot/shared/widgets/snackbar/custom_snack_bar.dart';

/// Sign in, or switch to creating an account, with email and password.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isCreatingAccount = false;

  @override
  void initState() {
    super.initState();
    // Debug builds start with the shared test account, so signing in is one click.
    if (kDebugMode) {
      _email.text = 'ashiq.dev.codes+copilot-test@gmail.com';
      _password.text = 'Test-cVUre2Kzv99n';
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();
    final email = _email.text.trim();
    _isCreatingAccount
        ? cubit.signUp(email, _password.text)
        : cubit.signIn(email, _password.text);
  }

  void _toggleMode() {
    _formKey.currentState?.reset();
    setState(() => _isCreatingAccount = !_isCreatingAccount);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
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
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthHeader(
                    title: _isCreatingAccount
                        ? 'Create your account'
                        : 'Welcome back',
                    subtitle: _isCreatingAccount
                        ? 'Start asking questions about company filings.'
                        : 'Sign in to continue your research.',
                  ),
                  kHeight30,
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: FormValidators.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@company.com',
                      prefixIcon: Icon(LucideIcons.mail),
                    ),
                  ),
                  kHeight15,
                  PasswordField(
                    controller: _password,
                    onSubmitted: _submit,
                    helperText: _isCreatingAccount
                        ? 'At least 6 characters'
                        : null,
                  ),
                  kHeight25,
                  FilledButton(
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(
                            _isCreatingAccount ? 'Create account' : 'Sign in',
                          ),
                  ),
                  kHeight15,
                  _ModeSwitch(
                    isCreatingAccount: _isCreatingAccount,
                    onPressed: busy ? null : _toggleMode,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// "New here? Create an account" / "Already have an account? Sign in".
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.isCreatingAccount, required this.onPressed});

  final bool isCreatingAccount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          isCreatingAccount ? 'Already have an account?' : 'New here?',
          style: AppText.regular.textStyle(
            size: AppFontSize.s14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(isCreatingAccount ? 'Sign in' : 'Create an account'),
        ),
      ],
    );
  }
}
