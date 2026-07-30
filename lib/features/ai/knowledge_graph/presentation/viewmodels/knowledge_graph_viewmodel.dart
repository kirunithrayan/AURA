import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/di/injection_container.dart';
import '../../domain/entities/knowledge_edge.dart';
import '../../domain/entities/knowledge_node.dart';
import '../../domain/repositories/knowledge_graph_repository.dart';

/// State for the Knowledge Graph UI.
class KnowledgeGraphState extends Equatable {

  const KnowledgeGraphState({
    this.isLoading = false,
    this.nodes = const [],
    this.edges = const [],
    this.error,
    this.selectedNode,
  });
  final bool isLoading;
  final List<KnowledgeNode> nodes;
  final List<KnowledgeEdge> edges;
  final String? error;
  final KnowledgeNode? selectedNode;

  KnowledgeGraphState copyWith({
    bool? isLoading,
    List<KnowledgeNode>? nodes,
    List<KnowledgeEdge>? edges,
    String? error,
    KnowledgeNode? selectedNode,
  }) => KnowledgeGraphState(
      isLoading: isLoading ?? this.isLoading,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      error: error ?? this.error,
      selectedNode: selectedNode, // Can be null to clear selection
    );

  @override
  List<Object?> get props => [isLoading, nodes, edges, error, selectedNode];
}

class KnowledgeGraphViewModel extends StateNotifier<KnowledgeGraphState> {

  KnowledgeGraphViewModel(this._repository, this._workspaceId)
      : super(const KnowledgeGraphState()) {
    _loadGraph();
  }
  final KnowledgeGraphRepository _repository;
  final String _workspaceId;

  Future<void> _loadGraph() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final nodes = await _repository.getNodesForWorkspace(_workspaceId);
      final edges = await _repository.getEdgesForWorkspace(_workspaceId);
      state = state.copyWith(
        isLoading: false,
        nodes: nodes,
        edges: edges,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectNode(KnowledgeNode? node) {
    state = state.copyWith(selectedNode: node);
  }
}

final knowledgeGraphViewModelProvider = StateNotifierProvider.family<KnowledgeGraphViewModel, KnowledgeGraphState, String>((ref, workspaceId) {
  final repository = sl<KnowledgeGraphRepository>();
  return KnowledgeGraphViewModel(repository, workspaceId);
});
