import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/study/entities/chat_message.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets/app_snack.dart';
import '../../../../core/widgets/markdown_view.dart';
import '../../../../core/widgets/typing_dots.dart';

/// 28 dp tutor avatar shown beside AI rows.
class TutorAvatar extends StatelessWidget {
  const TutorAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.school_rounded,
            size: 16, color: AppColors.onAccent),
      ),
    );
  }
}

/// Tutor answer: flat, full width, Markdown with LaTeX and code blocks,
/// followed by Copy and (for the last answer) Regenerate.
class AiMessage extends StatelessWidget {
  const AiMessage({
    super.key,
    required this.message,
    this.onRegenerate,
  });

  final ChatMessage message;
  final VoidCallback? onRegenerate;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: message.content));
    if (context.mounted) {
      AppSnack.show(context, 'Answer copied', tone: SnackTone.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Tutor',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: TutorAvatar(),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectionArea(child: MarkdownView(data: message.content)),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      onPressed: () => _copy(context),
                    ),
                    if (onRegenerate != null)
                      _ActionButton(
                        icon: Icons.refresh_rounded,
                        label: 'Regenerate',
                        onPressed: onRegenerate!,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

/// User message: right-aligned bubble, at most 85% of the available width.
/// A failed message gets an error outline and "Not sent. Retry".
class UserBubble extends StatelessWidget {
  const UserBubble({
    super.key,
    required this.message,
    this.failed = false,
    this.onRetry,
  });

  final ChatMessage message;
  final bool failed;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth * 0.85;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Semantics(
              container: true,
              label: failed ? 'You, not sent' : 'You',
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.card),
                      topRight: Radius.circular(AppRadius.card),
                      bottomLeft: Radius.circular(AppRadius.card),
                      bottomRight: Radius.circular(4),
                    ),
                    border: Border.all(
                      color: failed ? AppColors.error : AppColors.border,
                      width: failed ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.imageBytes != null) ...[
                        ClipRRect(
                          borderRadius: AppRadius.inputAll,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 240),
                            child: Image.memory(
                              message.imageBytes!,
                              fit: BoxFit.cover,
                              semanticLabel: 'Attached image',
                            ),
                          ),
                        ),
                        if (message.content.isNotEmpty)
                          const SizedBox(height: AppSpacing.sm),
                      ] else if (message.hasImage) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.image_outlined,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: AppSpacing.xs),
                            Text('Image attached',
                                style: AppText.caption.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                        if (message.content.isNotEmpty)
                          const SizedBox(height: AppSpacing.xs),
                      ],
                      if (message.content.isNotEmpty)
                        SelectableText(message.content, style: AppText.bodyL),
                    ],
                  ),
                ),
              ),
            ),
            if (failed)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Not sent.',
                      style: AppText.caption.copyWith(color: AppColors.error)),
                  TextButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              ),
          ],
        );
      },
    );
  }
}

/// Flat AI row with animated dots while the tutor is replying.
class TypingRow extends StatelessWidget {
  const TypingRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        TutorAvatar(),
        SizedBox(width: AppSpacing.md),
        TypingDots(),
      ],
    );
  }
}

/// "Today", "Yesterday" or a short date between message groups.
class DateSeparator extends StatelessWidget {
  const DateSeparator({super.key, required this.date});

  final DateTime date;

  static String labelFor(DateTime date, [DateTime? now]) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final day = DateUtils.dateOnly(date);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (day.year == today.year) return DateFormat('EEE, d MMM').format(day);
    return DateFormat('d MMM y').format(day);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              labelFor(date),
              style: AppText.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
