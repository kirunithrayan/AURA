import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';

import '../../domain/engines/abstract_embedding_engine.dart';
import '../../domain/engines/abstract_inference_engine.dart';
import '../../domain/services/abstract_chunking_service.dart';
import '../../domain/services/abstract_prompt_builder.dart';
import '../../domain/services/abstract_vector_store.dart';
import '../../domain/registry/abstract_ai_service_registry.dart';

/// Provides the central registry for managing AI capabilities.
final aiServiceRegistryProvider = Provider<AbstractAIServiceRegistry>((ref) => sl<AbstractAIServiceRegistry>());

/// Provides the underlying Embedding Engine instance from GetIt.
final embeddingEngineProvider = Provider<AbstractEmbeddingEngine>((ref) => sl<AbstractEmbeddingEngine>());

/// Provides the underlying Inference Engine instance from GetIt.
final inferenceEngineProvider = Provider<AbstractInferenceEngine>((ref) => sl<AbstractInferenceEngine>());

/// Provides the Chunking Service instance from GetIt.
final chunkingServiceProvider = Provider<AbstractChunkingService>((ref) => sl<AbstractChunkingService>());

/// Provides the Prompt Builder instance from GetIt.
final promptBuilderProvider = Provider<AbstractPromptBuilder>((ref) => sl<AbstractPromptBuilder>());

/// Provides the Vector Store instance from GetIt.
final vectorStoreProvider = Provider<AbstractVectorStore>((ref) => sl<AbstractVectorStore>());
