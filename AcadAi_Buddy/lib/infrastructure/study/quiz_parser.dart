import 'dart:convert';

import 'package:study_ai_app/domain/study/entities/quiz_message.dart';

final _optionPrefix = RegExp(r'^\s*(?:\(?[A-Da-d]\)|[A-Da-d][.:]|[A-Da-d]\s+-)\s+');
final _answerLead = RegExp(r'^\s*(?:the\s+)?(?:correct\s+)?(?:option|answer)\b\s*(?:is\b)?\s*[:\-]?\s*',
    caseSensitive: false);
final _letterOnly = RegExp(r'^\(?([A-Da-d])(?:\)|\.|:|\s*-|$)');

/// Removes a leading "A) ", "b. ", "(C) " or "D - " from an option.
String stripOptionPrefix(String option) =>
    option.replaceFirst(_optionPrefix, '').trim();

String _norm(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

/// Resolves the model's answer to an index into [options], or null when it
/// cannot be resolved (the caller then drops the question).
///
/// Accepts an int index, the option text (with or without a letter prefix),
/// a bare letter ("B", "b)", "(B)"), or "Answer: B".
int? resolveAnswerIndex(List<String> options, Object? raw) {
  if (raw is int) return (raw >= 0 && raw < options.length) ? raw : null;
  if (raw is double && raw == raw.roundToDouble()) {
    return resolveAnswerIndex(options, raw.toInt());
  }

  final original = raw?.toString().trim() ?? '';
  if (original.isEmpty) return null;
  final a = original.replaceFirst(_answerLead, '').trim();
  final stripped = stripOptionPrefix(a);
  final clean = options.map(stripOptionPrefix).toList();

  // 1. Exact text (ignoring case and letter prefixes).
  for (final candidate in {original, a, stripped}) {
    final i = clean.indexWhere(
        (o) => o.toLowerCase() == candidate.toLowerCase());
    if (i >= 0) return i;
  }

  // 2. Bare letter.
  final m = _letterOnly.firstMatch(a);
  if (m != null) {
    final i = m.group(1)!.toUpperCase().codeUnitAt(0) - 65;
    if (i < options.length) return i;
  }

  // 3. Same words, ignoring punctuation.
  final n = _norm(stripped);
  if (n.isNotEmpty) {
    final i = clean.indexWhere((o) => _norm(o) == n);
    if (i >= 0) return i;
  }

  // 4. A numeric string that is not itself an option.
  final asInt = int.tryParse(a);
  if (asInt != null && asInt >= 0 && asInt < options.length) return asInt;

  return null;
}

/// Pulls the list of question objects out of a model reply: plain JSON,
/// a `{"questions": [...]}` wrapper, fenced code, or JSON with prose around
/// it. Returns null when no list can be decoded.
List<dynamic>? _extractList(String raw) {
  var text = raw
      .replaceAll(RegExp(r'```(?:json|JSON)?'), '')
      .replaceAll('```', '')
      .trim();

  Object? decoded;
  try {
    decoded = jsonDecode(text);
  } catch (_) {
    decoded = null;
  }
  if (decoded is List) return decoded;
  if (decoded is Map) {
    final q = decoded['questions'];
    if (q is List) return q;
    for (final v in decoded.values) {
      if (v is List) return v;
    }
  }

  final start = text.indexOf('[');
  final end = text.lastIndexOf(']');
  if (start < 0 || end <= start) return null;
  try {
    final inner = jsonDecode(text.substring(start, end + 1));
    return inner is List ? inner : null;
  } catch (_) {
    return null;
  }
}

/// Parses a model reply into valid questions. Items without a question,
/// with fewer than two options, or with an unresolvable answer are dropped.
List<QuizQuestion> parseQuizQuestions(String raw) {
  final list = _extractList(raw);
  if (list == null) return const [];

  final out = <QuizQuestion>[];
  for (final item in list) {
    try {
      if (item is! Map) continue;
      final question = (item['question'] ?? '').toString().trim();
      final rawOptions = item['options'];
      if (question.isEmpty || rawOptions is! List) continue;

      final original = rawOptions
          .map((o) => o.toString().trim())
          .where((o) => o.isNotEmpty)
          .toList();
      if (original.length < 2) continue;

      final answerRaw = item['answerIndex'] ??
          item['answer_index'] ??
          item['correctIndex'] ??
          item['answer'] ??
          item['correctAnswer'] ??
          item['correct'];
      final index = resolveAnswerIndex(original, answerRaw);
      if (index == null) continue;

      out.add(QuizQuestion(
        question: question,
        options: original.map(stripOptionPrefix).toList(),
        correctIndex: index,
        explanation: (item['explanation'] ?? '').toString().trim(),
      ));
    } catch (_) {
      // One malformed item never sinks the whole quiz.
    }
  }
  return out;
}

/// True when enough questions survived parsing to be worth showing.
bool enoughQuestions(int parsed, int requested) =>
    parsed > 0 && parsed >= (requested * 0.6).ceil();
