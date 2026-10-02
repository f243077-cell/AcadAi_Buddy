import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_ai_app/application/quiz/quiz_notifier.dart';
import 'package:study_ai_app/application/quiz/quiz_state.dart';
import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:study_ai_app/domain/study/entities/quiz_message.dart';
import 'package:study_ai_app/domain/study/entities/quiz_result.dart';
import 'package:study_ai_app/domain/study/entities/study_options.dart';
import 'package:study_ai_app/domain/study/repositories/i_ai_repository.dart';
import 'package:study_ai_app/domain/study/repositories/i_quiz_result_repository.dart';

class _QuizAi implements IAiRepository {
  Completer<Either<AiFailure, List<QuizQuestion>>>? pending;
  Either<AiFailure, List<QuizQuestion>> next = right(_questions);

  @override
  Future<Either<AiFailure, List<QuizQuestion>>> generateQuiz({
    required String subject,
    String? topic,
    required int count,
    QuizDifficulty difficulty = QuizDifficulty.medium,
    String? sourceText,
  }) =>
      pending?.future ?? Future.value(next);

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
  Future<Either<AiFailure, String>> summarize(
          {String? text,
          Uint8List? imageBytes,
          SummaryStyle style = SummaryStyle.keyPoints}) async =>
      right('');
}

class _Results implements IQuizResultRepository {
  final saved = <QuizResult>[];

  @override
  Future<void> saveResult(String uid, QuizResult result) async =>
      saved.add(result);

  @override
  Stream<List<QuizResult>> watchResults(String uid) => Stream.value(saved);
}

const _questions = [
  QuizQuestion(question: 'Q1', options: ['a', 'b', 'c', 'd'], correctIndex: 1),
  QuizQuestion(question: 'Q2', options: ['a', 'b', 'c', 'd'], correctIndex: 0),
  QuizQuestion(question: 'Q3', options: ['a', 'b', 'c', 'd'], correctIndex: 3),
];

const _config = QuizConfig(subject: 'DSA', topic: 'Recursion', count: 3);

void main() {
  late _QuizAi ai;
  late _Results results;
  late QuizNotifier n;

  setUp(() {
    ai = _QuizAi();
    results = _Results();
    n = QuizNotifier(ai, results: results, uid: 'u1');
  });

  void answer(int i) {
    n.select(i);
    n.check();
    n.next();
  }

  test('scores by option index and saves the result once', () async {
    await n.start(_config);
    expect(n.state, isA<QuizLoaded>());

    n.select(1);
    expect(n.check(), isTrue);
    n.next();
    answer(2); // wrong
    answer(3); // right

    final f = n.state as QuizFinished;
    expect(f.score, 2);
    expect(f.total, 3);
    expect(f.wrongQuestions.single.question, 'Q2');
    expect(results.saved.single.score, 2);
    expect(results.saved.single.topic, 'Recursion');
  });

  test('check is disabled until something is selected; selection clears on next',
      () async {
    await n.start(_config);
    expect(n.check(), isNull);
    n.select(0);
    n.check();
    n.select(2); // ignored after checking
    expect((n.state as QuizLoaded).selectedIndex, 0);
    n.next();
    expect((n.state as QuizLoaded).selectedIndex, isNull);
    expect((n.state as QuizLoaded).checked, isFalse);
  });

  test('retry wrong questions runs only those and is not saved again',
      () async {
    await n.start(_config);
    answer(0); // wrong
    answer(0); // right
    answer(0); // wrong
    n.retryWrong();
    final s = n.state as QuizLoaded;
    expect(s.questions.map((q) => q.question), ['Q1', 'Q3']);
    answer(1);
    answer(3);
    expect((n.state as QuizFinished).isRetry, isTrue);
    expect(results.saved.length, 1);
  });

  test('a cancelled generation is ignored when it arrives late', () async {
    ai.pending = Completer();
    final starting = n.start(_config);
    n.cancel();
    ai.pending!.complete(right(_questions));
    await starting;
    expect(n.state, isA<QuizInitial>());
  });

  test('failures become a typed QuizFailure with friendly text', () async {
    ai.next = left(AiFailure.rateLimited);
    await n.start(_config);
    final f = n.state as QuizFailure;
    expect(f.failure, AiFailure.rateLimited);
    expect(f.error, isNot(contains('Exception')));
  });

  test('config summary line', () {
    expect(_config.summary, '3 questions, Medium, Recursion');
  });

  test('QuizStats aggregates results', () {
    final stats = QuizStats.from([
      QuizResult(
          id: '1', subject: 'DSA', score: 8, total: 10, createdAt: DateTime(2026)),
      QuizResult(
          id: '2', subject: 'OS', score: 4, total: 10, createdAt: DateTime(2026)),
    ]);
    expect(stats.taken, 2);
    expect(stats.averagePercent, 60);
    expect(stats.bestSubject, 'DSA');
  });
}
