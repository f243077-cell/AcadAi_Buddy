import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:study_ai_app/domain/study/entities/chat_session.dart';

enum ChatStatus { loading, idle, sending }

/// One state for the whole conversation. [messages] are never dropped, even
/// after a failure.
class ChatState {
  const ChatState({
    this.messages = const [],
    this.status = ChatStatus.loading,
    this.subject = 'General',
    this.session,
    this.failedMessageId,
    this.error,
  });

  final List<ChatMessage> messages;
  final ChatStatus status;
  final String subject;

  /// Chat metadata; null until the first message creates the chat.
  final ChatSession? session;

  /// User message whose reply failed; the UI shows "Not sent. Retry".
  final String? failedMessageId;

  /// One-shot error: the UI shows a snackbar, then calls `clearError()`.
  final AiFailure? error;

  bool get isSending => status == ChatStatus.sending;
  String get title => session?.title ?? 'New chat';

  /// Whether the last message is a tutor reply that can be regenerated.
  bool get canRegenerate =>
      !isSending &&
      messages.isNotEmpty &&
      messages.last.role == MessageRole.model;

  ChatState copyWith({
    List<ChatMessage>? messages,
    ChatStatus? status,
    String? subject,
    ChatSession? session,
    String? failedMessageId,
    bool clearFailed = false,
    AiFailure? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      session: session ?? this.session,
      failedMessageId:
          clearFailed ? null : (failedMessageId ?? this.failedMessageId),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
