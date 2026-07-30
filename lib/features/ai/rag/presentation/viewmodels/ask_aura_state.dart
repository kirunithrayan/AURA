import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/ai_response.dart';

enum AskAuraStatus { initial, loading, streaming, complete, error }

class AskAuraState extends Equatable { // holds current streaming state

  const AskAuraState({
    this.activeConversation,
    this.status = AskAuraStatus.initial,
    this.errorMessage,
    this.latestResponse,
  });
  final Conversation? activeConversation;
  final AskAuraStatus status;
  final String? errorMessage;
  final AiResponse? latestResponse;

  AskAuraState copyWith({
    Conversation? activeConversation,
    AskAuraStatus? status,
    String? errorMessage,
    AiResponse? latestResponse,
  }) => AskAuraState(
      activeConversation: activeConversation ?? this.activeConversation,
      status: status ?? this.status,
      errorMessage: errorMessage,
      latestResponse: latestResponse ?? this.latestResponse,
    );

  @override
  List<Object?> get props => [
        activeConversation,
        status,
        errorMessage,
        latestResponse,
      ];
}
