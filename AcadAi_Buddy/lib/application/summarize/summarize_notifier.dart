import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_ai_app/application/summarize/summarize.dart';
import 'package:study_ai_app/domain/core/failures.dart';
import 'package:study_ai_app/domain/study/repositories/i_ai_repository.dart';
import 'package:study_ai_app/infrastructure/study/ai_service.dart';

class SummarizeNotifier extends StateNotifier<SummarizeState> {
  final IAiRepository _ai;

  SummarizeNotifier(this._ai) : super(const SummarizeInitial());

  Future<void> summarizeText(String notes) async {
    state = const SummarizeLoading();
    final r = await _ai.summarize(text: notes);
    state = r.fold((f) => SummarizeFailure(f.message), SummarizeLoaded.new);
  }

  Future<void> summarizeImage(Uint8List imageBytes) async {
    state = const SummarizeLoading();
    final r = await _ai.summarize(imageBytes: imageBytes);
    state = r.fold((f) => SummarizeFailure(f.message), SummarizeLoaded.new);
  }

  void reset() {
    state = const SummarizeInitial();
  }
}

final summarizeNotifierProvider =
    StateNotifierProvider<SummarizeNotifier, SummarizeState>((ref) {
  return SummarizeNotifier(ref.watch(aiRepositoryProvider));
});
