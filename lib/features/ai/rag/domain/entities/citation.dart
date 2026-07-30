import 'package:equatable/equatable.dart';

class Citation extends Equatable {

  const Citation({
    required this.index,
    required this.documentId,
    required this.workspaceId,
    required this.fileName,
    required this.snippet,
    this.pageNumber,
    required this.chunkIndex,
    required this.similarityScore,
  });
  final int index;
  final String documentId;
  final String workspaceId;
  final String fileName;
  final String snippet;
  final int? pageNumber;
  final int chunkIndex;
  final double similarityScore;

  @override
  List<Object?> get props => [
        index,
        documentId,
        workspaceId,
        fileName,
        snippet,
        pageNumber,
        chunkIndex,
        similarityScore,
      ];
}
