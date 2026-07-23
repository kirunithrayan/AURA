import 'package:flutter/material.dart';

class AiInsightsScreen extends StatelessWidget {
  final String documentId;

  const AiInsightsScreen({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Insights')),
      body: Center(
        child: Text('AI Insights for Document: $documentId'),
      ),
    );
  }
}
