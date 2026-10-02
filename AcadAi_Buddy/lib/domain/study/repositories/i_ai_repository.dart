import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/chat_message.dart';
import '../entities/quiz_message.dart';
import '../entities/study_options.dart';

/// Contract for every AI call the app makes. Implementations never throw;
/// they return a typed [AiFailure] instead.
abstract class IAiRepository {
  /// Tutor reply for [history] (oldest first; the last item is the newest
  /// user message). With [imageBytes] the newest message carries an image.
  Future<Either<AiFailure, String>> chat({
    required String subject,
    required List<ChatMessage> history,
    Uint8List? imageBytes,
  });

  /// Answers [prompt] about one image.
  Future<Either<AiFailure, String>> describeImage({
    required String prompt,
    required Uint8List bytes,
  });

  /// Multiple-choice questions. With [sourceText] the questions are based
  /// on that text (e.g. a summary) instead of the subject in general.
  Future<Either<AiFailure, List<QuizQuestion>>> generateQuiz({
    required String subject,
    String? topic,
    required int count,
    QuizDifficulty difficulty = QuizDifficulty.medium,
    String? sourceText,
  });

  /// Summary of typed notes or a photo of notes (exactly one of the two).
  Future<Either<AiFailure, String>> summarize({
    String? text,
    Uint8List? imageBytes,
    SummaryStyle style = SummaryStyle.keyPoints,
  });
}
