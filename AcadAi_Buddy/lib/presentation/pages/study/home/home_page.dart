import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../application/auth/auth_notifier.dart';
import '../../../../application/chat/chat_history.dart';
import '../../../../application/quiz/quiz_notifier.dart';
import '../../../../domain/study/entities/chat_session.dart';
import '../../../../domain/study/entities/quiz_result.dart';
import '../../../../domain/study/subject_catalogue.dart';
import '../../../core/format.dart';
import '../../../core/subject_icons.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/subject_sheet.dart';
import '../chat/start_chat.dart';
import '../tutor/tutor_page.dart';
import 'widgets/profile_sheet.dart';

String greetingFor(DateTime now) {
  final h = now.hour;
  if (h < 12) return 'Good morning,';
  if (h < 17) return 'Good afternoon,';
  return 'Good evening,';
}

/// Home: greeting, continue studying, tools, subjects, progress and recent
/// chats. Blocks without data are hidden rather than filled with filler.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final history = ref.watch(chatHistoryProvider);
    final results = ref.watch(quizResultsProvider);
    final recents = ref.watch(recentSubjectsProvider);
    final chats = history.valueOrNull ?? const <ChatSession>[];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            // ── Header ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greetingFor(DateTime.now()),
                          style: AppText.bodyM
                              .copyWith(color: AppColors.textMuted)),
                      Semantics(
                        header: true,
                        child: Text(
                          user == null ? '' : firstNameOf(user),
                          style: AppText.titleL,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (user != null)
                  IconButton(
                    tooltip: 'Profile and sign out',
                    onPressed: () => showProfileSheet(context, user),
                    icon: Avatar(user: user),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),

            // ── Continue studying ─────────────────────────────────────────
            if (history.isLoading && chats.isEmpty)
              const SkeletonBox(height: 112, radius: AppRadius.card)
            else if (chats.isNotEmpty)
              _ContinueCard(chat: chats.first)
            else
              _FirstSessionCard(onStart: () => startNewChat(context)),
            const SizedBox(height: AppSpacing.section),

            // ── Study tools ───────────────────────────────────────────────
            const SectionHeader(title: 'Study tools'),
            const SizedBox(height: AppSpacing.sm),
            _ToolCard(
              icon: Icons.forum_rounded,
              title: 'Ask Tutor',
              description: 'Step-by-step help in any subject',
              onTap: () => startNewChat(context, recents: recents),
            ),
            const SizedBox(height: AppSpacing.md),
            _ToolCard(
              icon: Icons.quiz_rounded,
              title: 'Practice Quiz',
              description: 'Generate MCQs and check yourself',
              onTap: () => context.go('/quiz'),
            ),
            const SizedBox(height: AppSpacing.md),
            _ToolCard(
              icon: Icons.description_rounded,
              title: 'Summarize Notes',
              description: 'Turn notes or a photo into key points',
              onTap: () => context.go('/summarize'),
            ),
            const SizedBox(height: AppSpacing.section),

            // ── Your subjects ─────────────────────────────────────────────
            SectionHeader(
              title: 'Your subjects',
              actionLabel: 'Browse all',
              onAction: () async {
                final s = await SubjectSheet.show(context, recents: recents);
                if (s != null && context.mounted) {
                  startNewChat(context, subject: s);
                }
              },
            ),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final s in recents.isNotEmpty
                    ? recents
                    : subjectsInCategory('FAST Core')
                        .take(4)
                        .map((s) => s.name))
                  ActionChip(
                    avatar: Icon(iconForSubject(s),
                        size: 18, color: AppColors.accent),
                    label: Text(s),
                    tooltip: 'Start a chat in $s',
                    onPressed: () => startNewChat(context, subject: s),
                  ),
              ],
            ),

            // ── Progress (only with real results) ─────────────────────────
            if ((results.valueOrNull ?? const []).isNotEmpty) ...[
              const SizedBox(height: AppSpacing.section),
              const SectionHeader(title: 'Progress'),
              const SizedBox(height: AppSpacing.sm),
              _ProgressTiles(stats: QuizStats.from(results.value!)),
            ],

            // ── Recent chats ──────────────────────────────────────────────
            if (chats.length > 1) ...[
              const SizedBox(height: AppSpacing.section),
              SectionHeader(
                title: 'Recent chats',
                actionLabel: 'See all',
                onAction: () => context.go('/tutor'),
              ),
              for (final c in chats.skip(1).take(3)) ChatHistoryTile(chat: c),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.chat});

  final ChatSession chat;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accentBar: true,
      onTap: () => openChat(context, chat.id, subject: chat.subject),
      semanticLabel:
          'Continue studying: ${chat.title}, ${chat.subject}, ${relativeTime(chat.updatedAt)}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CONTINUE STUDYING',
                style: AppText.overline.copyWith(color: AppColors.accent)),
            const SizedBox(height: AppSpacing.sm),
            Text(chat.title,
                style: AppText.titleS,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            if (chat.lastMessage.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(chat.lastMessage,
                  style:
                      AppText.bodyM.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(iconForSubject(chat.subject),
                    size: 16, color: AppColors.accent),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(chat.subject,
                      style: AppText.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(relativeTime(chat.updatedAt),
                    style:
                        AppText.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FirstSessionCard extends StatelessWidget {
  const _FirstSessionCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accentBar: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Start your first session', style: AppText.titleS),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pick a subject and ask the tutor anything, from a definition to '
            'a full worked example.',
            style: AppText.bodyM.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Ask the tutor',
            icon: Icons.forum_rounded,
            fullWidth: false,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      semanticLabel: '$title. $description',
      child: ExcludeSemantics(
        child: Row(
          children: [
            IconBadge(icon: icon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.titleS),
                  Text(description,
                      style: AppText.bodyM
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ProgressTiles extends StatelessWidget {
  const _ProgressTiles({required this.stats});

  final QuizStats stats;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ('Quizzes', '${stats.taken}', Icons.quiz_outlined),
      ('Average', '${stats.averagePercent}%', Icons.insights_rounded),
      if (stats.bestSubject != null)
        ('Best subject', stats.bestSubject!, Icons.emoji_events_outlined),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          Expanded(
            child: AppCard(
              semanticLabel: '${tiles[i].$1}: ${tiles[i].$2}',
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(tiles[i].$3, size: 20, color: AppColors.accent),
                    const SizedBox(height: AppSpacing.sm),
                    Text(tiles[i].$2,
                        style: AppText.titleS,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    Text(tiles[i].$1,
                        style: AppText.caption
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ),
          if (i < tiles.length - 1) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}
