import '../../domain/engines/abstract_search_engine.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../indexing/cache/search_index_cache.dart';
import '../indexing/repositories/search_index_repository.dart';
import 'query/query_processor.dart';
import 'matching/matching_strategy.dart';
import 'snippet/search_snippet_generator.dart';
import '../../../../core/text_engine/abstract_text_document_engine.dart';
import '../../../workspace/domain/entities/workspace_file.dart';
import '../../domain/repositories/search_logger.dart';
import '../../domain/entities/search_log_context.dart';

/// Production keyword search engine operating on the persisted Search Index.
///
/// Pipeline:
///   1. Process the query (tokenize, normalize, filter stop words)
///   2. Fetch candidate document metadata from repository
///   3. For each candidate, retrieve its search index
///   4. Run the matching strategy against the index entries
///   5. Generate snippets for matched documents
///   6. Return unranked candidate SearchResults
class KeywordSearchEngine implements AbstractSearchEngine {

  KeywordSearchEngine(
    this._repository,
    this._indexRepository,
    this._indexCache,
    this._queryProcessor,
    this._matchingStrategy,
    this._snippetGenerator,
    this._textEngine,
    this._logger,
  );
  final SearchRepository _repository;
  final SearchIndexRepository _indexRepository;
  final SearchIndexCache _indexCache;
  final AbstractQueryProcessor _queryProcessor;
  final AbstractMatchingStrategy _matchingStrategy;
  final SearchSnippetGenerator _snippetGenerator;
  final AbstractTextDocumentEngine _textEngine;
  final SearchLogger _logger;

  @override
  String get engineType => 'keyword';

  @override
  Future<List<SearchResult>> search(SearchQuery query) async {
    // 1. Process query
    final processed = _queryProcessor.process(query);

    // 2. Fetch candidate metadata
    final candidates = await _repository.getCandidateMetadata(query);

    if (candidates.isEmpty) return [];

    // Handle empty keyword: return all candidates with default scores
    if (processed.isEmpty) {
      return candidates
          .map((m) => SearchResult(
                metadata: m,
                score: 1.0,
                searchEngineType: engineType,
              ))
          .toList();
    }

    // 3. Match against search index for each candidate
    final results = <SearchResult>[];

    for (final metadata in candidates) {
      try {
        // Retrieve index (cache -> repository)
        var index = _indexCache.get(metadata.id);
        index ??= await _indexRepository.getIndex(metadata.id);

        if (index == null) {
          // No index exists — skip this document gracefully
          continue;
        }

        // Cache for next lookup
        _indexCache.put(metadata.id, index);

        // 4. Run matching strategy
        final matchResult = _matchingStrategy.match(
          processed,
          index.entries,
          metadata.id,
          metadata.fileName,
        );

        if (matchResult == null) continue;

        // 5. Generate snippet
        String? snippet;
        List<String> highlights = matchResult.matchedTokens;

        if (matchResult.matchPositions.isNotEmpty) {
          // Try to get raw content for snippet generation
          try {
            final file = WorkspaceFile(
              id: metadata.id,
              workspaceId: metadata.workspaceId,
              fileName: metadata.fileName,
              filePath: metadata.filePath,
              extension: metadata.fileExtension,
              createdAt: metadata.createdAt,
              modifiedAt: metadata.modifiedAt,
              importedAt: metadata.importedAt,
            );
            final textDoc = await _textEngine.openDocument(file);
            final snippetResult = _snippetGenerator.generate(
              content: textDoc.content,
              matchedTokens: matchResult.matchedTokens,
              matchPositions: matchResult.matchPositions,
            );
            snippet = snippetResult.snippet;
            highlights = snippetResult.highlights;
          } catch (e) {
            _logger.logWithContext(
              SearchLogContext(
                operation: 'GenerateSnippet',
                success: false,
                workspaceId: metadata.workspaceId,
                searchEngine: engineType,
              ),
              errorMessage: e.toString(),
              extraData: {'fileId': metadata.id},
            );
          }
        }

        results.add(SearchResult(
          metadata: metadata,
          score: matchResult.score,
          snippet: snippet,
          highlights: highlights,
          matchPositions: matchResult.matchPositions,
          matchReason: matchResult.matchReason,
          searchEngineType: engineType,
        ));
      } catch (e) {
        _logger.logWithContext(
          SearchLogContext(
            operation: 'KeywordSearchCandidate',
            success: false,
            workspaceId: metadata.workspaceId,
            searchEngine: engineType,
          ),
          errorMessage: e.toString(),
          extraData: {'fileId': metadata.id},
        );
        continue;
      }
    }

    return results;
  }
}
