import 'dart:collection';
import '../../../domain/entities/indexing/search_index.dart';

/// In-memory LRU cache for search indexes, with TTL-ready design.
class SearchIndexCache {
  final int _maxSize;
  final Duration _ttl;
  final LinkedHashMap<String, _IndexCacheEntry> _cache =
      LinkedHashMap<String, _IndexCacheEntry>();

  SearchIndexCache({
    int maxSize = 30,
    Duration ttl = const Duration(minutes: 10),
  })  : _maxSize = maxSize,
        _ttl = ttl;

  void put(String documentId, SearchIndex index) {
    if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[documentId] = _IndexCacheEntry(index: index, timestamp: DateTime.now());
  }

  SearchIndex? get(String documentId) {
    final entry = _cache[documentId];
    if (entry == null) return null;

    if (DateTime.now().difference(entry.timestamp) > _ttl) {
      _cache.remove(documentId);
      return null;
    }

    // Move to end for LRU
    _cache.remove(documentId);
    _cache[documentId] = entry;
    return entry.index;
  }

  void remove(String documentId) {
    _cache.remove(documentId);
  }

  void clear() {
    _cache.clear();
  }

  bool contains(String documentId) {
    return get(documentId) != null;
  }
}

class _IndexCacheEntry {
  final SearchIndex index;
  final DateTime timestamp;

  _IndexCacheEntry({required this.index, required this.timestamp});
}
