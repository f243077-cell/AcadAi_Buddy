import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../application/auth/auth_notifier.dart';
import '../../../../../domain/auth/entities/app_user.dart';
import '../../../../core/theme.dart';

/// Up to two initials from a display name, falling back to the email.
String initialsFor(AppUser user) {
  final words = user.displayName
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isNotEmpty) {
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }
  return user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';
}

String firstNameOf(AppUser user) {
  final name = user.displayName.trim();
  if (name.isEmpty) return 'there';
  return name.split(RegExp(r'\s+')).first;
}

/// Circle with the user's initials.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.user, this.size = 40});

  final AppUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.tint(AppColors.accent, 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent),
      ),
      child: Text(
        initialsFor(user),
        style: (size >= 56 ? AppText.titleM : AppText.label)
            .copyWith(color: AppColors.accent),
      ),
    );
  }
}

Future<void> showProfileSheet(BuildContext context, AppUser user) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (_) => _ProfileSheet(user: user),
  );
}

class _ProfileSheet extends ConsumerWidget {
  const _ProfileSheet({required this.user});

  final AppUser user;

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
    if (ok != true || !context.mounted) return;
    Navigator.of(context).pop();
    await ref.read(authNotifierProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Avatar(user: user, size: 56),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName,
                        style: AppText.titleM,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(user.email,
                        style: AppText.bodyM
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(),
          if (kDebugMode)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.widgets_outlined),
              title: const Text('Widget gallery'),
              subtitle: const Text('Debug builds only'),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/gallery');
              },
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: Text('Sign out',
                style: AppText.titleS.copyWith(color: AppColors.error)),
            onTap: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
    );
  }
}
