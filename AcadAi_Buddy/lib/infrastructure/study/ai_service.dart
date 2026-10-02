import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:study_ai_app/domain/study/entities/quiz_message.dart';
import 'package:study_ai_app/domain/study/entities/study_options.dart';
import 'package:study_ai_app/domain/study/repositories/i_ai_repository.dart';
import 'package:study_ai_app/infrastructure/study/ai_config.dart';
import 'package:study_ai_app/infrastructure/study/quiz_parser.dart';

final aiRepositoryProvider = Provider<IAiRepository>(
  (ref) => AiService(AiConfig.fromEnv()),
);

/// Detects an image's MIME type from its first bytes; defaults to JPEG.
String detectImageMime(Uint8List b) {
  bool starts(List<int> sig, [int offset = 0]) {
    if (b.length < offset + sig.length) return false;
    for (var i = 0; i < sig.length; i++) {
      if (b[offset + i] != sig[i]) return false;
    }
    return true;
  }

  if (starts([0x89, 0x50, 0x4E, 0x47])) return 'image/png';
  if (starts([0x47, 0x49, 0x46, 0x38])) return 'image/gif';
  if (starts([0x52, 0x49, 0x46, 0x46]) && starts([0x57, 0x45, 0x42, 0x50], 8)) {
    return 'image/webp';
  }
  if (starts([0x66, 0x74, 0x79, 0x70], 4)) return 'image/heic';
  return 'image/jpeg';
}

/// Maps an HTTP status to a typed failure.
AiFailure aiFailureForStatus(int status) {
  if (status == 401 || status == 402 || status == 403 || status == 404) {
    return AiFailure.unauthorized;
  }
  if (status == 408) return AiFailure.timeout;
  if (status == 429 || status == 502 || status == 503) {
    return AiFailure.rateLimited;
  }
  return AiFailure.unknown;
}

/// Maps a thrown exception to a typed failure.
AiFailure aiFailureForException(Object e) {
  if (e is TimeoutException) return AiFailure.timeout;
  if (e is SocketException || e is http.ClientException) {
    return AiFailure.offline;
  }
  if (e is FormatException || e is TypeError || e is RangeError) {
    return AiFailure.badResponse;
  }
  return AiFailure.unknown;
}

class _CallError {
  const _CallError(this.failure, [this.status]);
  final AiFailure failure;
  final int? status;
}

/// OpenRouter-compatible chat-completions client.
///
/// Timeout 45 s; two retries with 1 s / 3 s backoff on 429 and 5xx only.
/// Never throws: every failure becomes an [AiFailure].
class AiService implements IAiRepository {
  AiService(
    this.config, {
    http.Client? client,
    Future<void> Function(Duration)? sleep,
    this.timeout = const Duration(seconds: 45),
  })  : _client = client ?? http.Client(),
        _sleep = sleep ?? Future<void>.delayed;

  final AiConfig config;
  final http.Client _client;
  final Future<void> Function(Duration) _sleep;
  final Duration timeout;

  static const historyLimit = 12;
  static const _backoff = [Duration(seconds: 1), Duration(seconds: 3)];

  static String tutorPrompt(String subject) =>
      'You are AcadAI Buddy, a study tutor for university students in '
      'Pakistan. The current subject is $subject. Explain step by step in '
      'short paragraphs. Use Markdown; write math in LaTeX with \$...\$ and '
      '\$\$...\$\$; put code in fenced blocks with a language tag. Use simple '
      'English and add Roman-Urdu only when the student writes in it or asks. '
      'If a question is unrelated to studying, answer in one or two lines and '
      'steer back to $subject.';

  static const _studyPrompt =
      'You are AcadAI Buddy, a study assistant for university students in '
      'Pakistan. Use Markdown; write math in LaTeX with \$...\$ and '
      '\$\$...\$\$; put code in fenced blocks with a language tag.';

  // ── Transport ─────────────────────────────────────────────────────────────

  Future<Either<_CallError, String>> _complete({
    required bool vision,
    required List<Map<String, dynamic>> messages,
    bool jsonMode = false,
  }) async {
    if (config.apiKey.isEmpty) {
      return left(const _CallError(AiFailure.unauthorized));
    }
    final models = config.chainFor(vision: vision);
    final body = jsonEncode({
      'model': models.first,
      // OpenRouter falls back through this list when a model is busy.
      if (models.length > 1) 'models': models,
      'messages': messages,
      if (jsonMode) 'response_format': {'type': 'json_object'},
    });

    for (var attempt = 0;; attempt++) {
      int status;
      String? content;
      try {
        final res = await _client
            .post(
              config.completionsUri,
              headers: {
                'Authorization': 'Bearer ${config.apiKey}',
                'Content-Type': 'application/json',
                'X-Title': 'AcadAI Buddy',
              },
              body: body,
            )
            .timeout(timeout);
        status = res.statusCode;
        if (status == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes));
          // OpenRouter can report an upstream error inside a 200.
          final err = data is Map ? data['error'] : null;
          if (err is Map && err['code'] is int) {
            status = err['code'] as int;
          } else {
            final c = (data as Map)['choices']?[0]?['message']?['content'];
            content = c is String ? c.trim() : null;
            if (content == null || content.isEmpty) {
              return left(const _CallError(AiFailure.badResponse, 200));
            }
            return right(content);
          }
        }
      } catch (e) {
        return left(_CallError(aiFailureForException(e)));
      }

      final retriable = status == 429 || status >= 500;
      if (retriable && attempt < _backoff.length) {
        await _sleep(_backoff[attempt]);
        continue;
      }
      return left(_CallError(aiFailureForStatus(status), status));
    }
  }

  Map<String, dynamic> _imagePart(Uint8List bytes) => {
        'type': 'image_url',
        'image_url': {
          'url': 'data:${detectImageMime(bytes)};base64,${base64Encode(bytes)}',
        },
      };

  // ── IAiRepository ─────────────────────────────────────────────────────────

  /// Maps the last [historyLimit] messages to API messages.
  static List<Map<String, dynamic>> historyMessages(List<ChatMessage> history) {
    final recent = history.length > historyLimit
        ? history.sublist(history.length - historyLimit)
        : history;
    return [
      for (final m in recent)
        if (m.content.trim().isNotEmpty || m.hasImage)
          {
            'role': m.role == MessageRole.user ? 'user' : 'assistant',
            'content': m.content.trim().isEmpty ? '[image]' : m.content,
          },
    ];
  }

  @override
  Future<Either<AiFailure, String>> chat({
    required String subject,
    required List<ChatMessage> history,
    Uint8List? imageBytes,
  }) async {
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': tutorPrompt(subject)},
      ...historyMessages(history),
    ];
    if (imageBytes != null && messages.length > 1) {
      final last = messages.removeLast();
      final text = (last['content'] as String) == '[image]'
          ? 'Explain what this image shows and help me understand it.'
          : last['content'] as String;
      messages.add({
        'role': 'user',
        'content': [
          {'type': 'text', 'text': text},
          _imagePart(imageBytes),
        ],
      });
    }
    final r = await _complete(
      vision: imageBytes != null,
      messages: messages,
    );
    return r.leftMap((e) => e.failure);
  }

  @override
  Future<Either<AiFailure, String>> describeImage({
    required String prompt,
    required Uint8List bytes,
  }) async {
    final r = await _complete(
      vision: true,
      messages: [
        {'role': 'system', 'content': _studyPrompt},
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            _imagePart(bytes),
          ],
        },
      ],
    );
    return r.leftMap((e) => e.failure);
  }

  static String quizPrompt({
    required String subject,
    String? topic,
    required int count,
    required QuizDifficulty difficulty,
    String? sourceText,
  }) {
    final about = sourceText != null
        ? 'based only on the study material below'
        : topic == null || topic.isEmpty
            ? 'about $subject'
            : 'about "$topic" in $subject';
    final buffer = StringBuffer()
      ..writeln('Write $count ${difficulty.label.toLowerCase()} multiple-choice '
          'questions $about for university students.')
      ..writeln('Each question has exactly 4 options without letter prefixes, '
          'exactly one correct option, and a one or two sentence explanation.')
      ..writeln('Reply with JSON only, in this shape:')
      ..writeln('{"questions":[{"question":"...","options":["...","...","...","..."],'
          '"answerIndex":0,"explanation":"..."}]}')
      ..writeln('answerIndex is the 0-based index of the correct option. '
          'Use LaTeX with \$...\$ for math.');
    if (sourceText != null) {
      final text = sourceText.length > kMaxNoteLength
          ? sourceText.substring(0, kMaxNoteLength)
          : sourceText;
      buffer
        ..writeln()
        ..writeln('Study material:')
        ..writeln(text);
    }
    return buffer.toString();
  }

  Future<Either<AiFailure, List<QuizQuestion>>> _quizBatch(String prompt) async {
    final messages = [
      {'role': 'system', 'content': _studyPrompt},
      {'role': 'user', 'content': prompt},
    ];
    var r =
        await _complete(vision: false, messages: messages, jsonMode: true);
    // Some providers reject response_format; fall back to plain text.
    if (r.isLeft() && r.fold((e) => e.status == 400, (_) => false)) {
      r = await _complete(vision: false, messages: messages);
    }
    return r.fold(
      (e) => left(e.failure),
      (text) => right(parseQuizQuestions(text)),
    );
  }

  @override
  Future<Either<AiFailure, List<QuizQuestion>>> generateQuiz({
    required String subject,
    String? topic,
    required int count,
    QuizDifficulty difficulty = QuizDifficulty.medium,
    String? sourceText,
  }) async {
    // At most 10 per call; larger quizzes are split into parallel calls of 8.
    final batches =
        count <= 10 ? [count] : List.filled((count / 8).ceil(), 8);
    final results = await Future.wait(batches.map((n) => _quizBatch(quizPrompt(
          subject: subject,
          topic: topic,
          count: n,
          difficulty: difficulty,
          sourceText: sourceText,
        ))));

    final seen = <String>{};
    final questions = <QuizQuestion>[];
    AiFailure? firstFailure;
    for (final r in results) {
      r.fold(
        (f) => firstFailure ??= f,
        (qs) {
          for (final q in qs) {
            if (seen.add(q.question.toLowerCase())) questions.add(q);
          }
        },
      );
    }

    final kept = questions.take(count).toList();
    if (!enoughQuestions(kept.length, count)) {
      return left(firstFailure ?? AiFailure.badResponse);
    }
    return right(kept);
  }

  static String summaryInstruction(SummaryStyle style) => switch (style) {
        SummaryStyle.keyPoints =>
          'Summarize these university notes as Markdown bullet points grouped '
              'under short headings. Bold the key terms. End with a short '
              '"Key takeaways" list of three items.',
        SummaryStyle.examQuestions =>
          'From these notes, write 8 likely exam questions (a mix of short and '
              'long answer). After each, give a concise model answer.',
        SummaryStyle.flashcards =>
          'Turn these notes into 10 to 15 flashcards as a Markdown table with '
              'the columns "Front" and "Back". Keep each side short.',
        SummaryStyle.detailed =>
          'Write a detailed, well-structured study summary of these notes with '
              'headings, clear explanations and a worked example where useful.',
      };

  @override
  Future<Either<AiFailure, String>> summarize({
    String? text,
    Uint8List? imageBytes,
    SummaryStyle style = SummaryStyle.keyPoints,
  }) async {
    final instruction = summaryInstruction(style);
    if (imageBytes != null) {
      return describeImage(
        prompt: 'The image shows handwritten or printed study notes. '
            '$instruction',
        bytes: imageBytes,
      );
    }
    final notes = (text ?? '').trim();
    if (notes.isEmpty) return left(AiFailure.badResponse);
    final capped =
        notes.length > kMaxNoteLength ? notes.substring(0, kMaxNoteLength) : notes;
    final r = await _complete(vision: false, messages: [
      {'role': 'system', 'content': _studyPrompt},
      {'role': 'user', 'content': '$instruction\n\nNotes:\n$capped'},
    ]);
    return r.leftMap((e) => e.failure);
  }
}
