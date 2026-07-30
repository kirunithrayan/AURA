import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

class PdfBottomControls extends StatelessWidget {

  const PdfBottomControls({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onJumpToPage,
    required this.onZoomIn,
    required this.onZoomOut,
  });
  final int currentPage;
  final int pageCount;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final VoidCallback onJumpToPage;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: onZoomOut,
                  tooltip: 'Zoom Out',
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onZoomIn,
                  tooltip: 'Zoom In',
                ),
              ],
            ),
            InkWell(
              onTap: onJumpToPage,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '$currentPage / $pageCount',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: currentPage > 1 ? onPreviousPage : null,
                  tooltip: 'Previous Page',
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: currentPage < pageCount ? onNextPage : null,
                  tooltip: 'Next Page',
                ),
              ],
            ),
          ],
        ),
      ),
    );
}
