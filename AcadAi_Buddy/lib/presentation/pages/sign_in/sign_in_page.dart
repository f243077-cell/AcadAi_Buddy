import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_notifier.dart';
import '../../../application/auth/auth_state.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_snack.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/logo_mark.dart';
import 'widgets/auth_widgets.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _submitted = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? get _emailError => _submitted ? validateEmail(_email.text) : null;
  String? get _passwordError =>
      _submitted && _password.text.isEmpty ? 'Password is required' : null;

  void _onEdited(String _) {
    ref.read(authNotifierProvider.notifier).clearError();
    if (_submitted) setState(() {});
  }

  void _submit() {
    setState(() => _submitted = true);
    if (_emailError != null || _passwordError != null) return;
    FocusScope.of(context).unfocus();
    TextInput.finishAutofillContext();
    ref
        .read(authNotifierProvider.notifier)
        .signIn(_email.text.trim(), _password.text);
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _email.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (context) => _ResetDialog(controller: controller),
    );
    controller.dispose();
    if (email == null || !mounted) return;

    final result =
        await ref.read(authNotifierProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    result.fold(
      (f) => AppSnack.show(context, f.message, tone: SnackTone.error),
      (_) => AppSnack.show(
        context,
        'If an account exists for $email, a reset link is on its way.',
        tone: SnackTone.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final loading = auth is AuthLoading;
    final failure = auth is AuthFailureState ? auth.message : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(AppSpacing.screen),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: LogoMark()),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Welcome back',
                        style: AppText.titleL, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Sign in to continue studying',
                      style: AppText.bodyM.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    AppTextField(
                      controller: _email,
                      label: 'Email',
                      hint: 'you@university.edu.pk',
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
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      errorText: _passwordError,
                      onChanged: _onEdited,
                      onSubmitted: (_) => _submit(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: loading ? null : _forgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (failure != null) ...[
                      AuthErrorBanner(message: failure),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    AppButton(
                      label: 'Sign in',
                      loading: loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New here?',
                            style: AppText.bodyM
                                .copyWith(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () {
                                  ref
                                      .read(authNotifierProvider.notifier)
                                      .clearError();
                                  context.push('/sign-up');
                                },
                          child: const Text('Create an account'),
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

class _ResetDialog extends StatefulWidget {
  const _ResetDialog({required this.controller});

  final TextEditingController controller;

  @override
  State<_ResetDialog> createState() => _ResetDialogState();
}

class _ResetDialogState extends State<_ResetDialog> {
  String? _error;

  void _send() {
    final error = validateEmail(widget.controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(widget.controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("We'll email you a link to choose a new password."),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: widget.controller,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.send,
            errorText: _error,
            autofocus: true,
            onSubmitted: (_) => _send(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _send, child: const Text('Send link')),
      ],
    );
  }
}
