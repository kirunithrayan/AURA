import '../../../../workspace/domain/repositories/workspace_repository.dart';
import '../../../../workspace/domain/entities/workspace_file.dart';
import '../../../knowledge_graph/domain/entities/node_type.dart';
import '../../../knowledge_graph/domain/repositories/knowledge_graph_repository.dart';
import '../repositories/interaction_repository.dart';
import '../entities/workspace_insight.dart';

class WorkspaceInsightsService {

  WorkspaceInsightsService(
    this._workspaceRepository,
    this._graphRepository,
    this._interactionRepository,
  );
  final WorkspaceRepository _workspaceRepository;
  final KnowledgeGraphRepository _graphRepository;
  final InteractionRepository _interactionRepository;

  Future<WorkspaceInsight> generateInsight(String workspaceId) async {
    final workspaceResult = await _workspaceRepository.getWorkspaceFiles(workspaceId);
    final files = workspaceResult.getOrElse((_) => <WorkspaceFile>[]);
    final documentCount = files.length;

    final nodes = await _graphRepository.getNodesForWorkspace(workspaceId);
    final edges = await _graphRepository.getEdgesForWorkspace(workspaceId);

    final conversations = await _interactionRepository.getConversationSummaries(workspaceId);
    final conversationCount = conversations.length;

    int totalReadingTimeMs = 0;
    int viewedFilesCount = 0;
    
    // Sort concepts by frequency and confidence.
    // Document nodes live in the same table and would otherwise rank into
    // "Top Concepts" as file names, so keep concepts only.
    final sortedNodes = nodes.where((n) => n.type == NodeType.concept).toList()
      ..sort((a, b) => b.frequency.compareTo(a.frequency));
    final mostStudiedConcepts = sortedNodes.take(5).map((e) => e.label).toList();

    // Calculate reading time for workspace files
    for (var file in files) {
      final interaction = await _interactionRepository.getDocumentInteraction(file.id);
      if (interaction != null) {
        totalReadingTimeMs += interaction.readingTimeMs;
        viewedFilesCount++;
      }
    }

    final averageReadingTime = viewedFilesCount > 0 ? (totalReadingTimeMs ~/ viewedFilesCount) : 0;

    final searchInteractions = await _interactionRepository.getRecentSearchInteractions(10);
    final topSearches = searchInteractions.map((e) => e.query).toSet().take(5).toList();
    final favoriteFiles = files.where((f) => f.tags.contains('favorite')).map((f) => f.fileName).take(5).toList();
    
    int lastInteraction = 0;
    if (conversations.isNotEmpty) {
      lastInteraction = conversations.first.lastUpdated;
    }

    return WorkspaceInsight(
      documentCount: documentCount,
      conversationCount: conversationCount,
      knowledgeNodeCount: nodes.length,
      totalReadingTimeMs: totalReadingTimeMs,
      averageReadingTime: averageReadingTime,
      favoriteDocuments: favoriteFiles,
      mostStudiedConcepts: mostStudiedConcepts,
      topSearches: topSearches,
      knowledgeEdges: edges.length,
      lastInteraction: lastInteraction,
    );
  }
}
