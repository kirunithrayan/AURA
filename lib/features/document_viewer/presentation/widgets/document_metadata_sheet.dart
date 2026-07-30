import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/document_viewer/presentation/viewmodels/document_viewer_viewmodel.dart';
import 'providers/metadata_provider.dart';

class DocumentMetadataSheet extends StatelessWidget {

  const DocumentMetadataSheet({
    super.key,
    required this.state,
    this.provider,
  });
  final DocumentViewerViewModelState state;
  final MetadataProvider? provider;

  String _formatSize(int? bytes) {
    if (bytes == null) return 'Unknown';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final file = state.file;
    if (file == null) return const SizedBox.shrink();

    final specificMetadata = provider?.getMetadata(state) ?? {};

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Document Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildRow('Filename', file.fileName),
            _buildRow('File Type', file.extension?.toUpperCase() ?? 'Unknown'),
            _buildRow('File Size', _formatSize(file.size)),
            _buildRow('Created', _formatDate(file.createdAt)),
            _buildRow('Modified', _formatDate(file.modifiedAt)),
            _buildRow('Imported', _formatDate(file.importedAt)),
            _buildRow('SHA-256', file.contentHash ?? 'Unknown'),
            
            if (specificMetadata.isNotEmpty) ...[
              const Divider(height: 32),
              const Text('Properties', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...specificMetadata.entries.map((e) => _buildRow(e.key, e.value)),
            ],
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
}
