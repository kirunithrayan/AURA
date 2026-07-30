import 'package:flutter/material.dart';

class AiInsightsScreen extends StatelessWidget {

  const AiInsightsScreen({super.key, required this.documentId});
  final String documentId;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('AI Insights')),
      body: Center(
        child: Text('AI Insights for Document: $documentId'),
      ),
    );
}
