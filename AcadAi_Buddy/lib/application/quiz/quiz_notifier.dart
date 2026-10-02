import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:study_ai_app/application/auth/auth_notifier.dart';
import 'package:study_ai_app/application/quiz/quiz_state.dart';
import 'package:study_ai_app/domain/study/entities/quiz_message.dart';
import 'package:study_ai_app/domain/study/entities/quiz_result.dart';
import 'package:study_ai_app/domain/study/repositories/i_ai_repository.dart';
import 'package:study_ai_app/domain/study/repositories/i_quiz_result_repository.dart';
import 'package:study_ai_app/infrastructure/study/ai_service.dart';
import 'package:study_ai_app/infrastructure/study/firebase_quiz_result_repository.dart';

/// Runs one quiz: generate, select, check, next, finish.
///
/// A request id makes a cancelled or superseded generation a no-op, and
/// autoDispose resets everything when the quiz screen closes.
class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(this._ai, {IQuizResultRepository? results, String? uid})
      : _results = results,
        _uid = uid,
        super(const QuizInitial());

  final IAiRepository _ai;
  final IQuizResultRepository? _results;
  final String? _uid;
  int _requestId = 0;
  QuizConfig? _config;
  bool _isRetryRound = false;

  QuizConfig? get config => _config;

  Future<void> start(QuizConfig config) async {
    _config = config;
    _isRetryRound = false;
    final id = ++_requestId;
    state = const QuizLoading();
    final result = await _ai.generateQuiz(
      subject: config.subject,
      topic: config.topic,
      count: config.count,
      difficulty: config.difficulty,
      sourceText: config.sourceText,
    );
    if (!mounted || id != _requestId) return; // cancelled or superseded
    state = result.fold(
      QuizFailure.new,
      (questions) => _begin(questions),
    );
  }

  /// Kept for older callers.
  Future<void> generateQuiz(String subject, int numQuestions) =>
      start(QuizConfig(subject: subject, count: numQuestions));

  QuizLoaded _begin(List<QuizQuestion> questions) => QuizLoaded(
        questions: questions,
        currentIndex: 0,
        answers: List<int?>.filled(questions.length, null),
      );

  /// Ignores the in-flight generation; the caller leaves the screen.
  void cancel() {
    _requestId++;
    state = const QuizInitial();
  }

  void select(int index) {
    final s = state;
    if (s is! QuizLoaded || s.checked) return;
    if (index < 0 || index >= s.current.options.length) return;
    state = s.copyWith(selectedIndex: index);
  }

  /// Reveals right/wrong for the selected option. Returns whether it was
  /// correct, or null if nothing was checked.
  bool? check() {
    final s = state;
    if (s is! QuizLoaded || s.checked || s.selectedIndex == null) return null;
    final answers = [...s.answers]..[s.currentIndex] = s.selectedIndex;
    state = s.copyWith(answers: answers, checked: true);
    return s.selectedIndex == s.current.correctIndex;
  }

  void next() {
    final s = state;
    if (s is! QuizLoaded || !s.checked) return;
    if (s.isLast) {
      final finished = QuizFinished(
        questions: s.questions,
        answers: s.answers,
        isRetry: _isRetryRound,
      );
      state = finished;
      if (!_isRetryRound) _save(finished);
    } else {
      state = s.copyWith(
        currentIndex: s.currentIndex + 1,
        clearSelected: true,
        checked: false,
      );
    }
  }

  /// Kept for older callers.
  void nextQuestion() => next();

  /// New round with only the questions answered wrong.
  void retryWrong() {
    final s = state;
    if (s is! QuizFinished) return;
    final wrong = s.wrongQuestions;
    if (wrong.isEmpty) return;
    _isRetryRound = true;
    state = _begin(wrong);
  }

  void resetQuiz() {
    _requestId++;
    state = const QuizInitial();
  }

  void _save(QuizFinished f) {
    final repo = _results;
    final uid = _uid;
    final config = _config;
    if (repo == null || uid == null || config == null) return;
    final result = QuizResult(
      id: const Uuid().v4(),
      subject: config.subject,
      topic: config.topic,
      score: f.score,
      total: f.total,
      createdAt: DateTime.now(),
      items: [
        for (var i = 0; i < f.questions.length; i++)
          QuizResultItem(question: f.questions[i], selectedIndex: f.answers[i]),
      ],
    );
    // Not awaited: never blocks the result screen.
    repo.saveResult(uid, result).catchError((_) {});
  }
}

final quizNotifierProvider =
    StateNotifierProvider.autoDispose<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(
    ref.watch(aiRepositoryProvider),
    results: ref.watch(quizResultRepositoryProvider),
    uid: ref.read(currentUserProvider)?.id,
  );
});

/// The signed-in user's quiz results, newest first.
final quizResultsProvider =
    StreamProvider.autoDispose<List<QuizResult>>((ref) {
  final uid = ref.watch(currentUserProvider.select((u) => u?.id));
  if (uid == null) return Stream.value(const []);
  return ref.watch(quizResultRepositoryProvider).watchResults(uid);
});
