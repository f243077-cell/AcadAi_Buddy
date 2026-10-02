import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../application/auth/auth_notifier.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/app_card.dart';
import '../chat/start_chat.dart';
import 'widgets/profile_sheet.dart';

String greetingFor(DateTime now) {
  final h = now.hour;
  if (h < 12) return 'Good morning,';
  if (h < 17) return 'Good afternoon,';
  return 'Good evening,';
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greetingFor(DateTime.now()),
                          style: AppText.bodyM
                              .copyWith(color: AppColors.textMuted)),
                      Text(
                        user == null ? '' : firstNameOf(user),
                        style: AppText.titleL,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (user != null)
                  IconButton(
                    tooltip: 'Profile',
                    onPressed: () => showProfileSheet(context, user),
                    icon: Avatar(user: user),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            const SectionHeader(title: 'Study tools'),
            const SizedBox(height: AppSpacing.sm),
            _ToolCard(
              icon: Icons.forum_rounded,
              title: 'Ask Tutor',
              description: 'Step-by-step help in any subject',
              onTap: () => startNewChat(context),
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
          ],
        ),
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
