class DiagnosticsState {

  const DiagnosticsState({
    this.documentsIndexed = 0,
    this.embeddingCount = 0,
    this.cacheHits = 0,
    this.cacheMisses = 0,
    this.averageSearchTime = Duration.zero,
    this.averageIndexingTime = Duration.zero,
    this.knowledgeNodes = 0,
    this.knowledgeEdges = 0,
    this.databaseSizeBytes = 0,
    this.isLoading = false,
    this.errorMessage,
  });
  final int documentsIndexed;
  final int embeddingCount;
  final int cacheHits;
  final int cacheMisses;
  final Duration averageSearchTime;
  final Duration averageIndexingTime;
  final int knowledgeNodes;
  final int knowledgeEdges;
  final int databaseSizeBytes;
  final bool isLoading;
  final String? errorMessage;

  DiagnosticsState copyWith({
    int? documentsIndexed,
    int? embeddingCount,
    int? cacheHits,
    int? cacheMisses,
    Duration? averageSearchTime,
    Duration? averageIndexingTime,
    int? knowledgeNodes,
    int? knowledgeEdges,
    int? databaseSizeBytes,
    bool? isLoading,
    String? errorMessage,
  }) => DiagnosticsState(
      documentsIndexed: documentsIndexed ?? this.documentsIndexed,
      embeddingCount: embeddingCount ?? this.embeddingCount,
      cacheHits: cacheHits ?? this.cacheHits,
      cacheMisses: cacheMisses ?? this.cacheMisses,
      averageSearchTime: averageSearchTime ?? this.averageSearchTime,
      averageIndexingTime: averageIndexingTime ?? this.averageIndexingTime,
      knowledgeNodes: knowledgeNodes ?? this.knowledgeNodes,
      knowledgeEdges: knowledgeEdges ?? this.knowledgeEdges,
      databaseSizeBytes: databaseSizeBytes ?? this.databaseSizeBytes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
}
