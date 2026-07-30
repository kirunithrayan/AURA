import 'package:equatable/equatable.dart';

class ContextChunk extends Equatable {

  const ContextChunk({
    required this.documentId,
    required this.workspaceId,
    required this.fileName,
    required this.chunkIndex,
    required this.textSnippet,
    required this.similarityScore,
  });
  final String documentId;
  final String workspaceId;
  final String fileName;
  final int chunkIndex;
  final String textSnippet;
  final double similarityScore;

  @override
  List<Object?> get props => [
        documentId,
        workspaceId,
        fileName,
        chunkIndex,
        textSnippet,
        similarityScore,
      ];
}
