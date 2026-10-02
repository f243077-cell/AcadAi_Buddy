import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/domain/study/entities/quiz_message.dart';
import 'package:study_ai_app/domain/study/entities/study_options.dart';

/// What to generate. [sourceText] bases the quiz on given material.
class QuizConfig {
  const QuizConfig({
    required this.subject,
    this.topic,
    this.count = 10,
    this.difficulty = QuizDifficulty.medium,
    this.sourceText,
  });

  final String subject;
  final String? topic;
  final int count;
  final QuizDifficulty difficulty;
  final String? sourceText;

  /// "10 questions, Medium, Recursion".
  String get summary => [
        '$count questions',
        difficulty.label,
        if (topic != null && topic!.isNotEmpty) topic!,
      ].join(', ');
}

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
  const QuizLoaded({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    this.selectedIndex,
    this.checked = false,
  });

  final List<QuizQuestion> questions;
  final int currentIndex;

  /// The checked answer for each question so far (null = not reached).
  final List<int?> answers;

  /// Option tapped on the current question, before or after checking.
  final int? selectedIndex;

  /// Whether the current answer has been checked (states revealed).
  final bool checked;

  QuizQuestion get current => questions[currentIndex];
  bool get isLast => currentIndex >= questions.length - 1;
  int get score {
    var s = 0;
    for (var i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].correctIndex) s++;
    }
    return s;
  }

  /// Kept for older callers.
  bool get answered => checked;

  QuizLoaded copyWith({
    int? currentIndex,
    List<int?>? answers,
    int? selectedIndex,
    bool clearSelected = false,
    bool? checked,
  }) {
    return QuizLoaded(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      selectedIndex: clearSelected ? null : (selectedIndex ?? this.selectedIndex),
      checked: checked ?? this.checked,
    );
  }
}

class QuizFinished extends QuizState {
  const QuizFinished({
    required this.questions,
    required this.answers,
    this.isRetry = false,
  });

  final List<QuizQuestion> questions;
  final List<int?> answers;

  /// A "retry wrong questions" round (not saved as a new result).
  final bool isRetry;

  int get total => questions.length;
  int get score {
    var s = 0;
    for (var i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].correctIndex) s++;
    }
    return s;
  }

  int get percent => total == 0 ? 0 : (score * 100 / total).round();

  List<QuizQuestion> get wrongQuestions => [
        for (var i = 0; i < questions.length; i++)
          if (answers[i] != questions[i].correctIndex) questions[i],
      ];
}

class QuizFailure extends QuizState {
  const QuizFailure(this.failure);

  final AiFailure failure;

  /// Friendly text; never raw exception output.
  String get error => failure.message;
}
