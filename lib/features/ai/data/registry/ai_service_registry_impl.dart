import '../../domain/registry/abstract_ai_service_registry.dart';
import '../../domain/engines/abstract_embedding_engine.dart';
import '../../domain/engines/abstract_inference_engine.dart';
import '../../domain/services/abstract_chunking_service.dart';
import '../../domain/services/abstract_prompt_builder.dart';
import '../../domain/services/abstract_vector_store.dart';

/// Concrete implementation of the [AbstractAIServiceRegistry].
/// Manages dynamically registered AI services.
class AIServiceRegistryImpl implements AbstractAIServiceRegistry {
  final Map<String, AbstractEmbeddingEngine> _embeddingEngines = {};
  final Map<String, AbstractInferenceEngine> _inferenceEngines = {};
  final Map<String, AbstractChunkingService> _chunkingServices = {};
  final Map<String, AbstractPromptBuilder> _promptBuilders = {};
  final Map<String, AbstractVectorStore> _vectorStores = {};

  @override
  void registerEmbeddingEngine(String id, AbstractEmbeddingEngine engine) {
    _embeddingEngines[id] = engine;
  }

  @override
  void registerInferenceEngine(String id, AbstractInferenceEngine engine) {
    _inferenceEngines[id] = engine;
  }

  @override
  void registerChunkingService(String id, AbstractChunkingService service) {
    _chunkingServices[id] = service;
  }

  @override
  void registerPromptBuilder(String id, AbstractPromptBuilder builder) {
    _promptBuilders[id] = builder;
  }

  @override
  void registerVectorStore(String id, AbstractVectorStore store) {
    _vectorStores[id] = store;
  }

  @override
  AbstractEmbeddingEngine? getEmbeddingEngine(String id) => _embeddingEngines[id];

  @override
  AbstractInferenceEngine? getInferenceEngine(String id) => _inferenceEngines[id];

  @override
  AbstractChunkingService? getChunkingService(String id) => _chunkingServices[id];

  @override
  AbstractPromptBuilder? getPromptBuilder(String id) => _promptBuilders[id];

  @override
  AbstractVectorStore? getVectorStore(String id) => _vectorStores[id];

  @override
  void unregisterAll() {
    _embeddingEngines.clear();
    _inferenceEngines.clear();
    _chunkingServices.clear();
    _promptBuilders.clear();
    _vectorStores.clear();
  }
}
