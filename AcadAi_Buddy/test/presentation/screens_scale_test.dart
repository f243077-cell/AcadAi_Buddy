import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_ai_app/application/auth/auth_notifier.dart';
import 'package:study_ai_app/application/chat/chat_history.dart';
import 'package:study_ai_app/domain/auth/entities/app_user.dart';
import 'package:study_ai_app/domain/auth/repositories/i_auth_repositories.dart';
import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:study_ai_app/domain/study/entities/chat_session.dart';
import 'package:study_ai_app/domain/study/entities/quiz_message.dart';
import 'package:study_ai_app/domain/study/entities/study_options.dart';
import 'package:study_ai_app/domain/study/repositories/i_ai_repository.dart';
import 'package:study_ai_app/domain/study/repositories/i_chat_repositories.dart';
import 'package:study_ai_app/infrastructure/study/ai_service.dart';
import 'package:study_ai_app/domain/study/entities/quiz_result.dart';
import 'package:study_ai_app/domain/study/repositories/i_quiz_result_repository.dart';
import 'package:study_ai_app/infrastructure/study/firebase_chat_repository.dart';
import 'package:study_ai_app/infrastructure/study/firebase_quiz_result_repository.dart';
import 'package:study_ai_app/presentation/core/theme.dart';
import 'package:study_ai_app/presentation/pages/profile/profile_page.dart';
import 'package:study_ai_app/presentation/pages/sign_up/sign_up_page.dart';
import 'package:study_ai_app/presentation/pages/study/chat/chat_page.dart';
import 'package:study_ai_app/application/quiz/quiz_state.dart';
import 'package:study_ai_app/presentation/pages/study/quiz/quiz_play_page.dart';
import 'package:study_ai_app/presentation/pages/study/quiz/quiz_setup_page.dart';
import 'package:study_ai_app/presentation/pages/study/summarize/summarize_page.dart';
import 'package:study_ai_app/presentation/pages/study/tutor/tutor_page.dart';

class _Auth implements IAuthRepository {
  @override
  Stream<AppUser?> authStateChanges() => const Stream.empty();
  @override
  Future<Either<AuthFailure, AppUser>> signIn(String e, String p) async =>
      left(AuthFailure.serverError());
  @override
  Future<Either<AuthFailure, AppUser>> signUp(String e, String p, String n) async =>
      left(AuthFailure.serverError());
  @override
  Future<void> signOut() async {}
  @override
  AppUser? getSignedInUser() => null;
  @override
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail(String e) async =>
      right(unit);

  @override
  Future<Either<AuthFailure, AppUser>> updateDisplayName(String n) async =>
      right(AppUser(id: 'u1', email: 'a@b.co', displayName: n));
}

final _now = DateTime.now();
final _session = ChatSession(
  id: 'c1',
  ownerId: 'u1',
  subject: 'Data Structures & Algorithms',
  title: 'What is the base case in recursion?',
  lastMessage: 'x',
  createdAt: _now,
  updatedAt: _now,
);

class _Chats implements IChatRepository {
  @override
  Stream<ChatSession?> watchChat(String chatId) => Stream.value(_session);
  @override
  Stream<List<ChatMessage>> getMessages(String chatId) => Stream.value([
        ChatMessage(
            id: '1',
            content: 'What is the base case in recursion? Explain with an example please.',
            role: MessageRole.user,
            timestamp: _now,
            chatId: 'c1'),
        ChatMessage(
            id: '2',
            content: '## Base case\nIt stops recursion: \$T(n) = T(n-1) + 1\$.\n\n'
                '```python\ndef fact(n):\n    return 1 if n <= 1 else n * fact(n - 1)\n```\n\n'
                '| Case | Cost |\n|---|---|\n| best | O(1) |',
            role: MessageRole.model,
            timestamp: _now.add(const Duration(seconds: 1)),
            chatId: 'c1'),
      ]);
  @override
  Stream<List<ChatSession>> watchChats(String ownerId) => Stream.value([_session]);
  @override
  Future<void> addMessage(ChatSession s, ChatMessage m) async {}
  @override
  Future<void> saveMessage(ChatMessage m) async {}
  @override
  Future<void> upsertChat(ChatSession s) async {}
  @override
  Future<void> deleteMessage(String c, String m) async {}
  @override
  Future<void> clearMessages(ChatSession s) async {}
  @override
  Future<void> deleteChat(String c) async {}
}

class _Ai implements IAiRepository {
  @override
  Future<Either<AiFailure, String>> chat(
          {required String subject,
          required List<ChatMessage> history,
          Uint8List? imageBytes}) async =>
      right('');
  @override
  Future<Either<AiFailure, String>> describeImage(
          {required String prompt, required Uint8List bytes}) async =>
      right('');
  @override
  Future<Either<AiFailure, List<QuizQuestion>>> generateQuiz(
          {required String subject,
          String? topic,
          required int count,
          QuizDifficulty difficulty = QuizDifficulty.medium,
          String? sourceText}) async =>
      right(const [
        QuizQuestion(
          question: 'Which data structure follows LIFO order and is used for function calls?',
          options: [
            'Stack',
            'Queue',
            'A balanced binary search tree with parent pointers',
            'Hash map',
          ],
          correctIndex: 0,
          explanation: 'Calls push frames on the call stack.',
        ),
      ]);
  @override
  Future<Either<AiFailure, String>> summarize(
          {String? text,
          Uint8List? imageBytes,
          SummaryStyle style = SummaryStyle.keyPoints}) async =>
      right('');
}

class _Results implements IQuizResultRepository {
  @override
  Future<void> saveResult(String uid, QuizResult result) async {}
  @override
  Stream<List<QuizResult>> watchResults(String uid) => Stream.value(const []);
}

void main() {
  setUpAll(() => AppFonts.useGoogleFonts = false);

  final overrides = <Override>[
    authNotifierProvider.overrideWith((ref) => AuthNotifier(_Auth())),
    currentUserProvider.overrideWithValue(
        const AppUser(id: 'u1', email: 'a@b.co', displayName: 'Ali')),
    chatHistoryProvider.overrideWith((ref) => Stream.value([_session])),
    firebaseChatRepositoryProvider.overrideWithValue(_Chats()),
    aiRepositoryProvider.overrideWithValue(_Ai()),
    quizResultRepositoryProvider.overrideWithValue(_Results()),
  ];

  final screens = <String, Widget>{
    'sign up': const SignUpPage(),
    'tutor history': const TutorPage(),
    'quiz setup': const QuizSetupPage(),
    'summarize': const SummarizePage(),
    'chat': const ChatPage(chatId: 'c1'),
    'profile': const ProfilePage(),
    'quiz question': const QuizPlayPage(
        config: QuizConfig(subject: 'Data Structures & Algorithms', count: 5)),
  };

  for (final scale in [1.0, 1.3]) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} has no overflow at ${scale}x', (t) async {
        t.view.physicalSize = const Size(360, 720);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);

        await t.pumpWidget(ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            theme: buildAppTheme(),
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: entry.value,
              ),
            ),
          ),
        ));
        await t.pump();
        await t.pump(const Duration(milliseconds: 50));
        expect(t.takeException(), isNull);
        // Let periodic animations stop before the test ends.
        await t.pumpWidget(const SizedBox());
      });
    }
  }
}
