import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';

import '../../domain/entities/knowledge_node.dart';
import '../../domain/entities/node_type.dart';
import '../viewmodels/knowledge_graph_viewmodel.dart';

class KnowledgeGraphScreen extends ConsumerStatefulWidget {

  const KnowledgeGraphScreen({super.key, required this.workspaceId});
  final String workspaceId;

  @override
  ConsumerState<KnowledgeGraphScreen> createState() => _KnowledgeGraphScreenState();
}

class _KnowledgeGraphScreenState extends ConsumerState<KnowledgeGraphScreen> {
  final Graph graph = Graph()..isTree = false;
  late FruchtermanReingoldAlgorithm algorithm;
  final Map<String, Node> _nodeMap = {};
  
  @override
  void initState() {
    super.initState();
    algorithm = FruchtermanReingoldAlgorithm(FruchtermanReingoldConfiguration());
  }

  void _buildGraph(KnowledgeGraphState state) {
    graph.nodes.clear();
    graph.edges.clear();
    _nodeMap.clear();

    // Add nodes
    for (var kNode in state.nodes) {
      final node = Node.Id(kNode.id);
      _nodeMap[kNode.id] = node;
      graph.addNode(node);
    }

    // Add edges
    for (var kEdge in state.edges) {
      final source = _nodeMap[kEdge.sourceId];
      final target = _nodeMap[kEdge.targetId];
      if (source != null && target != null) {
        final paint = Paint()
          ..color = Colors.grey.withValues(alpha: 0.5)
          ..strokeWidth = max(1.0, kEdge.weight * 3);
        graph.addEdge(source, target, paint: paint);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(knowledgeGraphViewModelProvider(widget.workspaceId));
    final viewModel = ref.read(knowledgeGraphViewModelProvider(widget.workspaceId).notifier);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(child: Text('Error: ${state.error}')),
      );
    }

    // Rebuild graph if we have nodes
    _buildGraph(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Graph'),
      ),
      body: Row(
        children: [
          // Graph View
          Expanded(
            flex: 3,
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.1,
              maxScale: 5.0,
              child: GraphView(
                graph: graph,
                algorithm: algorithm,
                paint: Paint()
                  ..color = Colors.green
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  // Find the corresponding KnowledgeNode
                  final kNodeId = node.key!.value as String;
                  final kNode = state.nodes.firstWhere((n) => n.id == kNodeId);
                  
                  final isSelected = state.selectedNode?.id == kNode.id;
                  
                  return GestureDetector(
                    onTap: () {
                      viewModel.selectNode(kNode);
                    },
                    child: _buildNodeWidget(kNode, isSelected),
                  );
                },
              ),
            ),
          ),
          
          // Side Panel for Details
          if (state.selectedNode != null)
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.selectedNode!.label,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text('Type: ${state.selectedNode!.type.name}'),
                    const SizedBox(height: 8),
                    Text('Confidence: ${state.selectedNode!.confidence.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    Text('Frequency: ${state.selectedNode!.frequency}'),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.selectNode(null); // Clear selection
                      },
                      child: const Text('Close'),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNodeWidget(KnowledgeNode node, bool isSelected) {
    final Color nodeColor = node.type == NodeType.document ? Colors.blue : Colors.orange;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: nodeColor.withValues(alpha: isSelected ? 1.0 : 0.8),
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        node.label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
