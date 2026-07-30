import '../../domain/services/abstract_chunking_service.dart';
import '../../domain/entities/document_chunk.dart';

/// Stub implementation of [AbstractChunkingService] for DI registration.
class StubChunkingService implements AbstractChunkingService {
  const StubChunkingService();

  @override
  Future<List<DocumentChunk>> chunkDocument(String documentId) {
    throw UnimplementedError('Document chunking will be implemented in Phase 6.3');
  }

  @override
  List<DocumentChunk> chunkText(String text) {
    throw UnimplementedError('Text chunking will be implemented in Phase 6.3');
  }
}
