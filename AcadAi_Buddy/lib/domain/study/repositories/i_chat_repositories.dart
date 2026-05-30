import '../entities/chat_message.dart';

/// Abstract contract for chat message persistence operations.
///
/// Implementations live in `infrastructure/study/`.
abstract class IChatRepository {
  /// Persists [message] to the remote store.
  ///
  /// Throws if the operation fails (callers should wrap in try/catch or
  /// convert to an Either at the application layer).
  Future<void> saveMessage(ChatMessage message);

  /// Returns a real-time stream of all messages belonging to [chatId],
  /// ordered by [ChatMessage.timestamp] ascending.
  ///
  /// The stream emits a new list every time the underlying Firestore
  /// collection changes.
  Stream<List<ChatMessage>> getMessages(String chatId);
}
