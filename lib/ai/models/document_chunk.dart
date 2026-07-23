import 'package:equatable/equatable.dart';

/// Represents a physical chunk of text from a document.
class DocumentChunk extends Equatable {
  final String fileId;
  final int chunkIndex;
  final String text;
  final List<double>? embedding;

  const DocumentChunk({
    required this.fileId,
    required this.chunkIndex,
    required this.text,
    this.embedding,
  });

  @override
  List<Object?> get props => [fileId, chunkIndex, text, embedding];

  DocumentChunk copyWith({
    String? fileId,
    int? chunkIndex,
    String? text,
    List<double>? embedding,
  }) {
    return DocumentChunk(
      fileId: fileId ?? this.fileId,
      chunkIndex: chunkIndex ?? this.chunkIndex,
      text: text ?? this.text,
      embedding: embedding ?? this.embedding,
    );
  }
}
