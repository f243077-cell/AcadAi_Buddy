import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AI endpoint configuration, read from `.env` with defaults.
///
/// `.env` keys: OPENROUTER_API_KEY, AI_BASE_URL, AI_MODEL, AI_VISION_MODEL,
/// AI_FALLBACK_MODELS, AI_VISION_FALLBACK_MODELS (comma-separated, or
/// `none`). AI_BASE_URL can point at a proxy that holds the key server-side.
///
/// Free models are often rate-limited upstream, so each request carries a
/// fallback list: OpenRouter moves to the next model when one is busy.
class AiConfig {
  const AiConfig({
    required this.apiKey,
    this.baseUrl = defaultBaseUrl,
    this.model = defaultModel,
    this.visionModel = defaultModel,
    this.fallbackModels = const [],
    this.visionFallbackModels = const [],
  });

  static const defaultBaseUrl = 'https://openrouter.ai/api/v1';
  static const defaultModel = 'google/gemma-4-31b-it:free';
  static const defaultFallbacks = [
    'nvidia/nemotron-3-super-120b-a12b:free',
    'openrouter/free',
  ];
  static const defaultVisionFallbacks = [
    'qwen/qwen3.8-27b:free',
    'openrouter/free',
  ];

  /// OpenRouter accepts at most this many models per request.
  static const maxModelsPerRequest = 3;

  final String apiKey;
  final String baseUrl;
  final String model;
  final String visionModel;
  final List<String> fallbackModels;
  final List<String> visionFallbackModels;

  Uri get completionsUri => Uri.parse(
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/chat/completions');

  /// Primary model followed by its fallbacks, de-duplicated and capped.
  List<String> chainFor({required bool vision}) {
    final primary = vision ? visionModel : model;
    final rest = vision ? visionFallbackModels : fallbackModels;
    return {primary, ...rest}.take(maxModelsPerRequest).toList();
  }

  factory AiConfig.fromEnv() {
    String read(String key, String fallback) {
      final v = dotenv.isInitialized ? dotenv.env[key]?.trim() : null;
      return (v == null || v.isEmpty) ? fallback : v;
    }

    List<String> readList(String key, List<String> fallback) {
      final v = dotenv.isInitialized ? dotenv.env[key]?.trim() : null;
      if (v == null || v.isEmpty) return fallback;
      if (v.toLowerCase() == 'none') return const [];
      return v
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final model = read('AI_MODEL', defaultModel);
    return AiConfig(
      apiKey: read('OPENROUTER_API_KEY', ''),
      baseUrl: read('AI_BASE_URL', defaultBaseUrl),
      model: model,
      visionModel: read('AI_VISION_MODEL', model),
      fallbackModels: readList('AI_FALLBACK_MODELS', defaultFallbacks),
      visionFallbackModels:
          readList('AI_VISION_FALLBACK_MODELS', defaultVisionFallbacks),
    );
  }
}
