import '../../features/workspace/domain/entities/workspace_file.dart';
import 'models/text_document.dart';
import '../../features/document_viewer/domain/entities/viewer_search_result.dart';
import '../../features/document_viewer/data/cache/document_cache.dart';

import 'abstract_text_document_engine.dart';
import 'parsers/parser_registry.dart';

class TextEngineImpl implements AbstractTextDocumentEngine {
  final DocumentCache _cache;
  TextDocument? _currentDocument;
  Map<String, dynamic> _metadata = {};
  double _scrollPosition = 0.0;

  TextEngineImpl(this._cache);

  @override
  Future<TextDocument> openDocument(WorkspaceFile file) async {
    // Check cache first
    final cached = _cache.get(file.id);
    if (cached != null) {
      _currentDocument = cached;
      return cached;
    }

    final ext = file.extension ?? '';
    final parser = ParserRegistry.getParserForExtension(ext);
    
    if (parser == null) {
      throw Exception('Unsupported text format: $ext');
    }

    _metadata = await parser.extractMetadata(file);
    final doc = await parser.parse(file);
    
    _cache.put(file.id, doc);
    _currentDocument = doc;
    
    return doc;
  }

  @override
  void close() {
    _currentDocument = null;
    _metadata.clear();
  }

  @override
  TextDocument? getDocument() {
    return _currentDocument;
  }

  @override
  Map<String, dynamic> getMetadata() {
    return _metadata;
  }

  @override
  double getScrollPosition() {
    return _scrollPosition;
  }

  @override
  void setScrollPosition(double position) {
    _scrollPosition = position;
  }

  @override
  ViewerSearchResult search(String keyword) {
    throw UnimplementedError('Search not implemented in Phase 4');
  }
}
