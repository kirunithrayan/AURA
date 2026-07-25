import 'dart:collection';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/optimization/search_cache_key.dart';
import '../../domain/entities/optimization/search_cache_statistics.dart';
import '../../domain/entities/optimization/search_cache_configuration.dart';
import '../../domain/cache/abstract_search_cache.dart';

class SearchCache implements AbstractSearchCache {
  final SearchCacheConfiguration _config;
  final LinkedHashMap<SearchCacheKey, _CacheEntry> _cache = LinkedHashMap<SearchCacheKey, _CacheEntry>();
  
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;

  SearchCache(this._config);

  @override
  void put(SearchCacheKey key, List<SearchResult> results) {
    if (_cache.containsKey(key)) {
      _cache.remove(key); // Remove to re-insert at the end (LRU)
    } else if (_cache.length >= _config.maxEntries) {
      _cache.remove(_cache.keys.first);
      _evictions++;
    }
    _cache[key] = _CacheEntry(results: List.unmodifiable(results), timestamp: DateTime.now());
  }

  @override
  List<SearchResult>? get(SearchCacheKey key) {
    final entry = _cache[key];
    if (entry == null) {
      if (_config.enableMetrics) _misses++;
      return null;
    }
    
    // Check TTL
    if (DateTime.now().difference(entry.timestamp) > _config.defaultTTL) {
      _cache.remove(key);
      if (_config.enableMetrics) _misses++;
      return null;
    }
    
    if (_config.enableMetrics) _hits++;
    // Move to end to maintain LRU
    _cache.remove(key);
    _cache[key] = entry;
    
    return entry.results;
  }
  
  @override
  void invalidate() {
    _cache.clear();
    _hits = 0;
    _misses = 0;
    _evictions = 0;
  }

  @override
  SearchCacheStatistics getStatistics() {
    return SearchCacheStatistics(
      totalHits: _hits,
      totalMisses: _misses,
      currentSize: _cache.length,
      maxSize: _config.maxEntries,
      evictions: _evictions,
    );
  }
}

class _CacheEntry {
  final List<SearchResult> results;
  final DateTime timestamp;

  const _CacheEntry({required this.results, required this.timestamp});
}
