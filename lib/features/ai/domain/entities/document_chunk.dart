import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_chunk.freezed.dart';
part 'document_chunk.g.dart';

/// Strongly typed immutable domain entity representing a document chunk.
@freezed
class DocumentChunk with _$DocumentChunk {
  const factory DocumentChunk({
    required String id,
    required String documentId,
    required String workspaceId,
    required String text,
    required int chunkIndex,
    int? pageNumber,
    int? startOffset,
    int? endOffset,
    @Default({}) Map<String, dynamic> metadata,
  }) = _DocumentChunk;

  factory DocumentChunk.fromJson(Map<String, dynamic> json) => _$DocumentChunkFromJson(json);
}
