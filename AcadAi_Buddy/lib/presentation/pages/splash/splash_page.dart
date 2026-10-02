import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routes/app_routes.dart';
import '../../core/theme.dart';
import '../../core/widgets/logo_mark.dart';

/// Shown while the first auth event arrives. Visible for at least 600 ms;
/// the router moves on as soon as both that time and auth are ready.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    _timer = Timer(const Duration(milliseconds: 600), () {
      ref.read(splashMinElapsedProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: AppMotion.of(context, const Duration(milliseconds: 400)),
          curve: AppMotion.curve,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LogoMark(size: 64),
              const SizedBox(height: AppSpacing.xl),
              Text('AcadAI Buddy', style: AppText.display),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your AI study companion',
                style: AppText.bodyM.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SizedBox(
                width: 120,
                child: LinearProgressIndicator(minHeight: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
