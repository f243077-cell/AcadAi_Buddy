import 'package:flutter/material.dart';

import '../../../../../domain/study/entities/quiz_message.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets/markdown_view.dart';

enum OptionState { idle, selected, correct, wrong, dimmed }

/// The visual state of option [i] given the selection and whether the
/// answer has been checked.
OptionState optionStateFor({
  required int i,
  required int correctIndex,
  required int? selectedIndex,
  required bool checked,
}) {
  if (!checked) return i == selectedIndex ? OptionState.selected : OptionState.idle;
  if (i == correctIndex) return OptionState.correct;
  if (i == selectedIndex) return OptionState.wrong;
  return OptionState.dimmed;
}

/// 56 dp answer tile with an A-D badge. Correct and wrong states use an
/// icon as well as colour.
class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    super.key,
    required this.index,
    required this.text,
    required this.state,
    this.onTap,
  });

  final int index;
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  String get letter => String.fromCharCode(65 + index);

  @override
  Widget build(BuildContext context) {
    final (Color border, double width, Color fill) = switch (state) {
      OptionState.idle => (AppColors.border, 1.0, AppColors.surface),
      OptionState.dimmed => (AppColors.border, 1.0, AppColors.surface),
      OptionState.selected =>
        (AppColors.accent, 1.5, AppColors.tint(AppColors.accent, 0.08)),
      OptionState.correct =>
        (AppColors.success, 1.5, AppColors.tint(AppColors.success)),
      OptionState.wrong =>
        (AppColors.error, 1.5, AppColors.tint(AppColors.error)),
    };
    final status = switch (state) {
      OptionState.selected => ', selected',
      OptionState.correct => ', correct answer',
      OptionState.wrong => ', your answer, incorrect',
      _ => '',
    };

    return Semantics(
      button: onTap != null,
      selected: state == OptionState.selected,
      label: 'Option $letter: $text$status',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.fast),
        curve: AppMotion.curve,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: AppRadius.inputAll,
          border: Border.all(color: border, width: width),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.inputAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    _Badge(letter: letter, state: state),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Opacity(
                        opacity: state == OptionState.dimmed ? 0.7 : 1,
                        child: MarkdownView(data: text, baseStyle: AppText.bodyL),
                      ),
                    ),
                    if (state == OptionState.correct)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success),
                    if (state == OptionState.wrong)
                      const Icon(Icons.cancel_rounded, color: AppColors.error),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.letter, required this.state});

  final String letter;
  final OptionState state;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData? icon) = switch (state) {
      OptionState.selected => (AppColors.accent, AppColors.onAccent, null),
      OptionState.correct =>
        (AppColors.success, AppColors.onAccent, Icons.check_rounded),
      OptionState.wrong =>
        (AppColors.error, AppColors.onAccent, Icons.close_rounded),
      _ => (AppColors.surfaceAlt, AppColors.textSecondary, null),
    };
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: icon != null
          ? Icon(icon, size: 18, color: fg)
          : Text(letter, style: AppText.label.copyWith(color: fg)),
    );
  }
}

/// One segment per question: correct green, wrong red, current gold,
/// upcoming in the border colour.
class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({
    super.key,
    required this.questions,
    required this.answers,
    required this.currentIndex,
  });

  final List<QuizQuestion> questions;
  final List<int?> answers;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Question ${currentIndex + 1} of ${questions.length}',
      child: Row(
        children: [
          for (var i = 0; i < questions.length; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: AppMotion.of(context, AppMotion.normal),
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pillAll,
                  color: answers[i] != null
                      ? (answers[i] == questions[i].correctIndex
                          ? AppColors.success
                          : AppColors.error)
                      : i == currentIndex
                          ? AppColors.accent
                          : AppColors.border,
                ),
              ),
            ),
            if (i < questions.length - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

/// Info-toned card explaining the correct answer.
class ExplanationCard extends StatelessWidget {
  const ExplanationCard({super.key, required this.question});

  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    final text = question.explanation.isNotEmpty
        ? question.explanation
        : 'The correct answer is **${question.answer}**.';
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.card),
        decoration: BoxDecoration(
          color: AppColors.tint(AppColors.info, 0.10),
          borderRadius: AppRadius.cardAll,
          border: Border.all(color: AppColors.tint(AppColors.info, 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    size: 18, color: AppColors.info),
                const SizedBox(width: AppSpacing.sm),
                Text('Explanation',
                    style: AppText.label.copyWith(color: AppColors.info)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            MarkdownView(data: text, baseStyle: AppText.bodyM),
          ],
        ),
      ),
    );
  }
}
