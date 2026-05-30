import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_ai_app/application/quiz/quiz_state.dart';
import 'package:study_ai_app/infrastructure/study/gemini_service.dart';

class QuizNotifier extends StateNotifier<QuizState> {
  final GeminiService _geminiService;

  QuizNotifier(this._geminiService) : super(const QuizInitial());

  Future<void> generateQuiz(String subject, int numQuestions) async {
    state = const QuizLoading();
    try {
      final questions =
          await _geminiService.generateQuiz(subject, numQuestions);
      state = QuizLoaded(
        questions: questions,
        currentIndex: 0,
        score: 0,
        answered: false,
        selectedAnswer: null,
      );
    } catch (e) {
      state = QuizFailure(e.toString());
    }
  }

  void answerQuestion(String answer) {
    final s = state;
    if (s is! QuizLoaded || s.answered) return;

    final currentQuestion = s.questions[s.currentIndex];
    final isCorrect = answer == currentQuestion.answer;
    final newScore = isCorrect ? s.score + 1 : s.score;

    state = s.copyWith(
      score: newScore,
      answered: true,
      selectedAnswer: answer,
    );
  }

  void nextQuestion() {
    final s = state;
    if (s is! QuizLoaded) return;

    final isLastQuestion = s.currentIndex >= s.questions.length - 1;

    if (isLastQuestion) {
      state = QuizFinished(
        score: s.score,
        total: s.questions.length,
      );
    } else {
      state = s.copyWith(
        currentIndex: s.currentIndex + 1,
        answered: false,
        selectedAnswer: null,
      );
    }
  }

  void resetQuiz() {
    state = const QuizInitial();
  }
}

final quizNotifierProvider =
    StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref.watch(geminiServiceProvider));
});
