import 'package:study_ai_app/domain/study/entities/chat_message.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  const ChatLoaded(this.messages);
}

class ChatSending extends ChatState {
  final List<ChatMessage> messages;
  const ChatSending(this.messages);
}

class ChatFailureState extends ChatState {
  final String error;
  const ChatFailureState(this.error);
}
