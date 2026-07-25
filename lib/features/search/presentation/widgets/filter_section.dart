import 'package:flutter/material.dart';
import '../../domain/entities/search_filter.dart';

class FilterSection extends StatelessWidget {
  final SearchFilter currentFilter;
  final ValueChanged<SearchFilter> onFilterChanged;

  const FilterSection({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: 'Favorites',
            selected: currentFilter.favoritesOnly ?? false,
            onSelected: (val) {
              onFilterChanged(currentFilter.copyWith(favoritesOnly: val));
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Pinned',
            selected: currentFilter.pinnedOnly ?? false,
            onSelected: (val) {
              onFilterChanged(currentFilter.copyWith(pinnedOnly: val));
            },
          ),
          const SizedBox(width: 8),
          // Example of File Types filter
          _buildFilterChip(
            context,
            label: 'PDFs',
            selected: currentFilter.fileTypes.contains('pdf'),
            onSelected: (val) {
              final types = Set<String>.from(currentFilter.fileTypes);
              if (val) types.add('pdf');
              else types.remove('pdf');
              onFilterChanged(currentFilter.copyWith(fileTypes: types.toList()));
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Documents',
            selected: currentFilter.fileTypes.contains('docx'),
            onSelected: (val) {
              final types = Set<String>.from(currentFilter.fileTypes);
              if (val) types.add('docx');
              else types.remove('docx');
              onFilterChanged(currentFilter.copyWith(fileTypes: types.toList()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, {required String label, required bool selected, required ValueChanged<bool> onSelected}) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}
