import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/services/rag_service.dart';
import '../../domain/entities/ai_config.dart';
import '../../domain/entities/conversation.dart';
import 'ask_aura_state.dart';
import '../../../../../core/di/injection_container.dart';

final askAuraViewModelProvider = StateNotifierProvider<AskAuraViewModel, AskAuraState>((ref) => AskAuraViewModel(sl<RAGService>(), sl<AiConfig>()));

class AskAuraViewModel extends StateNotifier<AskAuraState> {

  AskAuraViewModel(this._ragService, this._aiConfig) : super(const AskAuraState());
  final RAGService _ragService;
  final AiConfig _aiConfig;
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
      final stream = _ragService.streamAskDocument(query, _aiConfig);
      
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
