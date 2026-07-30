class DocumentInteraction {

  const DocumentInteraction({
    required this.id,
    required this.documentId,
    required this.viewCount,
    required this.readingTimeMs,
    required this.lastViewedAt,
  });
  final String id;
  final String documentId;
  final int viewCount;
  final int readingTimeMs;
  final int lastViewedAt;

  DocumentInteraction copyWith({
    String? id,
    String? documentId,
    int? viewCount,
    int? readingTimeMs,
    int? lastViewedAt,
  }) => DocumentInteraction(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      viewCount: viewCount ?? this.viewCount,
      readingTimeMs: readingTimeMs ?? this.readingTimeMs,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
    );
}
