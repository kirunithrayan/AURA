import 'package:equatable/equatable.dart';

/// Entity representing a text chunk extracted from a document.
class DocumentChunk extends Equatable {

  const DocumentChunk({
    required this.id,
    required this.documentId,
    required this.chunkIndex,
    required this.content,
    required this.createdAt,
  });
  final String id;
  final String documentId;
  final int chunkIndex;
  final String content;
  final int createdAt;

  @override
  List<Object?> get props => [id, documentId, chunkIndex, content, createdAt];
}
