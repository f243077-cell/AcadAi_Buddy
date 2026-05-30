/// Domain entity representing a single multiple-choice quiz question.
///
/// Pure Dart — no Firebase or external imports.
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  /// The question text presented to the student.
  final String question;

  /// The list of answer options (typically 4 choices, A–D).
  final List<String> options;

  /// The correct answer string (must be one of the [options]).
  final String answer;

  /// Returns a copy of this question with the given fields replaced.
  QuizQuestion copyWith({
    String? question,
    List<String>? options,
    String? answer,
  }) {
    return QuizQuestion(
      question: question ?? this.question,
      options: options ?? List<String>.from(this.options),
      answer: answer ?? this.answer,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestion &&
          runtimeType == other.runtimeType &&
          question == other.question &&
          answer == other.answer &&
          _listsEqual(options, other.options);

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(question, answer, Object.hashAll(options));

  @override
  String toString() => 'QuizQuestion('
      'question: ${question.length > 40 ? '${question.substring(0, 40)}…' : question}, '
      'options: $options, '
      'answer: $answer'
      ')';
}
