import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/chat/chat_history.dart';
import '../../../../domain/study/entities/chat_session.dart';
import '../../../../domain/study/subject_catalogue.dart';
import '../../../core/format.dart';
import '../../../core/subject_icons.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/states.dart';
import '../chat/start_chat.dart';

/// Tutor tab: searchable chat history grouped by day.
class TutorPage extends ConsumerStatefulWidget {
  const TutorPage({super.key});

  @override
  ConsumerState<TutorPage> createState() => _TutorPageState();
}

class _TutorPageState extends ConsumerState<TutorPage> {
  final _search = TextEditingController();
  String _query = '';

  /// Swiped away but not deleted until the Undo snackbar closes.
  final Set<String> _pendingDelete = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _newChat() =>
      startNewChat(context, recents: ref.read(recentSubjectsProvider));

  void _swipeDelete(ChatSession chat) {
    setState(() => _pendingDelete.add(chat.id));
    final actions = ref.read(chatHistoryActionsProvider);
    AppSnack.show(
      context,
      'Chat deleted',
      actionLabel: 'Undo',
      onAction: () {
        if (mounted) setState(() => _pendingDelete.remove(chat.id));
      },
    ).closed.then((reason) {
      if (reason == SnackBarClosedReason.action) return;
      actions.delete(chat.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(chatHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tutor')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newChat,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New chat'),
      ),
      body: history.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: List.generate(6, (_) => const SkeletonTile()),
        ),
        error: (_, __) => ErrorState(
          title: "Couldn't load your chats",
          message: 'Check your connection and try again.',
          onRetry: () => ref.invalidate(chatHistoryProvider),
        ),
        data: (all) {
          final chats =
              all.where((c) => !_pendingDelete.contains(c.id)).toList();
          if (chats.isEmpty) {
            return EmptyState(
              icon: Icons.forum_rounded,
              title: 'No chats yet',
              message: 'Pick a subject and ask your first question.',
              actionLabel: 'New chat',
              actionIcon: Icons.add_rounded,
              onAction: _newChat,
            );
          }
          return _list(chats);
        },
      ),
    );
  }

  Widget _list(List<ChatSession> chats) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? chats
        : chats
            .where((c) =>
                c.title.toLowerCase().contains(q) ||
                c.subject.toLowerCase().contains(q))
            .toList();

    final children = <Widget>[
      AppTextField(
        controller: _search,
        hint: 'Search chats',
        prefixIcon: Icons.search_rounded,
        textInputAction: TextInputAction.search,
        onChanged: (v) => setState(() => _query = v),
      ),
      const SizedBox(height: AppSpacing.md),
    ];

    if (filtered.isEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxl),
        child: Text('No chats match "$_query".',
            style: AppText.bodyM.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
      ));
    } else {
      String? group;
      for (final c in filtered) {
        final g = dayGroup(c.updatedAt);
        if (g != group) {
          group = g;
          children.add(Padding(
            padding:
                const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
            child: SectionHeader(title: g),
          ));
        }
        children.add(Dismissible(
          key: ValueKey(c.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _swipeDelete(c),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.tint(AppColors.error, 0.16),
              borderRadius: AppRadius.cardAll,
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
          ),
          child: ChatHistoryTile(chat: c),
        ));
      }
    }
    // Room for the FAB.
    children.add(const SizedBox(height: 88));

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: children,
    );
  }
}

/// One chat in a history list.
class ChatHistoryTile extends StatelessWidget {
  const ChatHistoryTile({super.key, required this.chat});

  final ChatSession chat;

  @override
  Widget build(BuildContext context) {
    final subject = subjectByName(chat.subject);
    final icon = subject == null
        ? Icons.menu_book_rounded
        : iconForCategory(subject.category);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: IconBadge(icon: icon),
      title: Text(chat.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${chat.subject}, ${relativeTime(chat.updatedAt)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => openChat(context, chat.id, subject: chat.subject),
    );
  }
}
