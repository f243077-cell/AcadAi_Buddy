import '../entities/quiz_result.dart';

/// Stores finished quizzes per user.
abstract class IQuizResultRepository {
  /// Completes on server acknowledgement; callers should not await it.
  Future<void> saveResult(String uid, QuizResult result);

  /// The user's results, newest first.
  Stream<List<QuizResult>> watchResults(String uid);
}
