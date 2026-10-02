import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../application/chat/chat_history.dart';
import '../../../../application/quiz/quiz_state.dart';
import '../../../../domain/study/entities/study_options.dart';
import '../../../../domain/study/subject_catalogue.dart';
import '../../../core/subject_icons.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/subject_sheet.dart';

/// Quiz tab: pick subject, topic, length and difficulty, then generate.
class QuizSetupPage extends ConsumerStatefulWidget {
  const QuizSetupPage({super.key});

  @override
  ConsumerState<QuizSetupPage> createState() => _QuizSetupPageState();
}

class _QuizSetupPageState extends ConsumerState<QuizSetupPage> {
  String? _subject;
  String? _topic;
  int _count = 10;
  QuizDifficulty _difficulty = QuizDifficulty.medium;
  final _customTopic = TextEditingController();

  static const _counts = [5, 10, 15];

  @override
  void dispose() {
    _customTopic.dispose();
    super.dispose();
  }

  String _currentSubject(List<String> recents) =>
      _subject ?? (recents.isNotEmpty ? recents.first : kSubjects[2].name);

  Future<void> _pickSubject(String current, List<String> recents) async {
    final chosen =
        await SubjectSheet.show(context, current: current, recents: recents);
    if (chosen != null) _setSubject(chosen);
  }

  void _setSubject(String s) => setState(() {
        _subject = s;
        _topic = null;
        _customTopic.clear();
      });

  QuizConfig _config(String subject) {
    final custom = _customTopic.text.trim();
    return QuizConfig(
      subject: subject,
      topic: _topic ?? (custom.isEmpty ? null : custom),
      count: _count,
      difficulty: _difficulty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recents = ref.watch(recentSubjectsProvider);
    final subject = _currentSubject(recents);
    final catalogue = subjectByName(subject);
    final config = _config(subject);

    return Scaffold(
      appBar: AppBar(title: const Text('Practice quiz')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          const SectionHeader(title: 'Subject'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            onTap: () => _pickSubject(subject, recents),
            semanticLabel: 'Subject: $subject. Tap to change',
            child: ExcludeSemantics(
              child: Row(
                children: [
                  IconBadge(icon: iconForSubject(subject)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subject,
                            style: AppText.titleS,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        Text(catalogue?.category ?? 'Custom subject',
                            style: AppText.caption
                                .copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.expand_more_rounded,
                      color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          if (recents.where((r) => r != subject).isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final r in recents.where((r) => r != subject).take(4))
                  ActionChip(label: Text(r), onPressed: () => _setSubject(r)),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.section),
          const SectionHeader(title: 'Topic (optional)'),
          const SizedBox(height: AppSpacing.sm),
          if (catalogue != null)
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final t in catalogue.topics)
                  ChoiceChip(
                    label: Text(t),
                    selected: _topic == t,
                    onSelected: (on) => setState(() => _topic = on ? t : null),
                  ),
              ],
            )
          else
            AppTextField(
              controller: _customTopic,
              hint: 'e.g. Chapter 3',
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
            ),
          const SizedBox(height: AppSpacing.section),
          const SectionHeader(title: 'Questions'),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (final c in _counts)
                ButtonSegment(value: c, label: Text('$c')),
            ],
            selected: {_count},
            onSelectionChanged: (s) => setState(() => _count = s.first),
          ),
          const SizedBox(height: AppSpacing.section),
          const SectionHeader(title: 'Difficulty'),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<QuizDifficulty>(
            showSelectedIcon: false,
            segments: [
              for (final d in QuizDifficulty.values)
                ButtonSegment(value: d, label: Text(d.label)),
            ],
            selected: {_difficulty},
            onSelectionChanged: (s) => setState(() => _difficulty = s.first),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen, AppSpacing.md, AppSpacing.screen, AppSpacing.md),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(config.summary,
                  style: AppText.caption.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Generate quiz',
                icon: Icons.auto_awesome_rounded,
                onPressed: () => context.push('/quiz/play', extra: config),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
