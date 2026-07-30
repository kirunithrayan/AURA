import '../engines/abstract_embedding_engine.dart';
import '../engines/abstract_inference_engine.dart';
import '../services/abstract_chunking_service.dart';
import '../services/abstract_prompt_builder.dart';
import '../services/abstract_vector_store.dart';

/// Registry for managing active AI implementations.
/// Allows dynamic registration of multiple embeddings, chunking strategies,
/// and inference models to support dynamic AI capabilities at runtime.
abstract class AbstractAIServiceRegistry {
  void registerEmbeddingEngine(String id, AbstractEmbeddingEngine engine);
  void registerInferenceEngine(String id, AbstractInferenceEngine engine);
  void registerChunkingService(String id, AbstractChunkingService service);
  void registerPromptBuilder(String id, AbstractPromptBuilder builder);
  void registerVectorStore(String id, AbstractVectorStore store);

  AbstractEmbeddingEngine? getEmbeddingEngine(String id);
  AbstractInferenceEngine? getInferenceEngine(String id);
  AbstractChunkingService? getChunkingService(String id);
  AbstractPromptBuilder? getPromptBuilder(String id);
  AbstractVectorStore? getVectorStore(String id);
  
  void unregisterAll();
}
