import '../entities/chat_message.dart';
import '../entities/chat_session.dart';

/// Abstract contract for chat persistence.
///
/// Layout: `chats/{chatId}` holds [ChatSession] metadata (with `ownerId`);
/// `chats/{chatId}/messages/{id}` holds the messages.
///
/// Writes are applied to the local cache immediately; the returned future
/// completes on server acknowledgement, which never comes while offline, so
/// UI code must not await it.
abstract class IChatRepository {
  /// Persists [message] on its own (no metadata update).
  Future<void> saveMessage(ChatMessage message);

  /// Writes [message] and updates [session] metadata in one batch. Creates
  /// the chat document on the first message.
  Future<void> addMessage(ChatSession session, ChatMessage message);

  /// Real-time stream of the messages in [chatId], oldest first.
  Stream<List<ChatMessage>> getMessages(String chatId);

  /// The chat document, or null if it does not exist yet.
  Stream<ChatSession?> watchChat(String chatId);

  /// All chats owned by [ownerId], most recently updated first.
  Stream<List<ChatSession>> watchChats(String ownerId);

  /// Creates or updates the chat metadata.
  Future<void> upsertChat(ChatSession session);

  Future<void> deleteMessage(String chatId, String messageId);

  /// Deletes every message but keeps the chat document.
  Future<void> clearMessages(ChatSession session);

  /// Deletes the chat document and all of its messages.
  Future<void> deleteChat(String chatId);
}
