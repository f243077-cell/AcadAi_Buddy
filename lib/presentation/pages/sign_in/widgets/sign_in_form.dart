// lib/presentation/pages/sign_in/widgets/sign_in_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../application/auth/auth_notifier.dart';
import '../../../../../application/auth/auth_state.dart';

const Color _kAccent = Color(0xFFF4C430);
const Color _kBackground = Color(0xFF0D1B2A);
const Color _kTextPrimary = Colors.white;

class SignInForm extends ConsumerStatefulWidget {
  const SignInForm({super.key});

  @override
  ConsumerState<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool valid = true;

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Email is required');
      valid = false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      valid = false;
    }

    return valid;
  }

  void _handleSignIn() {
    if (!_validate()) return;
    ref.read(authNotifierProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        TextField(
          controller: _emailController,
          enabled: !isLoading,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          style: const TextStyle(
            color: _kTextPrimary,
            fontFamily: 'Georgia',
            fontSize: 15,
          ),
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'you@university.edu',
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            errorText: _emailError,
          ),
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
          onSubmitted: (_) => _handleSignIn(),
        ),

        const SizedBox(height: 16),

        // Password field
        TextField(
          controller: _passwordController,
          enabled: !isLoading,
          obscureText: _obscurePassword,
          style: const TextStyle(
            color: _kTextPrimary,
            fontFamily: 'Georgia',
            fontSize: 15,
          ),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            errorText: _passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
          onSubmitted: (_) => _handleSignIn(),
        ),

        const SizedBox(height: 28),

        // Sign In button
        ElevatedButton(
          onPressed: isLoading ? null : _handleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kAccent,
            foregroundColor: _kBackground,
            minimumSize: const Size(double.infinity, 52),
            disabledBackgroundColor: _kAccent.withAlpha((0.5 * 255).round()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _kBackground,
                  ),
                )
              : const Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
        ),
      ],
    );
  }
}
