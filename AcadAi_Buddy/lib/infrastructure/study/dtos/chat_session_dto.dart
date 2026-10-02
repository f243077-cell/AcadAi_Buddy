import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_ai_app/domain/study/entities/chat_session.dart';

class ChatSessionDto {
  const ChatSessionDto(this.session);

  final ChatSession session;

  Map<String, dynamic> toJson() => {
        'id': session.id,
        'ownerId': session.ownerId,
        'subject': session.subject,
        'title': session.title,
        'lastMessage': session.lastMessage,
        'createdAt': Timestamp.fromDate(session.createdAt),
        'updatedAt': Timestamp.fromDate(session.updatedAt),
      };

  static DateTime _date(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    // Pending server timestamps read back as null.
    return DateTime.now();
  }

  static ChatSession fromJson(String id, Map<String, dynamic> json) {
    return ChatSession(
      id: id,
      ownerId: (json['ownerId'] ?? '').toString(),
      subject: (json['subject'] ?? 'General').toString(),
      title: (json['title'] ?? 'Untitled chat').toString(),
      lastMessage: (json['lastMessage'] ?? '').toString(),
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }
}
