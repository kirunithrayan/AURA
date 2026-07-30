import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aura/core/di/injection_container.dart';
import '../../domain/services/text_preprocessor.dart';
import '../../domain/services/document_chunking_service.dart';
import '../../domain/services/embedding_service.dart';
import '../../domain/repositories/embedding_repository.dart';
import '../../domain/services/cosine_similarity_service.dart';
import '../../domain/services/document_indexing_service.dart';

// Riverpod providers for the embedding pipeline

/// Provider for the [TextPreprocessor]
final textPreprocessorProvider = Provider<TextPreprocessor>((ref) => sl<TextPreprocessor>());

/// Provider for the [DocumentChunkingService]
final documentChunkingServiceProvider = Provider<DocumentChunkingService>((ref) => sl<DocumentChunkingService>());

/// Provider for the [EmbeddingService] (ONNX implementation)
final embeddingServiceProvider = Provider<EmbeddingService>((ref) => sl<EmbeddingService>());

/// Provider for the [EmbeddingRepository] (SQLite implementation)
final embeddingRepositoryProvider = Provider<EmbeddingRepository>((ref) => sl<EmbeddingRepository>());

/// Provider for the [CosineSimilarityService]
final cosineSimilarityServiceProvider = Provider<CosineSimilarityService>((ref) => sl<CosineSimilarityService>());

/// Provider for the [DocumentIndexingService]
final documentIndexingServiceProvider = Provider<DocumentIndexingService>((ref) => sl<DocumentIndexingService>());
