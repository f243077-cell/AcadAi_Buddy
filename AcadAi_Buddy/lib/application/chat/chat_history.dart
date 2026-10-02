import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_ai_app/application/auth/auth_notifier.dart';
import 'package:study_ai_app/domain/study/entities/chat_session.dart';
import 'package:study_ai_app/domain/study/repositories/i_chat_repositories.dart';
import 'package:study_ai_app/infrastructure/study/firebase_chat_repository.dart';

/// The signed-in user's chats, most recently updated first.
final chatHistoryProvider =
    StreamProvider.autoDispose<List<ChatSession>>((ref) {
  final uid = ref.watch(currentUserProvider.select((u) => u?.id));
  if (uid == null) return Stream.value(const []);
  return ref.watch(firebaseChatRepositoryProvider).watchChats(uid);
});

/// Distinct subjects from recent chats (max 8), newest first.
final recentSubjectsProvider = Provider.autoDispose<List<String>>((ref) {
  final chats = ref.watch(chatHistoryProvider).valueOrNull ?? const [];
  final seen = <String>{};
  for (final c in chats) {
    if (c.subject.trim().isNotEmpty) seen.add(c.subject);
    if (seen.length == 8) break;
  }
  return seen.toList();
});

/// History-level actions that are not tied to an open chat screen.
class ChatHistoryActions {
  const ChatHistoryActions(this._repo);

  final IChatRepository _repo;

  /// Not awaited by callers: offline, the commit completes later.
  Future<void> delete(String chatId) =>
      _repo.deleteChat(chatId).catchError((_) {});
}

final chatHistoryActionsProvider = Provider<ChatHistoryActions>(
  (ref) => ChatHistoryActions(ref.watch(firebaseChatRepositoryProvider)),
);
