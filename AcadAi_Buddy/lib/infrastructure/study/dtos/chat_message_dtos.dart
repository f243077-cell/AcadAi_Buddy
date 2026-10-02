import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageDto {
  final String id;
  final String content;
  final String role; // 'user' or 'model'
  final DateTime timestamp;
  final String? imageUrl;
  final String chatId;
  final bool hasImage;

  const ChatMessageDto({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.imageUrl,
    required this.chatId,
    this.hasImage = false,
  });

  factory ChatMessageDto.fromDomain(ChatMessage message) {
    return ChatMessageDto(
      id: message.id,
      content: message.content,
      role: message.role == MessageRole.user ? 'user' : 'model',
      timestamp: message.timestamp,
      imageUrl: message.imageUrl,
      chatId: message.chatId,
      hasImage: message.hasImage || message.imageBytes != null,
    );
  }

  ChatMessage toDomain() {
    return ChatMessage(
      id: id,
      content: content,
      role: role == 'user' ? MessageRole.user : MessageRole.model,
      timestamp: timestamp,
      imageUrl: imageUrl,
      chatId: chatId,
      hasImage: hasImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'chatId': chatId,
      'hasImage': hasImage,
    };
  }

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    final rawTimestamp = json['timestamp'];
    final DateTime parsedTimestamp;

    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is DateTime) {
      parsedTimestamp = rawTimestamp;
    } else {
      parsedTimestamp = DateTime.now();
    }

    return ChatMessageDto(
      id: (json['id'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      role: (json['role'] ?? 'model').toString(),
      timestamp: parsedTimestamp,
      imageUrl: json['imageUrl'] as String?,
      chatId: (json['chatId'] ?? '').toString(),
      hasImage: json['hasImage'] == true,
    );
  }
}
