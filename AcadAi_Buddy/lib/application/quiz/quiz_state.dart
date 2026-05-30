import 'package:study_ai_app/domain/study/entities/quiz_message.dart';

abstract class QuizState {
  const QuizState();
}

class QuizInitial extends QuizState {
  const QuizInitial();
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuizLoaded extends QuizState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int score;
  final bool answered;
  final String? selectedAnswer;

  const QuizLoaded({
    required this.questions,
    required this.currentIndex,
    required this.score,
    required this.answered,
    this.selectedAnswer,
  });

  QuizLoaded copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? score,
    bool? answered,
    String? selectedAnswer,
  }) {
    return QuizLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      answered: answered ?? this.answered,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
    );
  }
}

class QuizFinished extends QuizState {
  final int score;
  final int total;
  const QuizFinished({required this.score, required this.total});
}

class QuizFailure extends QuizState {
  final String error;
  const QuizFailure(this.error);
}
