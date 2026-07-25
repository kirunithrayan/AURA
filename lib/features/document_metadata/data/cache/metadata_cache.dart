import '../../domain/entities/document_metadata.dart';

class MetadataCache {
  final Map<String, DocumentMetadata> _cache = {};

  DocumentMetadata? get(String id) {
    return _cache[id];
  }

  void put(String id, DocumentMetadata metadata) {
    _cache[id] = metadata;
  }

  void remove(String id) {
    _cache.remove(id);
  }

  void clear() {
    _cache.clear();
  }
}
