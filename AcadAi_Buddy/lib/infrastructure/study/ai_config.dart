import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AI endpoint configuration, read from `.env` with defaults.
///
/// `.env` keys: OPENROUTER_API_KEY, AI_BASE_URL, AI_MODEL, AI_VISION_MODEL.
/// AI_BASE_URL can point at a proxy that holds the key server-side.
class AiConfig {
  const AiConfig({
    required this.apiKey,
    this.baseUrl = defaultBaseUrl,
    this.model = defaultModel,
    this.visionModel = defaultModel,
  });

  static const defaultBaseUrl = 'https://openrouter.ai/api/v1';
  static const defaultModel = 'google/gemma-4-31b-it:free';

  final String apiKey;
  final String baseUrl;
  final String model;
  final String visionModel;

  Uri get completionsUri => Uri.parse(
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/chat/completions');

  factory AiConfig.fromEnv() {
    String read(String key, String fallback) {
      final v = dotenv.isInitialized ? dotenv.env[key]?.trim() : null;
      return (v == null || v.isEmpty) ? fallback : v;
    }

    final model = read('AI_MODEL', defaultModel);
    return AiConfig(
      apiKey: read('OPENROUTER_API_KEY', ''),
      baseUrl: read('AI_BASE_URL', defaultBaseUrl),
      model: model,
      visionModel: read('AI_VISION_MODEL', model),
    );
  }
}
