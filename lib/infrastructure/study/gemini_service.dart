import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:study_ai_app/domain/study/entities/quiz_message.dart';
import 'package:study_ai_app/infrastructure/study/dtos/quiz_questions_dtos.dart';

final geminiServiceProvider = Provider<GeminiService>(
  (ref) => GeminiService(),
);

class GeminiService {
  final String _apiKey = dotenv.env['OPENROUTER_API_KEY']!;
  final String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  final String _model = 'google/gemma-4-31b-it:free';
  // ☝️ Free model — no billing needed!

  final String _systemPrompt = 'You are AcadAI Buddy, an AI study assistant '
      'for Pakistani university students. Help with '
      'Programming, Discrete Math, OOP, Data Structures, '
      'Calculus, Physics. Explain clearly, mix simple '
      'English with Urdu when helpful.';

  Future<String> sendMessage(String prompt, String subject) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': '[$subject] $prompt'},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('OpenRouter error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> sendImageMessage(String prompt, Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'google/gemini-2.0-flash-exp:free',
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                }
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('OpenRouter error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<QuizQuestion>> generateQuiz(
      String subject, int numQuestions) async {
    try {
      final prompt = 'Generate $numQuestions MCQ questions about '
          '$subject for university students. '
          'Return ONLY a JSON array, no extra text, '
          'no markdown, only JSON:\n'
          '[{"question":"...","options":'
          '["A)...","B)...","C)...","D)..."],'
          '"answer":"A)..."}]';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'] as String;
        final clean =
            text.replaceAll('```json', '').replaceAll('```', '').trim();
        final List<dynamic> jsonList = jsonDecode(clean);
        return jsonList
            .map((e) =>
                QuizQuestionDto.fromJson(e as Map<String, dynamic>).toDomain())
            .toList();
      } else {
        throw Exception('OpenRouter error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Quiz generation error: $e');
    }
  }
}
