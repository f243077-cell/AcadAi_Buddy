import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:study_ai_app/infrastructure/study/quiz_parser.dart';

void main() {
  group('resolveAnswerIndex', () {
    const options = ['Stack', 'Queue', 'Binary tree', 'Hash map'];
    const prefixed = ['A) Stack', 'B) Queue', 'C) Binary tree', 'D) Hash map'];

    test('int index', () {
      expect(resolveAnswerIndex(options, 2), 2);
      expect(resolveAnswerIndex(options, 9), isNull);
      expect(resolveAnswerIndex(options, -1), isNull);
    });

    test('bare letter in its usual forms', () {
      expect(resolveAnswerIndex(options, 'B'), 1);
      expect(resolveAnswerIndex(options, 'b'), 1);
      expect(resolveAnswerIndex(options, 'B)'), 1);
      expect(resolveAnswerIndex(options, '(C)'), 2);
      expect(resolveAnswerIndex(options, 'Answer: D'), 3);
    });

    test('option text, with or without a letter prefix', () {
      expect(resolveAnswerIndex(options, 'Queue'), 1);
      expect(resolveAnswerIndex(options, 'queue'), 1);
      expect(resolveAnswerIndex(options, 'B) Queue'), 1);
      expect(resolveAnswerIndex(prefixed, 'B) Queue'), 1);
      expect(resolveAnswerIndex(prefixed, 'Queue'), 1);
      expect(resolveAnswerIndex(options, 'b. Queue'), 1);
      expect(resolveAnswerIndex(options, 'Binary tree.'), 2);
    });

    test('words starting with A-D are not mistaken for letters', () {
      expect(resolveAnswerIndex(options, 'Binary'), isNull);
      expect(resolveAnswerIndex(options, 'Deque'), isNull);
      expect(
          resolveAnswerIndex(['Optional chaining', 'Spread'], 'Optional chaining'),
          0);
    });

    test('junk resolves to null', () {
      expect(resolveAnswerIndex(options, null), isNull);
      expect(resolveAnswerIndex(options, ''), isNull);
      expect(resolveAnswerIndex(options, 'E'), isNull);
      expect(resolveAnswerIndex(options, 'none of these'), isNull);
    });
  });

  group('parseQuizQuestions', () {
    Map<String, dynamic> q(String text, Object? answer,
            {List<String> options = const ['w', 'x', 'y', 'z']}) =>
        {'question': text, 'options': options, 'answerIndex': answer, 'explanation': 'because'};

    test('plain array', () {
      final out = parseQuizQuestions(jsonEncode([q('Q1', 1), q('Q2', 0)]));
      expect(out.length, 2);
      expect(out.first.correctIndex, 1);
      expect(out.first.answer, 'x');
      expect(out.first.explanation, 'because');
    });

    test('{"questions": [...]} wrapper from JSON mode', () {
      final out = parseQuizQuestions(jsonEncode({'questions': [q('Q1', 3)]}));
      expect(out.single.correctIndex, 3);
    });

    test('fenced code block', () {
      final raw = '```json\n${jsonEncode([q('Q1', 2)])}\n```';
      expect(parseQuizQuestions(raw).single.correctIndex, 2);
    });

    test('prose before and after the JSON', () {
      final raw =
          'Sure! Here is your quiz:\n${jsonEncode([q('Q1', 0)])}\nGood luck, hope this helps.';
      expect(parseQuizQuestions(raw).length, 1);
    });

    test('old format: letter-prefixed options and text answer', () {
      final raw = jsonEncode([
        {
          'question': 'LIFO structure?',
          'options': ['A) Stack', 'B) Queue', 'C) Tree', 'D) Graph'],
          'answer': 'A) Stack',
        }
      ]);
      final out = parseQuizQuestions(raw).single;
      expect(out.options, ['Stack', 'Queue', 'Tree', 'Graph']);
      expect(out.correctIndex, 0);
    });

    test('bad items are dropped, good ones kept', () {
      final raw = jsonEncode([
        q('Good', 1),
        q('', 1), // empty question
        q('One option', 0, options: ['only']),
        q('Bad answer', 'E'),
        {'question': 'No options'},
        'not an object',
        q('Also good', 'C'),
      ]);
      final out = parseQuizQuestions(raw);
      expect(out.map((e) => e.question), ['Good', 'Also good']);
      expect(out.last.correctIndex, 2);
    });

    test('truncated / non-JSON reply yields nothing', () {
      expect(parseQuizQuestions('[{"question": "Q1", "options": ["a",'), isEmpty);
      expect(parseQuizQuestions('I cannot help with that.'), isEmpty);
    });

    test('too few survivors', () {
      expect(enoughQuestions(6, 10), isTrue);
      expect(enoughQuestions(5, 10), isFalse);
      expect(enoughQuestions(0, 1), isFalse);
      expect(enoughQuestions(3, 5), isTrue);
    });
  });
}
