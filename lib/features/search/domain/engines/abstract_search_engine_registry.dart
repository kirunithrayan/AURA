import '../entities/search_engine_descriptor.dart';
import '../entities/search_engine_capability.dart';

abstract class AbstractSearchEngineRegistry {
  Future<void> registerEngine(SearchEngineDescriptor descriptor);
  Future<void> unregisterEngine(String engineId);
  Future<void> enableEngine(String engineId);
  Future<void> disableEngine(String engineId);
  
  List<SearchEngineDescriptor> getActiveEngines();
  List<SearchEngineDescriptor> getEnginesByCapability(SearchEngineCapability capability);
  SearchEngineDescriptor? getEngineById(String engineId);
}
