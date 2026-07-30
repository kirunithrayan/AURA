import '../../../domain/entities/search_query.dart';
import '../../indexing/tokenizer/abstract_tokenizer.dart';
import '../../indexing/normalizer/abstract_token_normalizer.dart';
import '../../indexing/filter/abstract_stop_word_filter.dart';

/// A processed query ready for index matching.
class ProcessedQuery {

  const ProcessedQuery({
    required this.rawKeyword,
    required this.tokens,
    required this.isPhraseSearch,
    required this.isEmpty,
  });
  final String rawKeyword;
  final List<String> tokens;
  final bool isPhraseSearch;
  final bool isEmpty;
}

/// Contract for processing raw search queries into normalized, validated tokens.
abstract class AbstractQueryProcessor {
  ProcessedQuery process(SearchQuery query);
}

/// Default query processor: normalizes, tokenizes, removes stop words.
/// Detects phrase search when the keyword is wrapped in double quotes.
class DefaultQueryProcessor implements AbstractQueryProcessor {

  const DefaultQueryProcessor(
    this._tokenizer,
    this._normalizer,
    this._stopWordFilter,
  );
  final AbstractTokenizer _tokenizer;
  final AbstractTokenNormalizer _normalizer;
  final AbstractStopWordFilter _stopWordFilter;

  @override
  ProcessedQuery process(SearchQuery query) {
    final raw = query.keyword.trim();

    if (raw.isEmpty) {
      return const ProcessedQuery(
        rawKeyword: '',
        tokens: [],
        isPhraseSearch: false,
        isEmpty: true,
      );
    }

    // Detect phrase search: "exact phrase"
    final isPhraseSearch = raw.startsWith('"') && raw.endsWith('"') && raw.length > 2;
    final cleanedKeyword = isPhraseSearch ? raw.substring(1, raw.length - 1) : raw;

    // Tokenize
    final rawTokens = _tokenizer.tokenize(cleanedKeyword);

    // Normalize and filter stop words
    final processed = <String>[];
    for (final token in rawTokens) {
      final normalized = _normalizer.normalize(token.text);
      if (normalized.isEmpty) continue;
      // For phrase search, keep stop words to preserve phrase integrity
      if (!isPhraseSearch && !_stopWordFilter.shouldKeep(normalized)) continue;
      processed.add(normalized);
    }

    return ProcessedQuery(
      rawKeyword: cleanedKeyword,
      tokens: processed,
      isPhraseSearch: isPhraseSearch,
      isEmpty: processed.isEmpty,
    );
  }
}
