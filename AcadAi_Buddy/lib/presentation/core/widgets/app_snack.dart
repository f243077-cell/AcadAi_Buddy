import 'package:flutter/material.dart';

import '../theme.dart';

enum SnackTone { info, success, error }

/// Floating snackbars: one at a time, 4 s, optional action.
class AppSnack {
  AppSnack._();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String message, {
    SnackTone tone = SnackTone.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final (icon, color) = switch (tone) {
      SnackTone.info => (Icons.info_outline_rounded, AppColors.info),
      SnackTone.success => (Icons.check_circle_outline_rounded, AppColors.success),
      SnackTone.error => (Icons.error_outline_rounded, AppColors.error),
    };
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        duration: duration,
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message, style: AppText.bodyM)),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ),
    );
  }
}
