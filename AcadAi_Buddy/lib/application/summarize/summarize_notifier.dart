import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_ai_app/application/summarize/summarize.dart';
import 'package:study_ai_app/domain/study/entities/study_options.dart';
import 'package:study_ai_app/domain/study/repositories/i_ai_repository.dart';
import 'package:study_ai_app/infrastructure/study/ai_service.dart';

class SummarizeNotifier extends StateNotifier<SummarizeState> {
  final IAiRepository _ai;
  int _requestId = 0;

  SummarizeNotifier(this._ai) : super(const SummarizeInitial());

  /// Summarizes typed notes (capped at [kMaxNoteLength]) or a photo.
  Future<void> summarize({
    String? text,
    Uint8List? imageBytes,
    SummaryStyle style = SummaryStyle.keyPoints,
  }) async {
    final id = ++_requestId;
    state = const SummarizeLoading();
    final r = await _ai.summarize(text: text, imageBytes: imageBytes, style: style);
    if (!mounted || id != _requestId) return;
    state = r.fold(SummarizeFailure.new, SummarizeLoaded.new);
  }

  Future<void> summarizeText(String notes) => summarize(text: notes);

  Future<void> summarizeImage(Uint8List imageBytes) =>
      summarize(imageBytes: imageBytes);

  void reset() {
    _requestId++;
    state = const SummarizeInitial();
  }
}

final summarizeNotifierProvider =
    StateNotifierProvider.autoDispose<SummarizeNotifier, SummarizeState>((ref) {
  return SummarizeNotifier(ref.watch(aiRepositoryProvider));
});
