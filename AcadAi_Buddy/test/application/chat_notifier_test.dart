import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_ai_app/application/chat/chat_notifier.dart';
import 'package:study_ai_app/application/chat/chat_state.dart';
import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:study_ai_app/domain/study/entities/chat_session.dart';
import 'package:study_ai_app/domain/study/entities/quiz_message.dart';
import 'package:study_ai_app/domain/study/entities/study_options.dart';
import 'package:study_ai_app/domain/study/repositories/i_ai_repository.dart';
import 'package:study_ai_app/domain/study/repositories/i_chat_repositories.dart';

/// In-memory repository; "offline" writes never complete, like Firestore.
class FakeChatRepo implements IChatRepository {
  FakeChatRepo({this.offline = false});

  final bool offline;
  final saved = <ChatMessage>[];
  final sessions = <String, ChatSession>{};
  final deleted = <String>[];
  final _chat = StreamController<ChatSession?>.broadcast();

  Future<void> _write() =>
      offline ? Completer<void>().future : Future<void>.value();

  @override
  Future<void> addMessage(ChatSession session, ChatMessage message) {
    sessions[session.id] = session;
    saved.add(message);
    return _write();
  }

  @override
  Future<void> saveMessage(ChatMessage message) {
    saved.add(message);
    return _write();
  }

  @override
  Stream<List<ChatMessage>> getMessages(String chatId) =>
      Stream.value(saved.where((m) => m.chatId == chatId).toList());

  @override
  Stream<ChatSession?> watchChat(String chatId) async* {
    yield sessions[chatId];
    yield* _chat.stream;
  }

  @override
  Stream<List<ChatSession>> watchChats(String ownerId) =>
      Stream.value(sessions.values.toList());

  @override
  Future<void> upsertChat(ChatSession session) {
    sessions[session.id] = session;
    return _write();
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) {
    deleted.add(messageId);
    return _write();
  }

  @override
  Future<void> clearMessages(ChatSession session) => _write();

  @override
  Future<void> deleteChat(String chatId) => _write();
}

class FakeAi implements IAiRepository {
  final requests = <List<ChatMessage>>[];
  Completer<Either<AiFailure, String>>? pending;
  Either<AiFailure, String> next = right('answer');

  @override
  Future<Either<AiFailure, String>> chat({
    required String subject,
    required List<ChatMessage> history,
    Uint8List? imageBytes,
  }) {
    requests.add(history);
    if (pending != null) return pending!.future;
    return Future.value(next);
  }

  @override
  Future<Either<AiFailure, String>> describeImage(
          {required String prompt, required Uint8List bytes}) async =>
      right('');

  @override
  Future<Either<AiFailure, List<QuizQuestion>>> generateQuiz({
    required String subject,
    String? topic,
    required int count,
    QuizDifficulty difficulty = QuizDifficulty.medium,
    String? sourceText,
  }) async =>
      right(const []);

  @override
  Future<Either<AiFailure, String>> summarize(
          {String? text,
          Uint8List? imageBytes,
          SummaryStyle style = SummaryStyle.keyPoints}) async =>
      right('');
}

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 5));

void main() {
  ChatNotifier make(FakeChatRepo repo, FakeAi ai, [String id = 'c1']) =>
      ChatNotifier(
        chatId: id,
        repository: repo,
        ai: ai,
        ownerId: 'u1',
        initialSubject: 'Data Structures & Algorithms',
      );

  test('new chat becomes idle and keeps the opening subject', () async {
    final n = make(FakeChatRepo(), FakeAi());
    await _settle();
    expect(n.state.status, ChatStatus.idle);
    expect(n.state.subject, 'Data Structures & Algorithms');
  });

  test('offline failure keeps the whole conversation and marks the message',
      () async {
    final repo = FakeChatRepo(offline: true);
    final ai = FakeAi();
    final n = make(repo, ai);
    await _settle();

    await n.send('What is a stack?');
    expect(n.state.messages.length, 2);

    ai.next = left(AiFailure.offline);
    await n.send('And a queue?');
    expect(n.state.messages.length, 3, reason: 'nothing vanishes');
    expect(n.state.messages.last.content, 'And a queue?');
    expect(n.state.failedMessageId, n.state.messages.last.id);
    expect(n.state.error, AiFailure.offline);
    expect(n.state.status, ChatStatus.idle);
    // The user message was saved before the AI was asked.
    expect(repo.saved.any((m) => m.content == 'And a queue?'), isTrue);

    ai.next = right('A queue is FIFO.');
    await n.retry();
    expect(n.state.failedMessageId, isNull);
    expect(n.state.messages.last.content, 'A queue is FIFO.');
  });

  test('a follow-up sends the earlier turns as history', () async {
    final ai = FakeAi();
    final n = make(FakeChatRepo(), ai);
    await _settle();
    await n.send('Explain recursion');
    await n.send('Explain that again simpler');
    final history = ai.requests.last;
    expect(history.map((m) => m.content), [
      'Explain recursion',
      'answer',
      'Explain that again simpler',
    ]);
  });

  test('first message creates the chat with owner, subject and title',
      () async {
    final repo = FakeChatRepo();
    final n = make(repo, FakeAi());
    await _settle();
    await n.send('What is the base case in recursion?');
    final s = repo.sessions['c1']!;
    expect(s.ownerId, 'u1');
    expect(s.subject, 'Data Structures & Algorithms');
    expect(s.title, 'What is the base case in recursion?');
    expect(s.lastMessage, 'answer');
  });

  test('a reply that lands after the screen closed is saved to its own chat',
      () async {
    final repo = FakeChatRepo();
    final ai = FakeAi()..pending = Completer();
    final n = make(repo, ai);
    await _settle();
    final sending = n.send('Slow question');
    await _settle();
    n.dispose();

    ai.pending!.complete(right('late answer'));
    await sending; // must not throw after dispose
    final late = repo.saved.firstWhere((m) => m.content == 'late answer');
    expect(late.chatId, 'c1');
  });

  test('regenerate replaces the last answer', () async {
    final repo = FakeChatRepo();
    final ai = FakeAi();
    final n = make(repo, ai);
    await _settle();
    await n.send('Q');
    final firstAnswer = n.state.messages.last.id;
    ai.next = right('better answer');
    await n.regenerate();
    expect(repo.deleted, [firstAnswer]);
    expect(n.state.messages.map((m) => m.content), ['Q', 'better answer']);
  });

  test('send is ignored while a reply is pending', () async {
    final ai = FakeAi()..pending = Completer();
    final n = make(FakeChatRepo(), ai);
    await _settle();
    unawaited(n.send('one'));
    await _settle();
    await n.send('two');
    expect(ai.requests.length, 1);
    ai.pending!.complete(right('ok'));
  });
}
