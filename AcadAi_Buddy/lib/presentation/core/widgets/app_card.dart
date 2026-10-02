import 'package:flutter/material.dart';

import '../theme.dart';

/// Flat surface container: 1 px border, radius 16, padding 16.
///
/// With [accentBar] a 4 dp gold bar runs down the left edge (the
/// "continue studying" card). With [onTap] the whole card is a button.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.card),
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.borderWidth = 1,
    this.accentBar = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final bool accentBar;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (accentBar) {
      content = Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: content,
          ),
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: ColoredBox(color: AppColors.accent),
          ),
        ],
      );
    }

    final card = Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardAll,
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );

    if (onTap == null && semanticLabel == null) return card;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: card,
    );
  }
}

/// 40×40 rounded-12 square: tinted fill with an icon in the same tone.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color = AppColors.accent,
    this.size = 40,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.tint(color),
          borderRadius: AppRadius.inputAll,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: size * 0.55),
      ),
    );
  }
}

/// Uppercase overline label with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: AppText.overline.copyWith(color: AppColors.textMuted),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
