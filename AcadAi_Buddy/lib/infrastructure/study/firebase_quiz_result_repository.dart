import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_ai_app/domain/study/entities/quiz_message.dart';
import 'package:study_ai_app/domain/study/entities/quiz_result.dart';
import 'package:study_ai_app/domain/study/repositories/i_quiz_result_repository.dart';
import 'package:study_ai_app/infrastructure/core/firebase_injectable.dart';

final quizResultRepositoryProvider = Provider<IQuizResultRepository>(
  (ref) => FirebaseQuizResultRepository(ref.watch(firestoreProvider)),
);

class FirebaseQuizResultRepository implements IQuizResultRepository {
  FirebaseQuizResultRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('quizResults');

  @override
  Future<void> saveResult(String uid, QuizResult r) {
    return _col(uid).doc(r.id).set({
      'subject': r.subject,
      'topic': r.topic,
      'score': r.score,
      'total': r.total,
      'createdAt': Timestamp.fromDate(r.createdAt),
      'items': [
        for (final i in r.items)
          {
            'question': i.question.question,
            'options': i.question.options,
            'correctIndex': i.question.correctIndex,
            'explanation': i.question.explanation,
            'selectedIndex': i.selectedIndex,
          },
      ],
    });
  }

  @override
  Stream<List<QuizResult>> watchResults(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) => _fromJson(d.id, d.data())).toList());
  }

  static QuizResult _fromJson(String id, Map<String, dynamic> j) {
    final created = j['createdAt'];
    final items = <QuizResultItem>[];
    final rawItems = j['items'];
    if (rawItems is List) {
      for (final raw in rawItems) {
        if (raw is! Map) continue;
        final options =
            (raw['options'] as List? ?? const []).map((e) => '$e').toList();
        final correct = raw['correctIndex'];
        if (options.length < 2 || correct is! int || correct >= options.length) {
          continue;
        }
        items.add(QuizResultItem(
          question: QuizQuestion(
            question: '${raw['question'] ?? ''}',
            options: options,
            correctIndex: correct,
            explanation: '${raw['explanation'] ?? ''}',
          ),
          selectedIndex: raw['selectedIndex'] as int?,
        ));
      }
    }
    return QuizResult(
      id: id,
      subject: '${j['subject'] ?? 'General'}',
      topic: j['topic'] as String?,
      score: (j['score'] as num?)?.toInt() ?? 0,
      total: (j['total'] as num?)?.toInt() ?? 0,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      items: items,
    );
  }
}
