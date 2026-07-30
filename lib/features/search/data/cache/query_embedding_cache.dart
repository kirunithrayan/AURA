/// Cache for storing query embeddings to avoid re-generating them during the same session.
class QueryEmbeddingCache {
  final Map<String, List<double>> _cache = {};
  
  // Basic LRU or limit could be added here.
  static const int _maxCacheSize = 100;

  /// Retrieves a cached embedding for a query if it exists.
  List<double>? get(String query) => _cache[query];

  /// Caches an embedding for a query.
  void put(String query, List<double> embedding) {
    if (_cache.length >= _maxCacheSize) {
      // Remove the first entry if we hit the limit
      _cache.remove(_cache.keys.first);
    }
    _cache[query] = embedding;
  }

  /// Clears the cache.
  void clear() {
    _cache.clear();
  }
}
