import 'package:equatable/equatable.dart';
import '../engines/abstract_search_engine.dart';
import 'search_engine_capability.dart';
import 'search_engine_status.dart';

class SearchEngineDescriptor extends Equatable {

  const SearchEngineDescriptor({
    required this.id,
    required this.name,
    required this.capabilities,
    this.status = SearchEngineStatus.enabled,
    required this.engine,
  });
  final String id;
  final String name;
  final Set<SearchEngineCapability> capabilities;
  final SearchEngineStatus status;
  final AbstractSearchEngine engine;

  SearchEngineDescriptor copyWith({
    String? id,
    String? name,
    Set<SearchEngineCapability>? capabilities,
    SearchEngineStatus? status,
    AbstractSearchEngine? engine,
  }) => SearchEngineDescriptor(
      id: id ?? this.id,
      name: name ?? this.name,
      capabilities: capabilities ?? this.capabilities,
      status: status ?? this.status,
      engine: engine ?? this.engine,
    );

  @override
  List<Object?> get props => [id, name, capabilities, status, engine];
}
