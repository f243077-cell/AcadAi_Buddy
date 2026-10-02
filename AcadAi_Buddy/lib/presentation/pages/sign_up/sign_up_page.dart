import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_notifier.dart';
import '../../../application/auth/auth_state.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../sign_in/widgets/auth_widgets.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _submitted = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    for (final f in [_emailFocus, _passwordFocus, _confirmFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  String? get _nameError =>
      _submitted && _name.text.trim().isEmpty ? 'Full name is required' : null;

  String? get _emailError => _submitted ? validateEmail(_email.text) : null;

  String? get _passwordError {
    if (!_submitted) return null;
    if (_password.text.isEmpty) return 'Password is required';
    if (_password.text.length < kMinPasswordLength) {
      return 'Use at least $kMinPasswordLength characters';
    }
    return null;
  }

  String? get _confirmError {
    if (!_submitted) return null;
    if (_confirm.text.isEmpty) return 'Please confirm your password';
    if (_confirm.text != _password.text) return 'Passwords do not match';
    return null;
  }

  bool get _valid =>
      _nameError == null &&
      _emailError == null &&
      _passwordError == null &&
      _confirmError == null;

  void _onEdited(String _) {
    ref.read(authNotifierProvider.notifier).clearError();
    setState(() {}); // strength meter and live validation
  }

  void _submit() {
    setState(() => _submitted = true);
    if (!_valid) return;
    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext();
    ref.read(authNotifierProvider.notifier).signUp(
          _email.text.trim(),
          _password.text,
          _name.text.trim(),
        );
  }

  void _toSignIn() {
    ref.read(authNotifierProvider.notifier).clearError();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final loading = auth is AuthLoading;
    final failure = auth is AuthFailureState ? auth.message : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to sign in',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: loading ? null : _toSignIn,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0,
                AppSpacing.screen, AppSpacing.screen),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Create your account', style: AppText.titleL),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Your chats and quiz results are saved to it.',
                      style: AppText.bodyM.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppTextField(
                      controller: _name,
                      label: 'Full name',
                      prefixIcon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      errorText: _nameError,
                      onChanged: _onEdited,
                      onSubmitted: (_) => _emailFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _email,
                      focusNode: _emailFocus,
                      label: 'Email',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      errorText: _emailError,
                      onChanged: _onEdited,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _password,
                      focusNode: _passwordFocus,
                      label: 'Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscure: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      errorText: _passwordError,
                      helperText: _passwordError == null
                          ? 'At least $kMinPasswordLength characters'
                          : null,
                      onChanged: _onEdited,
                      onSubmitted: (_) => _confirmFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PasswordStrengthMeter(password: _password.text),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _confirm,
                      focusNode: _confirmFocus,
                      label: 'Confirm password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      errorText: _confirmError,
                      onChanged: _onEdited,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (failure != null) ...[
                      AuthErrorBanner(message: failure),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    AppButton(
                      label: 'Create account',
                      loading: loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?',
                            style: AppText.bodyM
                                .copyWith(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: loading ? null : _toSignIn,
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
