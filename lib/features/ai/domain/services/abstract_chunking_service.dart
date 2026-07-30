import '../entities/document_chunk.dart';

/// Abstract interface for breaking large documents into semantic chunks.
abstract class AbstractChunkingService {
  /// Chunks an entire document based on its internal structure.
  Future<List<DocumentChunk>> chunkDocument(String documentId);

  /// Chunks a raw string of text into smaller overlapping segments.
  List<DocumentChunk> chunkText(String text);
}
