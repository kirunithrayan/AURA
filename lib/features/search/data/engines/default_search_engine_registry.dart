import '../../domain/engines/abstract_search_engine_registry.dart';
import '../../domain/entities/search_engine_descriptor.dart';
import '../../domain/entities/search_engine_capability.dart';
import '../../domain/entities/search_engine_status.dart';

class DefaultSearchEngineRegistry implements AbstractSearchEngineRegistry {
  final Map<String, SearchEngineDescriptor> _engines = {};

  @override
  Future<void> registerEngine(SearchEngineDescriptor descriptor) async {
    _engines[descriptor.id] = descriptor;
  }

  @override
  Future<void> unregisterEngine(String engineId) async {
    _engines.remove(engineId);
  }

  @override
  Future<void> enableEngine(String engineId) async {
    if (_engines.containsKey(engineId)) {
      _engines[engineId] = _engines[engineId]!.copyWith(status: SearchEngineStatus.enabled);
    }
  }

  @override
  Future<void> disableEngine(String engineId) async {
    if (_engines.containsKey(engineId)) {
      _engines[engineId] = _engines[engineId]!.copyWith(status: SearchEngineStatus.disabled);
    }
  }

  @override
  List<SearchEngineDescriptor> getActiveEngines() => _engines.values.where((e) => e.status == SearchEngineStatus.enabled).toList();

  @override
  List<SearchEngineDescriptor> getEnginesByCapability(SearchEngineCapability capability) => _engines.values.where((e) => e.capabilities.contains(capability)).toList();

  @override
  SearchEngineDescriptor? getEngineById(String engineId) => _engines[engineId];
}
