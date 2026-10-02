import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../application/quiz/quiz_notifier.dart';
import '../../../../application/quiz/quiz_state.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/markdown_view.dart';
import '../../../core/widgets/score_ring.dart';
import '../../../core/widgets/states.dart';
import 'widgets/quiz_widgets.dart';

/// Pushed over the shell: generates, runs and scores one quiz.
class QuizPlayPage extends ConsumerStatefulWidget {
  const QuizPlayPage({super.key, required this.config});

  final QuizConfig? config;

  @override
  ConsumerState<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends ConsumerState<QuizPlayPage> {
  QuizNotifier get _notifier => ref.read(quizNotifierProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final config = widget.config;
      if (config == null) {
        context.pop(); // opened without settings (e.g. after a restart)
      } else {
        _notifier.start(config);
      }
    });
  }

  Future<bool> _confirmLeave() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave quiz?'),
        content: const Text('Your answers in this quiz will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _close() async {
    final s = ref.read(quizNotifierProvider);
    if (s is QuizLoaded && !await _confirmLeave()) return;
    if (s is QuizLoading) _notifier.cancel();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(quizNotifierProvider);
    final config = widget.config;

    return PopScope(
      canPop: s is! QuizLoaded,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          if (s is QuizLoading) _notifier.cancel();
          return;
        }
        if (await _confirmLeave() && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close quiz',
            icon: const Icon(Icons.close_rounded),
            onPressed: _close,
          ),
          titleSpacing: 0,
          title: s is QuizLoaded
              ? Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.screen),
                  child: QuizProgressBar(
                    questions: s.questions,
                    answers: s.answers,
                    currentIndex: s.currentIndex,
                  ),
                )
              : Text(config?.subject ?? 'Quiz'),
        ),
        body: switch (s) {
          QuizLoaded() => _QuestionView(state: s, config: config),
          QuizFinished() => _ResultView(state: s, config: config),
          QuizFailure() => ErrorState(
              failure: s.failure,
              title: "Couldn't make your quiz",
              onRetry: config == null ? null : () => _notifier.start(config),
            ),
          _ => _LoadingView(
              summary: config?.summary ?? '',
              onCancel: () {
                _notifier.cancel();
                context.pop();
              },
            ),
        },
      ),
    );
  }
}

class _LoadingView extends StatefulWidget {
  const _LoadingView({required this.summary, required this.onCancel});

  final String summary;
  final VoidCallback onCancel;

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView> {
  static const _lines = [
    'Reading the syllabus',
    'Writing questions',
    'Checking answers',
  ];
  int _line = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      setState(() => _line = (_line + 1) % _lines.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 200, child: LinearProgressIndicator()),
            const SizedBox(height: AppSpacing.xl),
            Semantics(
              liveRegion: true,
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.normal),
                child: Text(
                  '${_lines[_line]}…',
                  key: ValueKey(_line),
                  style: AppText.titleS,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(widget.summary,
                style: AppText.bodyM.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxl),
            AppButton.secondary(
              label: 'Cancel',
              fullWidth: false,
              onPressed: widget.onCancel,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionView extends ConsumerWidget {
  const _QuestionView({required this.state, required this.config});

  final QuizLoaded state;
  final QuizConfig? config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(quizNotifierProvider.notifier);
    final q = state.current;
    final topic = config?.topic ?? config?.subject;
    final caption = 'Question ${state.currentIndex + 1} of '
        '${state.questions.length}${topic == null ? '' : ', $topic'}';

    return Column(
      children: [
        Expanded(
          child: ListView(
            key: ValueKey(state.currentIndex),
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              Text(caption,
                  style: AppText.caption.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: MarkdownView(data: q.question, baseStyle: AppText.question),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < q.options.length; i++) ...[
                QuizOptionTile(
                  index: i,
                  text: q.options[i],
                  state: optionStateFor(
                    i: i,
                    correctIndex: q.correctIndex,
                    selectedIndex: state.selectedIndex,
                    checked: state.checked,
                  ),
                  onTap: state.checked
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          notifier.select(i);
                        },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (state.checked) ...[
                const SizedBox(height: AppSpacing.xs),
                ExplanationCard(question: q),
              ],
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SafeArea(
            top: false,
            child: state.checked
                ? AppButton(
                    label: state.isLast ? 'See results' : 'Next',
                    icon: state.isLast
                        ? Icons.flag_rounded
                        : Icons.arrow_forward_rounded,
                    onPressed: notifier.next,
                  )
                : AppButton(
                    label: 'Check answer',
                    onPressed: state.selectedIndex == null
                        ? null
                        : () {
                            notifier.check();
                            HapticFeedback.mediumImpact();
                          },
                  ),
          ),
        ),
      ],
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView({required this.state, required this.config});

  final QuizFinished state;
  final QuizConfig? config;

  static (String, IconData) verdict(int percent) {
    if (percent >= 80) return ('Excellent', Icons.emoji_events_rounded);
    if (percent >= 60) return ('Good', Icons.thumb_up_alt_rounded);
    if (percent >= 40) return ('Keep going', Icons.trending_up_rounded);
    return ('Keep practicing', Icons.school_rounded);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(quizNotifierProvider.notifier);
    final (label, icon) = verdict(state.percent);
    final color = scoreColor(state.percent);
    final where = config?.topic ?? config?.subject;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        const SizedBox(height: AppSpacing.md),
        Center(child: ScoreRing(score: state.score, total: state.total)),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppText.titleL),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'You got ${state.score} of ${state.total} right'
          '${where == null ? '' : ' in $where'}'
          '${state.isRetry ? ' (retry round)' : ''}.',
          style: AppText.bodyM.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (state.wrongQuestions.isNotEmpty) ...[
          AppButton(
            label: 'Retry wrong questions (${state.wrongQuestions.length})',
            icon: Icons.replay_rounded,
            onPressed: notifier.retryWrong,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (config != null) ...[
          AppButton.secondary(
            label: 'New quiz',
            icon: Icons.auto_awesome_rounded,
            onPressed: () => notifier.start(config!),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AppButton.ghost(label: 'Done', onPressed: () => context.pop()),
        const SizedBox(height: AppSpacing.section),
        const SectionHeader(title: 'Review'),
        for (var i = 0; i < state.questions.length; i++)
          _ReviewTile(
            number: i + 1,
            question: state.questions[i].question,
            options: state.questions[i].options,
            correctIndex: state.questions[i].correctIndex,
            selectedIndex: state.answers[i],
            explanation: state.questions[i].explanation,
          ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.number,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.selectedIndex,
    required this.explanation,
  });

  final int number;
  final String question;
  final List<String> options;
  final int correctIndex;
  final int? selectedIndex;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final correct = selectedIndex == correctIndex;
    String opt(int i) => '${String.fromCharCode(65 + i)}. ${options[i]}';
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.lg),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      shape: const Border(),
      leading: Icon(
        correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
        color: correct ? AppColors.success : AppColors.error,
        semanticLabel: correct ? 'Correct' : 'Incorrect',
      ),
      title: Text('$number. $question',
          style: AppText.bodyM, maxLines: 2, overflow: TextOverflow.ellipsis),
      children: [
        MarkdownView(data: question, baseStyle: AppText.bodyM),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your answer: ${selectedIndex == null ? 'Not answered' : opt(selectedIndex!)}',
          style: AppText.bodyM
              .copyWith(color: correct ? AppColors.success : AppColors.error),
        ),
        if (!correct)
          Text('Correct answer: ${opt(correctIndex)}',
              style: AppText.bodyM.copyWith(color: AppColors.success)),
        if (explanation.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          MarkdownView(
            data: explanation,
            baseStyle: AppText.bodyM.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
