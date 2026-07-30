import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/riverpod_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/file_icon_widget.dart';
import '../../domain/entities/document_metadata.dart';
import '../../../../core/router/app_routes.dart';

class RecentDocumentsSection extends ConsumerStatefulWidget {
  const RecentDocumentsSection({super.key});

  @override
  ConsumerState<RecentDocumentsSection> createState() => _RecentDocumentsSectionState();
}

class _RecentDocumentsSectionState extends ConsumerState<RecentDocumentsSection> {
  List<DocumentMetadata> _recentDocs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentDocuments();
  }

  Future<void> _loadRecentDocuments() async {
    setState(() => _isLoading = true);
    final service = ref.read(recentDocumentsServiceProvider);
    final result = await service.getRecentDocuments(limit: 5);
    
    result.fold(
      (failure) {
        setState(() => _isLoading = false);
      },
      (docs) {
        setState(() {
          _recentDocs = docs;
          _isLoading = false;
        });
      },
    );
  }
  
  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentDocs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No recent documents', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Semantics(
            header: true,
            child: const Text(
              'Recent Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: _recentDocs.length,
            itemBuilder: (context, index) {
              final doc = _recentDocs[index];
              return _buildRecentCard(context, doc);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCard(BuildContext context, DocumentMetadata doc) => Semantics(
      label: 'Recent document: ${doc.fileName}. Last opened: ${_formatDate(doc.lastOpenedAt)}',
      button: true,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.documentViewer, arguments: doc.id);
        },
        child: Container(
          width: 120,
          margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: FileIconWidget(
                        extension: doc.fileExtension ?? '',
                        size: 32,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      doc.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(doc.lastOpenedAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (doc.isFavorite)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: ExcludeSemantics(child: Icon(Icons.star, color: Colors.amber, size: 16)),
                ),
              if (doc.isPinned && !doc.isFavorite)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: ExcludeSemantics(child: Icon(Icons.push_pin, color: AppColors.primary, size: 16)),
                ),
            ],
          ),
        ),
      ),
    );
}
