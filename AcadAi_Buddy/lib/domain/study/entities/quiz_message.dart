/// Domain entity representing a single multiple-choice quiz question.
///
/// Pure Dart — no Firebase or external imports.
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
  });

  /// The question text presented to the student.
  final String question;

  /// The answer options without letter prefixes (the UI draws A–D badges).
  final List<String> options;

  /// Index into [options] of the correct answer.
  final int correctIndex;

  /// Why the correct answer is right (from the model; may be empty).
  final String explanation;

  /// The correct answer text. Kept so older callers still compile.
  String get answer => options[correctIndex];

  /// Returns a copy of this question with the given fields replaced.
  QuizQuestion copyWith({
    String? question,
    List<String>? options,
    int? correctIndex,
    String? explanation,
  }) {
    return QuizQuestion(
      question: question ?? this.question,
      options: options ?? List<String>.from(this.options),
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestion &&
          runtimeType == other.runtimeType &&
          question == other.question &&
          correctIndex == other.correctIndex &&
          explanation == other.explanation &&
          _listsEqual(options, other.options);

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(question, correctIndex, explanation, Object.hashAll(options));

  @override
  String toString() => 'QuizQuestion('
      'question: ${question.length > 40 ? '${question.substring(0, 40)}…' : question}, '
      'options: $options, '
      'correctIndex: $correctIndex'
      ')';
}
