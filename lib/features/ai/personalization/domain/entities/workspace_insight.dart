class WorkspaceInsight {

  const WorkspaceInsight({
    required this.documentCount,
    required this.conversationCount,
    required this.knowledgeNodeCount,
    required this.totalReadingTimeMs,
    required this.averageReadingTime,
    required this.favoriteDocuments,
    required this.mostStudiedConcepts,
    required this.topSearches,
    required this.knowledgeEdges,
    required this.lastInteraction,
  });
  final int documentCount;
  final int conversationCount;
  final int knowledgeNodeCount;
  final int totalReadingTimeMs;
  final int averageReadingTime;
  final List<String> favoriteDocuments;
  final List<String> mostStudiedConcepts;
  final List<String> topSearches;
  final int knowledgeEdges;
  final int lastInteraction;
}
