import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/domain/study/entities/chat_message.dart';
import 'package:study_ai_app/infrastructure/study/ai_config.dart';
import 'package:study_ai_app/infrastructure/study/ai_service.dart';

http.Response _ok(String content) => http.Response(
      jsonEncode({
        'choices': [
          {
            'message': {'content': content}
          }
        ]
      }),
      200,
    );

ChatMessage _msg(int i, MessageRole role) => ChatMessage(
      id: '$i',
      content: 'message $i',
      role: role,
      timestamp: DateTime(2026, 1, 1, 0, i),
      chatId: 'c',
    );

void main() {
  const config = AiConfig(apiKey: 'test-key');
  final sleeps = <Duration>[];
  Future<void> fakeSleep(Duration d) async => sleeps.add(d);

  setUp(sleeps.clear);

  AiService service(MockClientHandler handler,
          {Duration timeout = const Duration(seconds: 45)}) =>
      AiService(config,
          client: MockClient(handler), sleep: fakeSleep, timeout: timeout);

  test('sends the system prompt plus the last 12 messages with roles',
      () async {
    late Map<String, dynamic> body;
    final ai = service((req) async {
      body = jsonDecode(req.body) as Map<String, dynamic>;
      return _ok('hi');
    });
    final history = [
      for (var i = 0; i < 20; i++)
        _msg(i, i.isEven ? MessageRole.user : MessageRole.model),
    ];
    final r = await ai.chat(subject: 'Calculus', history: history);
    expect(r.getOrElse(() => ''), 'hi');

    final messages = body['messages'] as List;
    expect(messages.first['role'], 'system');
    expect(messages.first['content'], contains('Calculus'));
    expect(messages.length, 13);
    expect(messages[1]['content'], 'message 8');
    expect(messages[2]['role'], 'assistant');
    expect(messages.last['content'], 'message 19');
  });

  test('retries 429 twice with 1 s / 3 s backoff, then succeeds', () async {
    var calls = 0;
    final ai = service((_) async {
      calls++;
      return calls < 3 ? http.Response('busy', 429) : _ok('done');
    });
    final r = await ai.chat(subject: 's', history: [_msg(0, MessageRole.user)]);
    expect(r.isRight(), isTrue);
    expect(calls, 3);
    expect(sleeps, [const Duration(seconds: 1), const Duration(seconds: 3)]);
  });

  test('gives up after two retries with rateLimited', () async {
    var calls = 0;
    final ai = service((_) async {
      calls++;
      return http.Response('busy', 429);
    });
    final r = await ai.chat(subject: 's', history: [_msg(0, MessageRole.user)]);
    expect(r.fold((f) => f, (_) => null), AiFailure.rateLimited);
    expect(calls, 3);
  });

  test('does not retry 401 and maps it to unauthorized', () async {
    var calls = 0;
    final ai = service((_) async {
      calls++;
      return http.Response('no', 401);
    });
    final r = await ai.chat(subject: 's', history: [_msg(0, MessageRole.user)]);
    expect(r.fold((f) => f, (_) => null), AiFailure.unauthorized);
    expect(calls, 1);
  });

  test('maps exceptions: offline, timeout, garbled body', () async {
    final offline = service((_) async => throw const SocketException('down'));
    expect(
        (await offline.chat(subject: 's', history: [_msg(0, MessageRole.user)]))
            .fold((f) => f, (_) => null),
        AiFailure.offline);

    final slow = service(
      (_) => Completer<http.Response>().future,
      timeout: const Duration(milliseconds: 10),
    );
    expect(
        (await slow.chat(subject: 's', history: [_msg(0, MessageRole.user)]))
            .fold((f) => f, (_) => null),
        AiFailure.timeout);

    final garbled = service((_) async => http.Response('not json', 200));
    expect(
        (await garbled.chat(subject: 's', history: [_msg(0, MessageRole.user)]))
            .fold((f) => f, (_) => null),
        AiFailure.badResponse);
  });

  test('an error inside a 200 body is mapped by its code', () async {
    final ai = service((_) async => http.Response(
        jsonEncode({
          'error': {'code': 401, 'message': 'bad key'}
        }),
        200));
    final r = await ai.chat(subject: 's', history: [_msg(0, MessageRole.user)]);
    expect(r.fold((f) => f, (_) => null), AiFailure.unauthorized);
  });

  test('missing API key fails fast without a request', () async {
    var calls = 0;
    final ai = AiService(const AiConfig(apiKey: ''),
        client: MockClient((_) async {
      calls++;
      return _ok('x');
    }));
    final r = await ai.chat(subject: 's', history: [_msg(0, MessageRole.user)]);
    expect(r.fold((f) => f, (_) => null), AiFailure.unauthorized);
    expect(calls, 0);
  });

  test('image chat uses the vision model and a typed data URL', () async {
    late Map<String, dynamic> body;
    final ai = AiService(
      const AiConfig(apiKey: 'k', model: 'text-m', visionModel: 'vision-m'),
      client: MockClient((req) async {
        body = jsonDecode(req.body) as Map<String, dynamic>;
        return _ok('a graph');
      }),
    );
    final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0, 0, 0, 0]);
    await ai.chat(
        subject: 's', history: [_msg(0, MessageRole.user)], imageBytes: png);
    expect(body['model'], 'vision-m');
    final parts = (body['messages'] as List).last['content'] as List;
    expect(parts[1]['image_url']['url'], startsWith('data:image/png;base64,'));
  });

  test('detectImageMime', () {
    expect(detectImageMime(Uint8List.fromList([0xFF, 0xD8, 0xFF, 0])),
        'image/jpeg');
    expect(detectImageMime(Uint8List.fromList([0x47, 0x49, 0x46, 0x38])),
        'image/gif');
    expect(
        detectImageMime(Uint8List.fromList(
            [0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50])),
        'image/webp');
  });

  test('status mapping', () {
    expect(aiFailureForStatus(402), AiFailure.unauthorized);
    expect(aiFailureForStatus(503), AiFailure.rateLimited);
    expect(aiFailureForStatus(500), AiFailure.unknown);
  });
}
