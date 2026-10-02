import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../application/chat/chat_history.dart';
import '../../../../application/chat/chat_notifier.dart';
import '../../../../application/chat/chat_state.dart';
import '../../../../domain/core/failures.dart';
import '../../../../domain/study/entities/chat_message.dart';
import '../../../../domain/study/subject_catalogue.dart';
import '../../../core/subject_icons.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_snack.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/subject_sheet.dart';
import 'widgets/chat_composer.dart';
import 'widgets/message_bubble.dart';

enum _MenuAction { rename, clear, delete }

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    required this.chatId,
    this.subject,
    this.prefill,
  });

  final String chatId;

  /// Subject the chat was opened with (a new chat uses it).
  final String? subject;

  /// Text placed in the composer without sending.
  final String? prefill;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late final TextEditingController _input =
      TextEditingController(text: widget.prefill ?? '');
  final _scroll = ScrollController();
  bool _showJump = false;

  ChatArgs get _args => (chatId: widget.chatId, subject: widget.subject);
  ChatNotifier get _notifier => ref.read(chatNotifierProvider(_args).notifier);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final show = _scroll.hasClients && _scroll.offset > 300;
      if (show != _showJump) setState(() => _showJump = show);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text, Uint8List? image) {
    _notifier.send(text, image: image);
    if (_scroll.hasClients) {
      _scroll.animateTo(0,
          duration: AppMotion.of(context, AppMotion.normal),
          curve: AppMotion.curve);
    }
  }

  Future<void> _pickSubject(String current) async {
    final chosen = await SubjectSheet.show(
      context,
      current: current,
      recents: ref.read(recentSubjectsProvider),
    );
    if (chosen != null) _notifier.changeSubject(chosen);
  }

  Future<void> _onMenu(_MenuAction action, ChatState s) async {
    switch (action) {
      case _MenuAction.rename:
        final title = await showDialog<String>(
          context: context,
          builder: (_) => _RenameDialog(initial: s.title),
        );
        if (title != null) _notifier.rename(title);
      case _MenuAction.clear:
        final ok = await _confirm(
          title: 'Clear this chat?',
          body: 'All messages are removed. The chat stays in your history.',
          action: 'Clear',
        );
        if (ok) _notifier.clear();
      case _MenuAction.delete:
        final ok = await _confirm(
          title: 'Delete this chat?',
          body: 'The chat and all of its messages are deleted.',
          action: 'Delete',
        );
        if (!ok) return;
        await _notifier.delete();
        if (mounted) context.pop();
    }
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String action,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = chatNotifierProvider(_args);
    final s = ref.watch(provider);

    ref.listen<AiFailure?>(provider.select((s) => s.error), (_, error) {
      if (error == null) return;
      AppSnack.show(
        context,
        error.message,
        tone: SnackTone.error,
        actionLabel: error.isRetriable ? 'Retry' : null,
        onAction: _notifier.retry,
      );
      _notifier.clearError();
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Semantics(
          button: true,
          hint: 'Change subject',
          child: InkWell(
            onTap: () => _pickSubject(s.subject),
            borderRadius: AppRadius.inputAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.title,
                      style: AppText.titleS,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(s.subject,
                      style:
                          AppText.caption.copyWith(color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<_MenuAction>(
            tooltip: 'More',
            icon: const Icon(Icons.more_vert_rounded),
            enabled: s.session != null,
            onSelected: (a) => _onMenu(a, s),
            itemBuilder: (_) => const [
              PopupMenuItem(value: _MenuAction.rename, child: Text('Rename')),
              PopupMenuItem(value: _MenuAction.clear, child: Text('Clear')),
              PopupMenuItem(
                value: _MenuAction.delete,
                child: Text('Delete',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _body(s),
                Positioned(
                  right: AppSpacing.chatScreen,
                  bottom: AppSpacing.md,
                  child: AnimatedScale(
                    scale: _showJump ? 1 : 0,
                    duration: AppMotion.of(context, AppMotion.fast),
                    child: FloatingActionButton.small(
                      heroTag: null,
                      tooltip: 'Scroll to latest',
                      backgroundColor: AppColors.surfaceAlt,
                      foregroundColor: AppColors.textPrimary,
                      onPressed: () => _scroll.animateTo(0,
                          duration: AppMotion.of(context, AppMotion.normal),
                          curve: AppMotion.curve),
                      child: const Icon(Icons.arrow_downward_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ChatComposer(
            controller: _input,
            subject: s.subject,
            sending: s.isSending,
            onSend: _send,
            onSubjectTap: () => _pickSubject(s.subject),
          ),
        ],
      ),
    );
  }

  Widget _body(ChatState s) {
    if (s.status == ChatStatus.loading && s.messages.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.chatScreen),
        child: Column(children: [SkeletonParagraph(), SkeletonParagraph()]),
      );
    }
    if (s.messages.isEmpty && !s.isSending) {
      return _ChatEmptyState(
        subject: s.subject,
        onSuggestion: (text) => _send(text, null),
      );
    }

    // Newest first, because the list is reversed.
    final items = <Widget>[];
    if (s.isSending) items.add(const TypingRow());
    final lastIndex = s.messages.length - 1;
    for (var i = lastIndex; i >= 0; i--) {
      final m = s.messages[i];
      items.add(m.role == MessageRole.user
          ? UserBubble(
              key: ValueKey(m.id),
              message: m,
              failed: s.failedMessageId == m.id,
              onRetry: _notifier.retry,
            )
          : AiMessage(
              key: ValueKey(m.id),
              message: m,
              onRegenerate:
                  i == lastIndex && s.canRegenerate ? _notifier.regenerate : null,
            ));
      final prev = i > 0 ? s.messages[i - 1] : null;
      if (prev == null || !DateUtils.isSameDay(prev.timestamp, m.timestamp)) {
        items.add(DateSeparator(date: m.timestamp));
      }
    }

    return ListView.separated(
      controller: _scroll,
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.chatScreen),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (_, i) => items[i],
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState({required this.subject, required this.onSuggestion});

  final String subject;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final topic = subjectByName(subject)?.topics.first ?? subject;
    final suggestions = [
      'Explain $topic simply',
      'Give me practice problems',
      'Summarize the key ideas',
      'Quiz me on this',
    ];
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Center(child: IconBadge(icon: iconForSubject(subject), size: 56)),
        const SizedBox(height: AppSpacing.lg),
        Text('What are we studying?',
            style: AppText.titleM, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ask anything about $subject, or try one of these.',
          style: AppText.bodyM.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final s in suggestions)
              ActionChip(label: Text(s), onPressed: () => onSuggestion(s)),
          ],
        ),
      ],
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final t = _controller.text.trim();
    if (t.isNotEmpty) Navigator.of(context).pop(t);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename chat'),
      content: AppTextField(
        controller: _controller,
        autofocus: true,
        maxLength: 60,
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
