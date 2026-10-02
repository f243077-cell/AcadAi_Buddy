import 'package:flutter/material.dart';

import '../../../domain/core/failures.dart';
import '../theme.dart';
import 'app_button.dart';
import 'app_card.dart';

/// Icon badge, title, one line of context and an optional call to action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.tone = AppColors.accent,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(icon: icon, color: tone, size: 56),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppText.titleS, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppText.bodyM.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: actionLabel!,
                icon: actionIcon,
                onPressed: onAction,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Friendly error with an optional Retry. Pass an [AiFailure] or a message.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.failure,
    this.message,
    this.title,
    this.onRetry,
  });

  final AiFailure? failure;
  final String? message;
  final String? title;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final offline = failure == AiFailure.offline;
    return EmptyState(
      icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      tone: AppColors.error,
      title: title ?? (offline ? 'No connection' : 'Something went wrong'),
      message: message ?? failure?.message ?? AiFailure.unknown.message,
      actionLabel: onRetry == null ? null : 'Retry',
      actionIcon: Icons.refresh_rounded,
      onAction: onRetry,
    );
  }
}

/// Pulsing placeholder used while content loads.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = AppRadius.input,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 0.5;
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 1).animate(_c),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

/// A few skeleton lines shaped like a paragraph.
class SkeletonParagraph extends StatelessWidget {
  const SkeletonParagraph({super.key, this.lines = 4});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines; i++) ...[
            FractionallySizedBox(
              widthFactor: i == lines - 1 ? 0.6 : 1,
              child: const SkeletonBox(height: 14, radius: 4),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Skeleton row shaped like a list tile with an icon badge.
class SkeletonTile extends StatelessWidget {
  const SkeletonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SkeletonBox(width: 40, height: 40),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, radius: 4),
                SizedBox(height: AppSpacing.sm),
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: SkeletonBox(height: 12, radius: 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
