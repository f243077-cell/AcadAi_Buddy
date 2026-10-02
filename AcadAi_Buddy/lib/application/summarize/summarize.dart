import 'package:study_ai_app/domain/core/failures.dart';

abstract class SummarizeState {
  const SummarizeState();
}

class SummarizeInitial extends SummarizeState {
  const SummarizeInitial();
}

class SummarizeLoading extends SummarizeState {
  const SummarizeLoading();
}

class SummarizeLoaded extends SummarizeState {
  final String summary;
  const SummarizeLoaded(this.summary);
}

class SummarizeFailure extends SummarizeState {
  final AiFailure failure;
  const SummarizeFailure(this.failure);

  /// Friendly text; never raw exception output.
  String get error => failure.message;
}
