import 'package:equatable/equatable.dart';

/// Entity representing a text chunk with its semantic embedding.
/// This prevents overloading DocumentEmbedding with metadata while keeping semantic logic clean.
class IndexedDocumentChunk extends Equatable {

  const IndexedDocumentChunk({
    required this.chunkId,
    required this.documentId,
    required this.chunkIndex,
    required this.textSnippet,
    required this.embedding,
    required this.createdAt,
  });
  final String chunkId;
  final String documentId;
  final int chunkIndex;
  final String textSnippet;
  final List<double> embedding;
  final int createdAt;

  @override
  List<Object?> get props => [
        chunkId,
        documentId,
        chunkIndex,
        textSnippet,
        embedding,
        createdAt,
      ];
}
