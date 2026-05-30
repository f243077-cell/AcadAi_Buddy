// lib/presentation/pages/sign_in/sign_in_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_notifier.dart';
import '../../../application/auth/auth_state.dart';
import 'widgets/sign_in_form.dart';

// ── Base colors ──────────────────────────────────────────────────────────────
const _kAccent = Color(0xFFF4C430);
const _kBackground = Color(0xFF0D1B2A);
const _kSurface = Color(0xFF162336);
const _kTextSecondary = Color(0xFF8899AA);
const _kDivider = Color(0xFF1E2F45);
const _kError = Color(0xFFFF5C5C);

// ── Pre-declared opacity variants (no withOpacity anywhere) ──────────────────
const _kAccent07 = Color(0x12F4C430); // accent  7%
const _kAccentNone = Color(0x00F4C430); // accent  0% (gradient end)
const _kBackground70 = Color(0xB30D1B2A); // bg     70% (loading overlay)

// ── Page ─────────────────────────────────────────────────────────────────────
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  String _failureMessage(AuthFailureState state) {
    final msg = state.failure.message;
    if (msg.contains('server')) return 'Server error. Please try again.';
    if (msg.contains('password') && msg.contains('incorrect')) {
      return 'Invalid email or password.';
    }
    if (msg.contains('already exists')) {
      return 'This email is already registered.';
    }
    if (msg.contains('No account')) return 'No account found with this email.';
    if (msg.contains('too weak')) return 'Password is too weak.';
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
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: _kSurface,
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
          // Decorative top-left radial circle
          const Positioned(
            top: -100,
            left: -50,
            child: SizedBox(
              width: 280,
              height: 280,
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
                  const SizedBox(height: 60),

                  const Text('🎓', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 20),

                  const Text(
                    'Welcome Back',
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
                    'Sign in to continue your studies',
                    style: TextStyle(
                      color: _kTextSecondary,
                      fontSize: 15,
                      fontFamily: 'Georgia',
                    ),
                  ),

                  const SizedBox(height: 40),

                  const SignInForm(),

                  const SizedBox(height: 24),

                  // OR divider
                  const Row(
                    children: [
                      Expanded(child: Divider(color: _kDivider, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: _kTextSecondary,
                            fontSize: 12,
                            fontFamily: 'Georgia',
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: _kDivider, thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sign up button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed:
                          isLoading ? null : () => context.push('/sign-up'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kAccent,
                        side: const BorderSide(color: _kDivider),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "Don't have an account? Sign Up",
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
