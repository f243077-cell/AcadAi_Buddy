import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_ai_app/application/summarize/summarize.dart';
import 'package:study_ai_app/infrastructure/study/gemini_service.dart';

class SummarizeNotifier extends StateNotifier<SummarizeState> {
  final GeminiService _geminiService;

  SummarizeNotifier(this._geminiService) : super(const SummarizeInitial());

  static const _summarizePromptSuffix =
      'Summarize these university notes in clear bullet points. '
      'Highlight the most important key concepts. Then list 3 most '
      'likely exam questions from this topic.';

  Future<void> summarizeText(String notes) async {
    state = const SummarizeLoading();
    try {
      final prompt = '$_summarizePromptSuffix\n\n$notes';
      final response = await _geminiService.sendMessage(prompt, 'general');
      state = SummarizeLoaded(response);
    } catch (e) {
      state = SummarizeFailure(e.toString());
    }
  }

  Future<void> summarizeImage(Uint8List imageBytes) async {
    state = const SummarizeLoading();
    try {
      final response = await _geminiService.sendImageMessage(
        _summarizePromptSuffix,
        imageBytes,
      );
      state = SummarizeLoaded(response);
    } catch (e) {
      state = SummarizeFailure(e.toString());
    }
  }

  void reset() {
    state = const SummarizeInitial();
  }
}

final summarizeNotifierProvider =
    StateNotifierProvider<SummarizeNotifier, SummarizeState>((ref) {
  return SummarizeNotifier(ref.watch(geminiServiceProvider));
});
