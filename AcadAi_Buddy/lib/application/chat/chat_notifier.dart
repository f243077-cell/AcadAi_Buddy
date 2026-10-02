import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:study_ai_app/application/auth/auth_notifier.dart';
import 'package:study_ai_app/application/chat/chat_state.dart';
import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:study_ai_app/domain/study/entities/chat_session.dart';
import 'package:study_ai_app/domain/study/repositories/i_ai_repository.dart';
import 'package:study_ai_app/domain/study/repositories/i_chat_repositories.dart';
import 'package:study_ai_app/domain/study/subject_catalogue.dart';
import 'package:study_ai_app/infrastructure/study/ai_service.dart';
import 'package:study_ai_app/infrastructure/study/firebase_chat_repository.dart';

/// Identifies one chat screen: the chat id plus the subject it was opened
/// with (used until the chat document says otherwise).
typedef ChatArgs = ({String chatId, String? subject});

/// Owns one conversation.
///
/// Firestore messages are merged with local ones (optimistic sends and
/// in-memory image bytes). The user's message is saved before the AI is
/// asked; on failure every message stays and the failed one is marked.
/// A request id guard means a superseded reply never changes the state, and
/// a reply that arrives after the screen closed is still saved to its own
/// chat but touches no state.
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier({
    required this.chatId,
    required IChatRepository repository,
    required IAiRepository ai,
    required String? ownerId,
    String? initialSubject,
  })  : _repo = repository,
        _ai = ai,
        _ownerId = ownerId,
        super(ChatState(subject: initialSubject ?? kGeneralSubject)) {
    _chatSub = _repo.watchChat(chatId).listen(
          _onSession,
          onError: (_) => _onSession(null),
        );
  }

  final String chatId;
  final IChatRepository _repo;
  final IAiRepository _ai;
  final String? _ownerId;
  final _uuid = const Uuid();

  StreamSubscription<ChatSession?>? _chatSub;
  StreamSubscription<List<ChatMessage>>? _msgSub;
  Timer? _resubscribe;

  ChatSession? _session;
  List<ChatMessage> _remote = const [];
  final Map<String, ChatMessage> _local = {};
  final Set<String> _hidden = {};
  int _requestId = 0;

  // ── Streams ───────────────────────────────────────────────────────────────

  void _onSession(ChatSession? s) {
    if (!mounted) return;
    if (s != null) {
      _session = s;
      state = state.copyWith(session: s, subject: s.subject);
      _subscribeMessages();
    } else if (_session == null && state.status == ChatStatus.loading) {
      // A brand-new chat: nothing to load until the first message.
      state = state.copyWith(status: ChatStatus.idle);
    }
  }

  void _subscribeMessages() {
    if (!mounted || _msgSub != null) return;
    _msgSub = _repo.getMessages(chatId).listen(
      (messages) {
        _remote = messages;
        if (state.status == ChatStatus.loading) {
          state = state.copyWith(status: ChatStatus.idle);
        }
        _emit();
      },
      onError: (_) {
        // Usually the chat document has not reached the server yet.
        _msgSub = null;
        if (state.status == ChatStatus.loading) {
          state = state.copyWith(status: ChatStatus.idle);
        }
        _resubscribe?.cancel();
        _resubscribe = Timer(const Duration(seconds: 3), _subscribeMessages);
      },
    );
  }

  void _emit() {
    if (!mounted) return;
    final byId = <String, ChatMessage>{for (final m in _remote) m.id: m};
    for (final l in _local.values.toList()) {
      final r = byId[l.id];
      if (r == null) {
        byId[l.id] = l;
      } else if (l.imageBytes != null) {
        byId[l.id] = r.copyWith(imageBytes: l.imageBytes);
      } else {
        _local.remove(l.id); // Firestore has it now.
      }
    }
    final list = byId.values.where((m) => !_hidden.contains(m.id)).toList()
      ..sort((a, b) {
        final t = a.timestamp.compareTo(b.timestamp);
        if (t != 0) return t;
        return a.role == MessageRole.user ? -1 : 1;
      });
    state = state.copyWith(messages: list);
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  static String _preview(ChatMessage m) {
    final text = m.content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isEmpty) return m.hasImage ? 'Image' : '';
    return text.length <= 120 ? text : '${text.substring(0, 120)}…';
  }

  /// Saves [m] and updates the chat metadata, creating the chat on the
  /// first message. Never awaited: offline writes only complete later.
  void _persist(ChatMessage m, String subject) {
    final owner = _ownerId;
    if (owner == null) return;
    final now = DateTime.now();
    final isNew = _session == null;
    final session = (_session ??
            ChatSession(
              id: chatId,
              ownerId: owner,
              subject: subject,
              title: ChatSession.titleFrom(m.content),
              lastMessage: '',
              createdAt: now,
              updatedAt: now,
            ))
        .copyWith(lastMessage: _preview(m), updatedAt: now);
    _session = session;
    if (mounted) state = state.copyWith(session: session);

    _repo.addMessage(session, m).then(
      (_) {
        if (isNew) _subscribeMessages();
      },
      onError: (_) {},
    );
    if (isNew) {
      // The local cache already has the chat; listen right away too.
      Future<void>.microtask(_subscribeMessages);
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Sends [text] (and optionally an image). Ignored while a reply is being
  /// generated; the text field itself stays enabled.
  Future<void> send(String text, {Uint8List? image}) async {
    if (state.isSending) return;
    final content = text.trim();
    if (content.isEmpty && image == null) return;

    final msg = ChatMessage(
      id: _uuid.v4(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      chatId: chatId,
      imageBytes: image,
      hasImage: image != null,
    );
    _local[msg.id] = msg;
    state = state.copyWith(
        status: ChatStatus.sending, clearFailed: true, clearError: true);
    _emit();
    _persist(msg, state.subject);
    await _ask(msg);
  }

  Future<void> _ask(ChatMessage userMsg) async {
    final id = ++_requestId;
    final subject = state.subject;
    final history = state.messages
        .where((m) => !m.timestamp.isAfter(userMsg.timestamp))
        .toList();

    final result = await _ai.chat(
      subject: subject,
      history: history,
      imageBytes: userMsg.imageBytes,
    );
    if (id != _requestId) return; // superseded by a retry or regenerate

    result.fold(
      (failure) {
        if (!mounted) return;
        state = state.copyWith(
          status: ChatStatus.idle,
          failedMessageId: userMsg.id,
          error: failure,
        );
      },
      (text) {
        final now = DateTime.now();
        final reply = ChatMessage(
          id: _uuid.v4(),
          content: text,
          role: MessageRole.model,
          timestamp: now.isAfter(userMsg.timestamp)
              ? now
              : userMsg.timestamp.add(const Duration(milliseconds: 1)),
          chatId: chatId,
        );
        // Saved to this chat even if the screen has closed meanwhile.
        _persist(reply, subject);
        if (!mounted) return;
        _local[reply.id] = reply;
        state = state.copyWith(status: ChatStatus.idle, clearFailed: true);
        _emit();
      },
    );
  }

  /// Asks again for the message marked "Not sent".
  Future<void> retry() async {
    final failedId = state.failedMessageId;
    if (failedId == null || state.isSending) return;
    final matches = state.messages.where((m) => m.id == failedId);
    if (matches.isEmpty) return;
    state = state.copyWith(
        status: ChatStatus.sending, clearFailed: true, clearError: true);
    await _ask(matches.first);
  }

  /// Replaces the last tutor reply with a new one.
  Future<void> regenerate() async {
    if (!state.canRegenerate) return;
    final last = state.messages.last;
    final users = state.messages.where((m) => m.role == MessageRole.user);
    if (users.isEmpty) return;
    final userMsg = users.last;

    _hidden.add(last.id);
    _local.remove(last.id);
    _repo.deleteMessage(chatId, last.id).catchError((_) {});
    state = state.copyWith(
        status: ChatStatus.sending, clearFailed: true, clearError: true);
    _emit();
    await _ask(userMsg);
  }

  void clearError() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  void changeSubject(String subject) {
    if (subject == state.subject) return;
    state = state.copyWith(subject: subject);
    final s = _session;
    if (s != null) {
      _session = s.copyWith(subject: subject);
      _repo.upsertChat(_session!).catchError((_) {});
      state = state.copyWith(session: _session);
    }
  }

  void rename(String title) {
    final s = _session;
    final t = title.trim();
    if (s == null || t.isEmpty) return;
    _session = s.copyWith(title: t);
    state = state.copyWith(session: _session);
    _repo.upsertChat(_session!).catchError((_) {});
  }

  /// Removes every message but keeps the chat.
  void clear() {
    _requestId++;
    _hidden.addAll(state.messages.map((m) => m.id));
    _local.clear();
    final s = _session;
    if (s != null) {
      _session = s.copyWith(lastMessage: '');
      _repo.clearMessages(s).catchError((_) {});
    }
    state = state.copyWith(
      status: ChatStatus.idle,
      session: _session,
      clearFailed: true,
      clearError: true,
    );
    _emit();
  }

  /// Deletes the chat and its messages. The caller leaves the screen.
  Future<void> delete() async {
    _requestId++;
    await _chatSub?.cancel();
    await _msgSub?.cancel();
    _chatSub = null;
    _msgSub = null;
    if (_session != null) {
      // Not awaited: offline, the commit only completes once back online.
      _repo.deleteChat(chatId).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    _msgSub?.cancel();
    _resubscribe?.cancel();
    super.dispose();
  }
}

final chatNotifierProvider = StateNotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, ChatArgs>((ref, args) {
  return ChatNotifier(
    chatId: args.chatId,
    initialSubject: args.subject,
    repository: ref.watch(firebaseChatRepositoryProvider),
    ai: ref.watch(aiRepositoryProvider),
    ownerId: ref.read(currentUserProvider)?.id,
  );
});
