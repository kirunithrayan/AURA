import 'package:equatable/equatable.dart';

/// Entity representing a semantic embedding for a specific document chunk.
class DocumentEmbedding extends Equatable {

  const DocumentEmbedding({
    required this.id,
    required this.documentId,
    required this.chunkId,
    required this.vector,
    required this.createdAt,
  });
  final String id;
  final String documentId;
  final String chunkId;
  final List<double> vector;
  final int createdAt;

  @override
  List<Object?> get props => [id, documentId, chunkId, vector, createdAt];
}
