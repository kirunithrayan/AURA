import '../../../../core/text_engine/models/text_document.dart';

class DocumentCache {
  final Map<String, TextDocument> _cache = {};

  TextDocument? get(String fileId) => _cache[fileId];

  void put(String fileId, TextDocument document) {
    _cache[fileId] = document;
  }

  void remove(String fileId) {
    _cache.remove(fileId);
  }

  void clear() {
    _cache.clear();
  }
}
