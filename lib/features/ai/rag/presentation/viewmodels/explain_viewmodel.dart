import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/di/injection_container.dart';
import '../../domain/entities/ai_config.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/errors/ai_errors.dart';
import '../../domain/services/ai_key_store.dart';
import '../../domain/services/rag_service.dart';
import 'explain_state.dart';

final explainViewModelProvider =
    StateNotifierProvider.autoDispose<ExplainViewModel, ExplainState>(
  (ref) => ExplainViewModel(sl<RAGService>(), sl<AiConfig>(), sl<AiKeyStore>()),
);

/// Drives the selection-triggered explanation.
///
/// Consumes the same RAG stream as the routed conversation but keeps its own
/// state, so an explanation never appends to the conversation history.
class ExplainViewModel extends StateNotifier<ExplainState> {
  ExplainViewModel(this._ragService, this._defaults, this._keyStore)
      : super(const ExplainState());

  final RAGService _ragService;
  final AiConfig _defaults;
  final AiKeyStore _keyStore;

  /// Explains [selection]. The selected text is passed through unchanged.
  Future<void> explain(String selection) async {
    if (selection.trim().isEmpty) return;

    state = ExplainState(
      status: ExplainStatus.loading,
      selection: selection,
    );

    try {
      // Same configuration path the routed conversation uses: the key is read
      // at the point of use and a missing key is surfaced, never defaulted.
      final String? apiKey = await _keyStore.readApiKey();
      if (apiKey == null) {
        throw const MissingApiKeyException('gemini');
      }

      final AiConfig config = AiConfig(
        apiKey: apiKey,
        providerName: _defaults.providerName,
        modelName: _defaults.modelName,
        temperature: _defaults.temperature,
        similarityThreshold: _defaults.similarityThreshold,
      );

      final Stream<AiResponse> stream =
          _ragService.streamAskDocument(selection, config);

      await for (final AiResponse response in stream) {
        if (!mounted) return;
        state = state.copyWith(
          status: ExplainStatus.streaming,
          response: response,
        );
      }

      if (!mounted) return;
      state = state.copyWith(status: ExplainStatus.complete);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: ExplainStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
