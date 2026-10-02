import 'package:flutter/material.dart';

import '../theme.dart';

enum AppButtonVariant { primary, secondary, ghost }

/// The one button used across the app: 52 dp high, radius 12.
///
/// While [loading] the label is replaced by a spinner without changing the
/// button's width, and taps are ignored.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
  }) : variant = AppButtonVariant.ghost;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final fg = switch (variant) {
      AppButtonVariant.primary => AppColors.onAccent,
      AppButtonVariant.secondary => AppColors.textPrimary,
      AppButtonVariant.ghost => AppColors.textPrimary,
    };

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    final child = loading
        ? Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: 0, child: content),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              ),
            ],
          )
        : content;

    final onTap = loading ? () {} : onPressed;

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(onPressed: onTap, child: child),
      AppButtonVariant.secondary =>
        OutlinedButton(onPressed: onTap, child: child),
      AppButtonVariant.ghost => TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size(AppSpacing.touch, 52),
            textStyle: AppText.titleS,
          ),
          child: child,
        ),
    };

    return Semantics(
      button: true,
      label: loading ? '$label, loading' : null,
      excludeSemantics: loading,
      child: fullWidth
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}
