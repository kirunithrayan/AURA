import 'dart:async';
import '../entities/ai_config.dart';
import '../entities/ai_response.dart';

abstract class RAGService {
  /// Stream a RAG response for the given query.
  /// Handles searching, building context, creating the prompt, and calling the AI provider.
  Stream<AiResponse> streamAskDocument(String query, AiConfig config);
  
  /// Awaits and returns a complete RAG response.
  Future<AiResponse> askDocument(String query, AiConfig config);
}
