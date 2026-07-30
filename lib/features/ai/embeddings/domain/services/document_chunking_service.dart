import '../entities/document_chunk.dart';
import 'package:uuid/uuid.dart';

/// Configuration for chunking.
class ChunkingConfig {

  const ChunkingConfig({
    this.chunkSize = 1000,
    this.chunkOverlap = 200,
  });
  final int chunkSize;
  final int chunkOverlap;
}

/// Service to split text into chunks suitable for embedding.
class DocumentChunkingService {

  const DocumentChunkingService();
  final _uuid = const Uuid();

  /// Splits extracted document text into chunks.
  /// Tries to split on paragraphs first, then sentences, then words.
  List<DocumentChunk> chunkText(String documentId, String text, {ChunkingConfig config = const ChunkingConfig()}) {
    if (text.isEmpty) return [];

    final List<DocumentChunk> chunks = [];
    int chunkIndex = 0;

    // Splitting strategy:
    // First, split by paragraphs (double newlines).
    // If a paragraph is too large, split by sentences.
    // If a sentence is too large, split by words.
    
    final List<String> rawChunks = _splitIntoOverlappingChunks(text, config);

    for (final chunkText in rawChunks) {
      if (chunkText.trim().isEmpty) continue;

      chunks.add(DocumentChunk(
        id: _uuid.v4(),
        documentId: documentId,
        chunkIndex: chunkIndex,
        content: chunkText.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      
      chunkIndex++;
    }

    return chunks;
  }

  List<String> _splitIntoOverlappingChunks(String text, ChunkingConfig config) {
    final List<String> chunks = [];
    int start = 0;
    
    while (start < text.length) {
      final int end = start + config.chunkSize;
      
      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }

      // Try to find a good breaking point (newline or period) near the end
      final int breakPoint = _findBreakPoint(text, start, end);
      
      chunks.add(text.substring(start, breakPoint));
      
      // Advance start pointer, subtracting overlap
      start = breakPoint - config.chunkOverlap;
      
      // Prevent infinite loop if overlap is too large or breakpoint logic fails
      if (start <= 0 || breakPoint == start + config.chunkOverlap) {
        start = breakPoint; 
      }
    }
    
    return chunks;
  }

  int _findBreakPoint(String text, int start, int end) {
    // Try to find a paragraph break
    int breakPoint = text.lastIndexOf('\n\n', end);
    if (breakPoint > start + (end - start) / 2) return breakPoint + 2;

    // Try to find a sentence break
    breakPoint = text.lastIndexOf('. ', end);
    if (breakPoint > start + (end - start) / 2) return breakPoint + 2;
    
    breakPoint = text.lastIndexOf('? ', end);
    if (breakPoint > start + (end - start) / 2) return breakPoint + 2;
    
    breakPoint = text.lastIndexOf('! ', end);
    if (breakPoint > start + (end - start) / 2) return breakPoint + 2;

    // Try to find a word break
    breakPoint = text.lastIndexOf(' ', end);
    if (breakPoint > start + (end - start) / 2) return breakPoint + 1;

    // Fallback: hard break
    return end;
  }
}
