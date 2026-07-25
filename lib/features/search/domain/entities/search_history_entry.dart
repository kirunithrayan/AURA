class SearchHistoryEntry {
  final String id;
  final String query;
  final DateTime searchedAt;
  final DateTime lastUsed;
  final int hitCount;
  final bool pinned;
  final String? workspaceId;
  final int resultCount;

  const SearchHistoryEntry({
    required this.id,
    required this.query,
    required this.searchedAt,
    required this.lastUsed,
    required this.hitCount,
    required this.pinned,
    this.workspaceId,
    required this.resultCount,
  });

  SearchHistoryEntry copyWith({
    String? id,
    String? query,
    DateTime? searchedAt,
    DateTime? lastUsed,
    int? hitCount,
    bool? pinned,
    String? workspaceId,
    int? resultCount,
  }) {
    return SearchHistoryEntry(
      id: id ?? this.id,
      query: query ?? this.query,
      searchedAt: searchedAt ?? this.searchedAt,
      lastUsed: lastUsed ?? this.lastUsed,
      hitCount: hitCount ?? this.hitCount,
      pinned: pinned ?? this.pinned,
      workspaceId: workspaceId ?? this.workspaceId,
      resultCount: resultCount ?? this.resultCount,
    );
  }
}
