import 'package:flutter/material.dart';

import '../../../core/theme.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'Email is required';
  if (!_emailPattern.hasMatch(v)) return 'Enter a valid email address';
  return null;
}

/// Minimum client-side password length for new accounts.
const kMinPasswordLength = 8;

/// 0 (empty) to 4 (strong).
int passwordStrength(String p) {
  if (p.isEmpty) return 0;
  var score = 0;
  if (p.length >= kMinPasswordLength) score++;
  if (RegExp(r'[a-z]').hasMatch(p) && RegExp(r'[A-Z]').hasMatch(p)) score++;
  if (RegExp(r'\d').hasMatch(p)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(p) || p.length >= 14) score++;
  return score == 0 ? 1 : score;
}

/// Inline auth failure shown above the primary button; announced to
/// screen readers when it appears.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.tint(AppColors.error),
          borderRadius: AppRadius.inputAll,
          border: Border.all(color: AppColors.error),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message, style: AppText.bodyM)),
          ],
        ),
      ),
    );
  }
}

/// Four-segment password strength meter with a label.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final s = passwordStrength(password);
    final (label, color) = switch (s) {
      0 => ('', AppColors.border),
      1 => ('Weak', AppColors.error),
      2 => ('Fair', AppColors.warning),
      3 => ('Good', AppColors.accent),
      _ => ('Strong', AppColors.success),
    };
    return Semantics(
      label: s == 0 ? null : 'Password strength: $label',
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: AppMotion.of(context, AppMotion.fast),
                height: 4,
                decoration: BoxDecoration(
                  color: i < s ? color : AppColors.border,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
            if (i < 3) const SizedBox(width: AppSpacing.xs),
          ],
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 48,
            child: ExcludeSemantics(
              child: Text(label,
                  style: AppText.caption.copyWith(color: color),
                  textAlign: TextAlign.end),
            ),
          ),
        ],
      ),
    );
  }
}
