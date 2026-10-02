/// Metadata for one tutor conversation (`chats/{id}`).
///
/// Pure Dart — no Firebase or external imports.
class ChatSession {
  const ChatSession({
    required this.id,
    required this.ownerId,
    required this.subject,
    required this.title,
    required this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String subject;

  /// Auto-set from the first user message; the user can rename it.
  final String title;
  final String lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Title derived from the first message: first 40 characters, one line.
  static String titleFrom(String firstMessage) {
    final oneLine = firstMessage.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (oneLine.isEmpty) return 'Image question';
    return oneLine.length <= 40 ? oneLine : '${oneLine.substring(0, 40).trimRight()}…';
  }

  ChatSession copyWith({
    String? subject,
    String? title,
    String? lastMessage,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id,
      ownerId: ownerId,
      subject: subject ?? this.subject,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatSession &&
          id == other.id &&
          ownerId == other.ownerId &&
          subject == other.subject &&
          title == other.title &&
          lastMessage == other.lastMessage &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
      id, ownerId, subject, title, lastMessage, createdAt, updatedAt);
}
