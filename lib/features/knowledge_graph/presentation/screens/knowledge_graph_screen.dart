import 'package:flutter/material.dart';

class KnowledgeGraphScreen extends StatelessWidget {
  final String workspaceId;

  const KnowledgeGraphScreen({super.key, required this.workspaceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Knowledge Graph')),
      body: Center(
        child: Text('Knowledge Graph for Workspace: $workspaceId'),
      ),
    );
  }
}
