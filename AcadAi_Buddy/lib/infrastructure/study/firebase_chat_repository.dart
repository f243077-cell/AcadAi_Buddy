import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:study_ai_app/domain/study/entities/chat_session.dart';
import 'package:study_ai_app/domain/study/repositories/i_chat_repositories.dart';

import 'package:study_ai_app/infrastructure/core/firebase_injectable.dart';
import 'package:study_ai_app/infrastructure/study/dtos/chat_message_dtos.dart';
import 'package:study_ai_app/infrastructure/study/dtos/chat_session_dto.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseChatRepositoryProvider = Provider<IChatRepository>(
  (ref) => FirebaseChatRepository(ref.watch(firestoreProvider)),
);

/// Firestore implementation of [IChatRepository].
///
/// Every write is applied to the local cache immediately; the returned
/// future completes on server acknowledgement, so the UI must not await it.
class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;

  FirebaseChatRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _chats.doc(chatId).collection('messages');

  @override
  Future<void> saveMessage(ChatMessage message) {
    return _messages(message.chatId)
        .doc(message.id)
        .set(ChatMessageDto.fromDomain(message).toJson());
  }

  @override
  Future<void> addMessage(ChatSession session, ChatMessage message) {
    final batch = _firestore.batch()
      ..set(_chats.doc(session.id), ChatSessionDto(session).toJson(),
          SetOptions(merge: true))
      ..set(_messages(session.id).doc(message.id),
          ChatMessageDto.fromDomain(message).toJson());
    return batch.commit();
  }

  @override
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _messages(chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageDto.fromJson(doc.data()).toDomain())
            .toList());
  }

  @override
  Stream<ChatSession?> watchChat(String chatId) {
    return _chats.doc(chatId).snapshots().map((doc) {
      final data = doc.data();
      return data == null ? null : ChatSessionDto.fromJson(doc.id, data);
    });
  }

  @override
  Stream<List<ChatSession>> watchChats(String ownerId) {
    // Sorted on the client so no composite index is required.
    return _chats.where('ownerId', isEqualTo: ownerId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((d) => ChatSessionDto.fromJson(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
        );
  }

  @override
  Future<void> upsertChat(ChatSession session) {
    return _chats
        .doc(session.id)
        .set(ChatSessionDto(session).toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) {
    return _messages(chatId).doc(messageId).delete();
  }

  @override
  Future<void> clearMessages(ChatSession session) async {
    final docs = await _messages(session.id).get();
    final batch = _firestore.batch();
    for (final d in docs.docs) {
      batch.delete(d.reference);
    }
    batch.set(
      _chats.doc(session.id),
      ChatSessionDto(session.copyWith(
        lastMessage: '',
        updatedAt: DateTime.now(),
      )).toJson(),
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final docs = await _messages(chatId).get();
    final batch = _firestore.batch();
    for (final d in docs.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_chats.doc(chatId));
    await batch.commit();
  }
}
