import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/services/rag_service.dart';
import '../../domain/services/ai_key_store.dart';
import '../../domain/entities/ai_config.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/errors/ai_errors.dart';
import 'ask_aura_state.dart';
import '../../../../../core/di/injection_container.dart';

final askAuraViewModelProvider = StateNotifierProvider<AskAuraViewModel, AskAuraState>(
  (ref) => AskAuraViewModel(sl<RAGService>(), sl<AiConfig>(), sl<AiKeyStore>()),
);

class AskAuraViewModel extends StateNotifier<AskAuraState> {

  AskAuraViewModel(this._ragService, this._defaults, this._keyStore) : super(const AskAuraState());
  final RAGService _ragService;
  final AiConfig _defaults;
  final AiKeyStore _keyStore;
  final _uuid = const Uuid();

  void initConversation(String workspaceId) {
    if (state.activeConversation != null && state.activeConversation!.workspaceId == workspaceId) {
      return;
    }
    
    final newConv = Conversation(
      id: _uuid.v4(),
      title: 'New Chat',
      workspaceId: workspaceId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    state = state.copyWith(activeConversation: newConv, status: AskAuraStatus.initial);
  }

  Future<void> submitQuery(String query) async {
    if (state.activeConversation == null) return;
    if (query.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: query,
      timestamp: DateTime.now(),
    );

    final updatedConv = state.activeConversation!.copyWith(
      messages: [...state.activeConversation!.messages, userMessage],
    );

    state = state.copyWith(
      activeConversation: updatedConv,
      status: AskAuraStatus.loading,
      errorMessage: null,
      latestResponse: null,
    );

    try {
      // Read the user-supplied key at the point of use. A missing key is a
      // configuration error surfaced to the user, not a silent fallback.
      final apiKey = await _keyStore.readApiKey();
      if (apiKey == null) {
        throw const MissingApiKeyException('gemini');
      }

      final config = AiConfig(
        apiKey: apiKey,
        providerName: _defaults.providerName,
        modelName: _defaults.modelName,
        temperature: _defaults.temperature,
        similarityThreshold: _defaults.similarityThreshold,
      );

      final stream = _ragService.streamAskDocument(query, config);

      await for (final response in stream) {
        state = state.copyWith(
          status: AskAuraStatus.streaming,
          latestResponse: response,
        );
      }

      // Done streaming, save as ai message
      if (state.latestResponse != null) {
        final aiMessage = ChatMessage(
          id: _uuid.v4(),
          role: MessageRole.ai,
          content: state.latestResponse!.text,
          timestamp: DateTime.now(),
        );

        final finalConv = state.activeConversation!.copyWith(
          messages: [...state.activeConversation!.messages, aiMessage],
          updatedAt: DateTime.now(),
        );

        state = state.copyWith(
          status: AskAuraStatus.complete,
          activeConversation: finalConv,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AskAuraStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
