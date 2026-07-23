import 'package:flutter/material.dart';
import '../../../../core/widgets/aura_bottom_sheet.dart';

enum FileSortOption { name, dateCreated, dateModified, size }

class FileSortSheet extends StatelessWidget {
  final FileSortOption currentSort;
  final Function(FileSortOption) onSortChanged;

  const FileSortSheet({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  static Future<FileSortOption?> show(
    BuildContext context, 
    FileSortOption currentSort,
  ) {
    return AuraBottomSheet.show<FileSortOption>(
      context: context,
      builder: (ctx) => FileSortSheet(
        currentSort: currentSort,
        onSortChanged: (sort) => Navigator.pop(ctx, sort),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Sort by',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        _buildListTile(context, 'Name (A-Z)', FileSortOption.name, Icons.sort_by_alpha),
        _buildListTile(context, 'Date Added', FileSortOption.dateCreated, Icons.calendar_today),
        _buildListTile(context, 'Last Modified', FileSortOption.dateModified, Icons.edit_calendar),
        _buildListTile(context, 'Size', FileSortOption.size, Icons.format_size),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, String title, FileSortOption option, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: currentSort == option ? const Icon(Icons.check, color: Colors.blue) : null,
      onTap: () => onSortChanged(option),
    );
  }
}
