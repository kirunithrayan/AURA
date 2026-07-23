import 'package:flutter/material.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String documentId;

  const DocumentViewerScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Viewing Document: $documentId')),
      body: const Center(
        child: Text('Document Viewer Placeholder'),
      ),
    );
  }
}
