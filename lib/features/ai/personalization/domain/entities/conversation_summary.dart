class ConversationSummary {

  const ConversationSummary({
    required this.id,
    required this.conversationId,
    required this.workspaceId,
    required this.summary,
    required this.topics,
    required this.messageCount,
    required this.lastUpdated,
    required this.createdAt,
  });
  final String id;
  final String conversationId;
  final String workspaceId;
  final String summary;
  final List<String> topics;
  final int messageCount;
  final int lastUpdated;
  final int createdAt;

  ConversationSummary copyWith({
    String? id,
    String? conversationId,
    String? workspaceId,
    String? summary,
    List<String>? topics,
    int? messageCount,
    int? lastUpdated,
    int? createdAt,
  }) => ConversationSummary(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      workspaceId: workspaceId ?? this.workspaceId,
      summary: summary ?? this.summary,
      topics: topics ?? this.topics,
      messageCount: messageCount ?? this.messageCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
}
