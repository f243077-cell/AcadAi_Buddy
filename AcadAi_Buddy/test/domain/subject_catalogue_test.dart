import 'package:flutter_test/flutter_test.dart';
import 'package:study_ai_app/domain/study/subject_catalogue.dart';

void main() {
  test('subject ids and names are unique', () {
    final ids = kSubjects.map((s) => s.id).toList();
    final names = kSubjects.map((s) => s.name.toLowerCase()).toList();
    expect(ids.toSet().length, ids.length);
    expect(names.toSet().length, names.length);
  });

  test('every subject has topics and a known category', () {
    for (final s in kSubjects) {
      expect(s.topics, isNotEmpty, reason: s.name);
      expect(kSubjectCategories, contains(s.category), reason: s.name);
      expect(s.iconKey, isNotEmpty, reason: s.name);
    }
  });

  test('every category has at least one subject', () {
    for (final c in kSubjectCategories) {
      expect(subjectsInCategory(c), isNotEmpty, reason: c);
    }
  });

  test('subjectByName is case-insensitive and null for custom subjects', () {
    expect(subjectByName('calculus')?.id, 'calculus');
    expect(subjectByName('Underwater Basket Weaving'), isNull);
  });
}
