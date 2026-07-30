import 'package:freezed_annotation/freezed_annotation.dart';

part 'vector_search_result.freezed.dart';
part 'vector_search_result.g.dart';

/// Strongly typed immutable domain entity representing a semantic search result.
@freezed
class VectorSearchResult with _$VectorSearchResult {
  const factory VectorSearchResult({
    required String vectorId,
    required double similarityScore,
    required String documentId,
    required String workspaceId,
    required String chunkId,
    int? pageNumber,
    @Default({}) Map<String, dynamic> metadata,
  }) = _VectorSearchResult;

  factory VectorSearchResult.fromJson(Map<String, dynamic> json) => _$VectorSearchResultFromJson(json);
}
