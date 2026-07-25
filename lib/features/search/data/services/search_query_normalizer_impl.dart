import '../../domain/entities/search_query.dart';
import '../../domain/entities/optimization/normalized_search_query.dart';
import '../../domain/services/search_query_normalizer.dart';
import '../../../../core/text_engine/abstract_text_document_engine.dart';
// Note: We use AbstractTextDocumentEngine just to ensure we share standard tokenization logic if needed, 
// though typical normalization is simpler here.

class SearchQueryNormalizerImpl implements SearchQueryNormalizer {
  final AbstractTextDocumentEngine _textEngine;

  SearchQueryNormalizerImpl(this._textEngine);

  @override
  NormalizedSearchQuery normalize(SearchQuery query) {
    final keyword = query.keyword;
    
    // Lowercase
    String normalized = keyword.toLowerCase();
    
    // Remove extra whitespace
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Tokenize
    final rawTokens = normalized.split(' ').where((e) => e.isNotEmpty).toList();
    
    // Deduplicate
    final uniqueTokens = rawTokens.toSet().toList();
    
    // Rebuild string
    final deduplicatedKeyword = uniqueTokens.join(' ');
    
    return NormalizedSearchQuery(
      originalKeyword: keyword,
      normalizedKeyword: deduplicatedKeyword,
      normalizedTokens: uniqueTokens,
    );
  }
}
