
import '../entities/document_chunk.dart';
import '../entities/indexed_document_chunk.dart';
import 'text_preprocessor.dart';
import 'document_chunking_service.dart';
import 'embedding_service.dart';
import '../repositories/embedding_repository.dart';

/// Service responsible for the complete document indexing pipeline.
/// 
/// Pipeline:
/// 1. Preprocess
/// 2. Chunk
/// 3. Generate Embeddings (batch)
/// 4. Store Embeddings
class DocumentIndexingService {

  DocumentIndexingService({
    required TextPreprocessor preprocessor,
    required DocumentChunkingService chunkingService,
    required EmbeddingService embeddingService,
    required EmbeddingRepository repository,
  })  : _preprocessor = preprocessor,
        _chunkingService = chunkingService,
        _embeddingService = embeddingService,
        _repository = repository;
  final TextPreprocessor _preprocessor;
  final DocumentChunkingService _chunkingService;
  final EmbeddingService _embeddingService;
  final EmbeddingRepository _repository;

  /// Indexes a document's extracted text.
  /// 
  /// [onProgress] can be provided to receive progress updates (0.0 to 1.0).
  /// [isCancelled] can be provided to support cancellation from the UI.
  Future<void> indexDocument({
    required String documentId,
    required String extractedText,
    void Function(double)? onProgress,
    bool Function()? isCancelled,
  }) async {
    if (extractedText.isEmpty) {
      onProgress?.call(1.0);
      return;
    }

    if (isCancelled != null && isCancelled()) return;
    onProgress?.call(0.1);

    // 1. Preprocess
    final String cleanText = _preprocessor.preprocess(extractedText);
    
    if (isCancelled != null && isCancelled()) return;
    onProgress?.call(0.2);

    // 2. Chunk
    final List<DocumentChunk> chunks = _chunkingService.chunkText(documentId, cleanText);
    if (chunks.isEmpty) {
      onProgress?.call(1.0);
      return;
    }

    if (isCancelled != null && isCancelled()) return;
    onProgress?.call(0.3);

    // Ensure embedding service is ready
    await _embeddingService.initialize();

    // 3. Generate Embeddings (Batching)
    // To avoid memory overflow, process in batches.
    const int batchSize = 10;
    final List<IndexedDocumentChunk> embeddings = [];
    
    final int totalBatches = (chunks.length / batchSize).ceil();
    
    for (int i = 0; i < chunks.length; i += batchSize) {
      if (isCancelled != null && isCancelled()) return;

      final end = (i + batchSize < chunks.length) ? i + batchSize : chunks.length;
      final batchChunks = chunks.sublist(i, end);
      
      final List<String> textsToEmbed = batchChunks.map((c) => c.content).toList();
      final List<List<double>> vectors = await _embeddingService.generateEmbeddingsBatch(textsToEmbed);
      
      for (int j = 0; j < batchChunks.length; j++) {
        embeddings.add(IndexedDocumentChunk(
          chunkId: batchChunks[j].id,
          documentId: documentId,
          chunkIndex: batchChunks[j].chunkIndex,
          textSnippet: batchChunks[j].content,
          embedding: vectors[j],
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
      }
      
      final currentBatch = (i / batchSize).floor() + 1;
      // Progress from 0.3 to 0.8 during embedding generation
      final progress = 0.3 + (0.5 * (currentBatch / totalBatches));
      onProgress?.call(progress);
    }

    if (isCancelled != null && isCancelled()) return;
    onProgress?.call(0.9);

    // 4. Store Embeddings
    // Clear existing embeddings for this document first to avoid duplicates
    await _repository.deleteDocumentEmbeddings(documentId);
    
    // Save new ones
    await _repository.saveEmbeddings(embeddings);

    onProgress?.call(1.0);
  }
}
