class SearchCacheConfiguration {
  final int maxEntries;
  final int maxMemoryBytes;
  final Duration defaultTTL;
  final Duration cleanupInterval;
  final bool enableMetrics;

  const SearchCacheConfiguration({
    this.maxEntries = 50,
    this.maxMemoryBytes = 10 * 1024 * 1024, // 10 MB default
    this.defaultTTL = const Duration(minutes: 5),
    this.cleanupInterval = const Duration(minutes: 1),
    this.enableMetrics = true,
  });

  SearchCacheConfiguration copyWith({
    int? maxEntries,
    int? maxMemoryBytes,
    Duration? defaultTTL,
    Duration? cleanupInterval,
    bool? enableMetrics,
  }) {
    return SearchCacheConfiguration(
      maxEntries: maxEntries ?? this.maxEntries,
      maxMemoryBytes: maxMemoryBytes ?? this.maxMemoryBytes,
      defaultTTL: defaultTTL ?? this.defaultTTL,
      cleanupInterval: cleanupInterval ?? this.cleanupInterval,
      enableMetrics: enableMetrics ?? this.enableMetrics,
    );
  }
}
