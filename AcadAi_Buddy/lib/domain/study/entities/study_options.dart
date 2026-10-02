/// Options passed from the UI to the AI layer. Pure Dart.
library;

enum QuizDifficulty { easy, medium, hard }

extension QuizDifficultyX on QuizDifficulty {
  String get label => switch (this) {
        QuizDifficulty.easy => 'Easy',
        QuizDifficulty.medium => 'Medium',
        QuizDifficulty.hard => 'Hard',
      };
}

enum SummaryStyle { keyPoints, examQuestions, flashcards, detailed }

extension SummaryStyleX on SummaryStyle {
  String get label => switch (this) {
        SummaryStyle.keyPoints => 'Key points',
        SummaryStyle.examQuestions => 'Exam questions',
        SummaryStyle.flashcards => 'Flashcards',
        SummaryStyle.detailed => 'Detailed',
      };
}

/// Longest note text sent for summarizing.
const kMaxNoteLength = 12000;
