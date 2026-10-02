import 'quiz_message.dart';

/// One answered question inside a [QuizResult].
class QuizResultItem {
  const QuizResultItem({required this.question, this.selectedIndex});

  final QuizQuestion question;
  final int? selectedIndex;

  bool get isCorrect => selectedIndex == question.correctIndex;
}

/// A finished quiz (`users/{uid}/quizResults/{id}`). Pure Dart.
class QuizResult {
  const QuizResult({
    required this.id,
    required this.subject,
    this.topic,
    required this.score,
    required this.total,
    required this.createdAt,
    this.items = const [],
  });

  final String id;
  final String subject;
  final String? topic;
  final int score;
  final int total;
  final DateTime createdAt;
  final List<QuizResultItem> items;

  int get percent => total == 0 ? 0 : (score * 100 / total).round();
}

/// Aggregate progress shown on Home.
class QuizStats {
  const QuizStats({
    required this.taken,
    required this.averagePercent,
    this.bestSubject,
  });

  final int taken;
  final int averagePercent;

  /// Subject with the highest average (at least one quiz), if any.
  final String? bestSubject;

  static QuizStats from(List<QuizResult> results) {
    if (results.isEmpty) return const QuizStats(taken: 0, averagePercent: 0);
    final avg =
        results.map((r) => r.percent).reduce((a, b) => a + b) / results.length;
    final bySubject = <String, List<int>>{};
    for (final r in results) {
      bySubject.putIfAbsent(r.subject, () => []).add(r.percent);
    }
    String? best;
    var bestAvg = -1.0;
    bySubject.forEach((subject, percents) {
      final a = percents.reduce((x, y) => x + y) / percents.length;
      if (a > bestAvg) {
        bestAvg = a;
        best = subject;
      }
    });
    return QuizStats(
      taken: results.length,
      averagePercent: avg.round(),
      bestSubject: best,
    );
  }
}
