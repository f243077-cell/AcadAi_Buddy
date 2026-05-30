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
  final String error;
  const SummarizeFailure(this.error);
}
