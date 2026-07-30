import '../entities/conversation_summary.dart';
import '../entities/document_interaction.dart';
import '../entities/search_interaction.dart';

abstract class InteractionRepository {
  Future<void> saveDocumentInteraction(DocumentInteraction interaction);
  Future<DocumentInteraction?> getDocumentInteraction(String documentId);
  Future<List<DocumentInteraction>> getRecentDocumentInteractions(int limit);
  
  Future<void> saveSearchInteraction(SearchInteraction interaction);
  Future<List<SearchInteraction>> getRecentSearchInteractions(int limit);
  
  Future<void> saveConversationSummary(ConversationSummary summary);
  Future<List<ConversationSummary>> getConversationSummaries(String workspaceId);
  Future<int> getConversationCount(String workspaceId);
  
  Future<void> clearMemory();
}
