// lib/presentation/pages/sign_up/sign_up_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_notifier.dart';
import '../../../application/auth/auth_state.dart';

// ── Base colors ──────────────────────────────────────────────────────────────
const _kAccent = Color(0xFFF4C430);
const _kBackground = Color(0xFF0D1B2A);
const _kSurface = Color(0xFF162336);
const _kSurfaceVariant = Color(0xFF1E2F45);
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFF8899AA);
const _kDivider = Color(0xFF1E2F45);
const _kError = Color(0xFFFF5C5C);

// ── Pre-declared opacity variants (no withOpacity anywhere) ──────────────────
const _kAccent07 = Color(0x12F4C430); // accent  7%
const _kAccentNone = Color(0x00F4C430); // accent  0% (gradient end)
const _kAccent50 = Color(0x80F4C430); // accent 50% (disabled button)
const _kBackground70 = Color(0xB30D1B2A); // bg     70% (loading overlay)

// ── Page ─────────────────────────────────────────────────────────────────────
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool valid = true;

    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Full name is required');
      valid = false;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Email is required');
      valid = false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      valid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      valid = false;
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your password');
      valid = false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      valid = false;
    }

    return valid;
  }

  void _handleSignUp() {
    if (!_validate()) return;
    ref.read(authNotifierProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
  }

  String _failureMessage(AuthFailureState state) {
    final msg = state.failure.message;
    if (msg.contains('server')) return 'Server error. Please try again.';
    if (msg.contains('already exists')) {
      return 'This email is already registered.';
    }
    if (msg.contains('No account')) return 'No account found with this email.';
    if (msg.contains('too weak')) {
      return 'Password is too weak. Choose a stronger one.';
    }
    if (msg.contains('badly formatted')) {
      return 'Please enter a valid email address.';
    }
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (!mounted) return;

      if (next is AuthAuthenticated) {
        context.go('/home');
      } else if (next is AuthFailureState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: _kError, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _failureMessage(next),
                    style: const TextStyle(color: _kTextPrimary),
                  ),
                ),
              ],
            ),
            backgroundColor: _kSurfaceVariant,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: _kBackground,
      body: Stack(
        children: [
          // Decorative top-right radial circle
          const Positioned(
            top: -80,
            right: -80,
            child: SizedBox(
              width: 260,
              height: 260,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_kAccent07, _kAccentNone],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Back button
                  GestureDetector(
                    onTap: isLoading ? null : () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kDivider),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: _kTextSecondary,
                        size: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text('📚', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 20),

                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color: _kAccent,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  const Text(
                    'Join AcadAI Buddy and start learning',
                    style: TextStyle(
                      color: _kTextSecondary,
                      fontSize: 15,
                      fontFamily: 'Georgia',
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Name field
                  TextField(
                    controller: _nameController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                        color: _kTextPrimary,
                        fontFamily: 'Georgia',
                        fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'John Smith',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      errorText: _nameError,
                    ),
                    onChanged: (_) {
                      if (_nameError != null) {
                        setState(() => _nameError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email field
                  TextField(
                    controller: _emailController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: const TextStyle(
                        color: _kTextPrimary,
                        fontFamily: 'Georgia',
                        fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'you@university.edu',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      errorText: _emailError,
                    ),
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
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
                        fontSize: 15),
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
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm password field
                  TextField(
                    controller: _confirmPasswordController,
                    enabled: !isLoading,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(
                        color: _kTextPrimary,
                        fontFamily: 'Georgia',
                        fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      errorText: _confirmPasswordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    onChanged: (_) {
                      if (_confirmPasswordError != null) {
                        setState(() => _confirmPasswordError = null);
                      }
                    },
                    onSubmitted: (_) => _handleSignUp(),
                  ),

                  const SizedBox(height: 32),

                  // Sign Up button
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAccent,
                      foregroundColor: _kBackground,
                      minimumSize: const Size(double.infinity, 52),
                      disabledBackgroundColor: _kAccent50,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
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
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Already have account
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kAccent,
                        side: const BorderSide(color: _kDivider),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Already have an account? Sign In',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (isLoading)
            const ColoredBox(
              color: _kBackground70,
              child: Center(
                child: CircularProgressIndicator(color: _kAccent),
              ),
            ),
        ],
      ),
    );
  }
}
