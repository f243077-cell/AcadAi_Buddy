import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_notifier.dart';
import '../../../application/chat/chat_history.dart';
import '../../../application/quiz/quiz_notifier.dart';
import '../../../domain/auth/entities/app_user.dart';
import '../../../domain/study/entities/quiz_result.dart';
import '../../core/app_info.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_snack.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/logo_mark.dart';

/// Account screen: who you are, your study stats, account actions,
/// About, and sign out.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      // Signing out: the router is about to leave this screen.
      return const Scaffold(body: SizedBox.shrink());
    }
    final chats = ref.watch(chatHistoryProvider).valueOrNull;
    final results = ref.watch(quizResultsProvider).valueOrNull;
    final stats = results == null ? null : QuizStats.from(results);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          _Header(user: user),
          const SizedBox(height: AppSpacing.section),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Chats',
                  value: chats == null ? null : '${chats.length}',
                  icon: Icons.forum_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  label: 'Quizzes',
                  value: stats == null ? null : '${stats.taken}',
                  icon: Icons.quiz_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  label: 'Average',
                  value: stats == null
                      ? null
                      : stats.taken == 0
                          ? '–'
                          : '${stats.averagePercent}%',
                  icon: Icons.insights_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          const SectionHeader(title: 'Account'),
          _Group(children: [
            _Row(
              icon: Icons.badge_outlined,
              title: 'Name',
              subtitle: user.displayName,
              onTap: () => _editName(context, ref, user),
            ),
            _Row(
              icon: Icons.mail_outline_rounded,
              title: 'Email',
              subtitle: user.email,
            ),
            _Row(
              icon: Icons.lock_reset_rounded,
              title: 'Change password',
              subtitle: 'We email you a secure reset link',
              onTap: () => _resetPassword(context, ref, user),
            ),
          ]),
          const SizedBox(height: AppSpacing.section),
          const SectionHeader(title: 'Study'),
          _Group(children: [
            _Row(
              icon: Icons.history_rounded,
              title: 'Chat history',
              onTap: () => context.go('/tutor'),
            ),
            _Row(
              icon: Icons.quiz_outlined,
              title: 'Practice quiz',
              onTap: () => context.go('/quiz'),
            ),
          ]),
          const SizedBox(height: AppSpacing.section),
          const SectionHeader(title: 'About'),
          _Group(children: [
            _Row(
              icon: Icons.info_outline_rounded,
              title: 'About $kAppName',
              subtitle: 'Version $kAppVersion',
              onTap: () => _showAbout(context),
            ),
          ]),
          const SizedBox(height: AppSpacing.xxl),
          AppButton.secondary(
            label: 'Sign out',
            icon: Icons.logout_rounded,
            onPressed: () => _confirmSignOut(context, ref),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Future<void> _editName(
      BuildContext context, WidgetRef ref, AppUser user) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initial: user.displayName),
    );
    if (name == null || name == user.displayName || !context.mounted) return;
    final failure =
        await ref.read(authNotifierProvider.notifier).updateDisplayName(name);
    if (!context.mounted) return;
    if (failure == null) {
      AppSnack.show(context, 'Name updated', tone: SnackTone.success);
    } else {
      AppSnack.show(context, failure.message, tone: SnackTone.error);
    }
  }

  Future<void> _resetPassword(
      BuildContext context, WidgetRef ref, AppUser user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password?'),
        content: Text(
            "We'll send a link to ${user.email} so you can choose a new password."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send link'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final result = await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordReset(user.email);
    if (!context.mounted) return;
    result.fold(
      (f) => AppSnack.show(context, f.message, tone: SnackTone.error),
      (_) => AppSnack.show(context, 'Reset link sent to ${user.email}',
          tone: SnackTone.success),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'Your chats and quiz results stay saved to your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(authNotifierProvider.notifier).signOut();
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: kAppName,
      applicationVersion: 'Version $kAppVersion',
      applicationIcon: const LogoMark(),
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'An AI study companion for university students: a tutor for any '
          'subject, practice quizzes and note summaries.',
          style: AppText.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'AI answers can be wrong. Check important facts with your course '
          'material or teacher.',
          style: AppText.caption.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Avatar(user: user, size: 80),
        const SizedBox(height: AppSpacing.lg),
        Text(user.displayName,
            style: AppText.titleL,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: AppSpacing.xs),
        Text(user.email,
            style: AppText.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;

  /// Null while loading.
  final String? value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      semanticLabel: '$label: ${value ?? 'loading'}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.accent),
            const SizedBox(height: AppSpacing.sm),
            Text(value ?? '…', style: AppText.titleM),
            Text(label,
                style: AppText.caption.copyWith(color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

/// A card holding settings rows separated by dividers.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 56),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Your name'),
      content: AppTextField(
        controller: _controller,
        autofocus: true,
        maxLength: 50,
        errorText: _error,
        textCapitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.name],
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
