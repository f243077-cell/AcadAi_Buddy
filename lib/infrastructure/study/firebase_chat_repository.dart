import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:study_ai_app/domain/study/repositories/i_chat_repositories.dart';

import 'package:study_ai_app/infrastructure/core/firebase_injectable.dart';
import 'package:study_ai_app/infrastructure/study/dtos/chat_message_dtos.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseChatRepositoryProvider = Provider<IChatRepository>(
  (ref) => FirebaseChatRepository(ref.watch(firestoreProvider)),
);

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;

  FirebaseChatRepository(this._firestore);

  @override
  Future<void> saveMessage(ChatMessage message) async {
    final dto = ChatMessageDto.fromDomain(message);
    await _firestore
        .collection('chats')
        .doc(message.chatId)
        .collection('messages')
        .doc(message.id)
        .set(dto.toJson());
  }

  @override
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessageDto.fromJson(doc.data()).toDomain();
      }).toList();
    });
  }
}
