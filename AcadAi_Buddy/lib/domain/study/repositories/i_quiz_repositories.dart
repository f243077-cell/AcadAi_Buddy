import 'package:dartz/dartz.dart';

import 'package:study_ai_app/domain/core/failures.dart';
import '../entities/quiz_message.dart';

/// Abstract contract for AI-powered quiz generation.
///
/// Implementations live in `infrastructure/study/` and delegate to the
/// Gemini API via [GeminiService].
abstract class IQuizRepository {
  /// Generates [numQuestions] multiple-choice questions on [subject].
  ///
  /// Returns [Right<List<QuizQuestion>>] on success, or a typed
  /// [Left<ChatFailure>] if the AI service or network fails.
  ///
  /// - [subject]: The topic / subject area to generate questions about
  ///   (e.g. `'Organic Chemistry'`, `'World War II'`).
  /// - [numQuestions]: How many questions to generate. Callers should
  ///   keep this reasonable (≤ 20) to stay within model token limits.
  Future<Either<ChatFailure, List<QuizQuestion>>> generateQuiz(
    String subject,
    int numQuestions,
  );
}