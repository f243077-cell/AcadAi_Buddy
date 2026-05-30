// lib/presentation/pages/splash/splash_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_notifier.dart';
import '../../../application/auth/auth_state.dart';

const Color _kAccent = Color(0xFFF4C430);
const Color _kBackground = Color(0xFF0D1B2A);
const Color _kSurface = Color(0xFF162336);
const Color _kTextSecondary = Color(0xFF8899AA);

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).checkAuth();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (!mounted) return;
      if (next is AuthAuthenticated) {
        context.go('/home');
      } else if (next is AuthUnauthenticated || next is AuthFailureState) {
        context.go('/sign-in');
      }
    });

    return Scaffold(
      backgroundColor: _kBackground,
      body: Stack(
        children: [
          // Decorative top-right circle
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _kAccent.withAlpha(20),
                    _kAccent.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
          // Decorative bottom-left circle
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _kAccent.withAlpha(15),
                    _kAccent.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo container
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _kAccent.withAlpha(102),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _kAccent.withAlpha(31),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🎓', style: TextStyle(fontSize: 48)),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'AcadAI Buddy',
                      style: TextStyle(
                        color: _kAccent,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Your Intelligent Study Companion',
                      style: TextStyle(
                        color: _kTextSecondary,
                        fontSize: 14,
                        fontFamily: 'Georgia',
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 56),

                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _kAccent.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom version text
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: const Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _kTextSecondary,
                  fontSize: 12,
                  fontFamily: 'Georgia',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
