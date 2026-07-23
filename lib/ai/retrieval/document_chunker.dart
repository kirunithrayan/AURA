import '../../core/constants/app_constants.dart';
import '../models/document_chunk.dart';

/// Handles splitting documents into smaller semantic chunks for embedding.
class DocumentChunker {
  final int maxTokens;
  final int overlap;

  DocumentChunker({
    this.maxTokens = AppConstants.maxChunkSize,
    this.overlap = AppConstants.chunkOverlap,
  });

  /// Chunks a raw string of text. 
  /// Uses a simplistic character/word based heuristic for Phase 1.
  /// Real implementation would use a proper tokenizer matching the ONNX model.
  List<DocumentChunk> chunkText(String fileId, String text) {
    if (text.isEmpty) return [];

    // Simplistic word-based chunking
    final words = text.split(RegExp(r'\s+'));
    final List<DocumentChunk> chunks = [];
    
    // Approximate: 1 token ~= 1.5 words
    final int wordsPerChunk = (maxTokens * 1.5).floor();
    final int wordsOverlap = (overlap * 1.5).floor();
    
    int index = 0;
    int chunkIdx = 0;

    while (index < words.length) {
      int end = index + wordsPerChunk;
      if (end > words.length) end = words.length;

      final chunkWords = words.sublist(index, end);
      chunks.add(DocumentChunk(
        fileId: fileId,
        chunkIndex: chunkIdx++,
        text: chunkWords.join(' '),
      ));

      if (end == words.length) break;
      index = end - wordsOverlap; // Step back for overlap
    }

    return chunks;
  }
}
