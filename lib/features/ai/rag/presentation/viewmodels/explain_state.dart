import '../../domain/entities/ai_response.dart';

enum ExplainStatus { initial, loading, streaming, complete, error }

/// State for the selection-triggered explanation surface.
///
/// Deliberately separate from [AskAuraState]: an explanation is a one-shot
/// answer about a selection and must never mutate the routed conversation.
class ExplainState {
  const ExplainState({
    this.status = ExplainStatus.initial,
    this.selection = '',
    this.response,
    this.errorMessage,
  });

  final ExplainStatus status;
  final String selection;
  final AiResponse? response;
  final String? errorMessage;

  ExplainState copyWith({
    ExplainStatus? status,
    String? selection,
    AiResponse? response,
    String? errorMessage,
  }) =>
      ExplainState(
        status: status ?? this.status,
        selection: selection ?? this.selection,
        response: response ?? this.response,
        errorMessage: errorMessage,
      );
}
