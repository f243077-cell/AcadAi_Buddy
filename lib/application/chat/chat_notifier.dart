import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:study_ai_app/application/chat/chat_state.dart';
import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:study_ai_app/domain/study/repositories/i_chat_repositories.dart';
import 'package:study_ai_app/infrastructure/study/gemini_service.dart';
import 'package:study_ai_app/infrastructure/study/firebase_chat_repository.dart';

class ChatNotifier extends StateNotifier<ChatState> {
  final IChatRepository _chatRepository;
  final GeminiService _geminiService;
  final _uuid = const Uuid();
  StreamSubscription? _messagesSubscription;

  ChatNotifier(this._chatRepository, this._geminiService)
      : super(const ChatInitial());

  Future<void> loadMessages(String chatId) async {
    // ✅ Only show loading on FIRST load
    if (state is ChatInitial) {
      state = const ChatLoading();
    }

    await _messagesSubscription?.cancel();

    _messagesSubscription = _chatRepository.getMessages(chatId).listen(
      (messages) {
        // ✅ Never touch state if sending
        if (state is ChatSending) return;
        state = ChatLoaded(messages);
      },
      onError: (e) {
        state = ChatFailureState(e.toString());
      },
    );
  }

  Future<void> sendMessage(String text, String chatId, String subject) async {
    final currentMessages = _currentMessages;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      imageUrl: null,
      chatId: chatId,
    );

    // ✅ Show user message immediately
    state = ChatSending([...currentMessages, userMessage]);

    try {
      // ✅ Get AI response first
      final aiResponse = await _geminiService.sendMessage(text, subject);

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: aiResponse,
        role: MessageRole.model,
        timestamp: DateTime.now(),
        imageUrl: null,
        chatId: chatId,
      );

      // ✅ Update UI immediately with both messages
      final updatedMessages = [
        ...currentMessages,
        userMessage,
        aiMessage,
      ];
      state = ChatLoaded(updatedMessages);

      // ✅ Save to Firestore in background
      // (don't await — no blocking!)
      _chatRepository.saveMessage(userMessage);
      _chatRepository.saveMessage(aiMessage);
    } catch (e) {
      // ✅ On error keep user message visible
      state = ChatLoaded([...currentMessages, userMessage]);
      // Show error via snackbar in UI
      state = ChatFailureState(e.toString());
    }
  }

  Future<void> sendImageMessage(
      String text, Uint8List imageBytes, String chatId) async {
    final currentMessages = _currentMessages;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      imageUrl: null,
      chatId: chatId,
    );

    state = ChatSending([...currentMessages, userMessage]);

    try {
      final aiResponse =
          await _geminiService.sendImageMessage(text, imageBytes);

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: aiResponse,
        role: MessageRole.model,
        timestamp: DateTime.now(),
        imageUrl: null,
        chatId: chatId,
      );

      final updatedMessages = [
        ...currentMessages,
        userMessage,
        aiMessage,
      ];
      state = ChatLoaded(updatedMessages);

      // Save in background
      _chatRepository.saveMessage(userMessage);
      _chatRepository.saveMessage(aiMessage);
    } catch (e) {
      state = ChatLoaded([...currentMessages, userMessage]);
      state = ChatFailureState(e.toString());
    }
  }

  void clearChat() {
    _messagesSubscription?.cancel();
    state = const ChatInitial();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  List<ChatMessage> get _currentMessages {
    final s = state;
    if (s is ChatLoaded) return s.messages;
    if (s is ChatSending) return s.messages;
    return [];
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.watch(firebaseChatRepositoryProvider),
    ref.watch(geminiServiceProvider),
  );
});
