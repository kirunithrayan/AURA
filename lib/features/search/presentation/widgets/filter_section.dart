import 'package:flutter/material.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/entities/search_mode.dart';

class FilterSection extends StatelessWidget {

  const FilterSection({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });
  final SearchFilter currentFilter;
  final ValueChanged<SearchFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildSearchModeToggle(context),
          const SizedBox(width: 16),
          const VerticalDivider(width: 1),
          const SizedBox(width: 16),
          _buildFilterChip(
            context,
            label: 'Favorites',
            selected: currentFilter.favoritesOnly,
            onSelected: (val) {
              onFilterChanged(currentFilter.copyWith(favoritesOnly: val));
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Pinned',
            selected: currentFilter.pinnedOnly,
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
              if (val) {
                types.add('pdf');
              } else {
                types.remove('pdf');
              }
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
              if (val) {
                types.add('docx');
              } else {
                types.remove('docx');
              }
              onFilterChanged(currentFilter.copyWith(fileTypes: types.toList()));
            },
          ),
        ],
      ),
    );

  Widget _buildFilterChip(BuildContext context, {required String label, required bool selected, required ValueChanged<bool> onSelected}) => FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );

  Widget _buildSearchModeToggle(BuildContext context) => SegmentedButton<SearchMode>(
      segments: const [
        ButtonSegment(
          value: SearchMode.hybrid,
          label: Text('Hybrid AI'),
          icon: Icon(Icons.auto_awesome),
        ),
        ButtonSegment(
          value: SearchMode.keyword,
          label: Text('Keyword'),
          icon: Icon(Icons.text_fields),
        ),
        ButtonSegment(
          value: SearchMode.semantic,
          label: Text('Semantic'),
          icon: Icon(Icons.psychology),
        ),
      ],
      selected: {currentFilter.mode},
      onSelectionChanged: (Set<SearchMode> newSelection) {
        onFilterChanged(currentFilter.copyWith(mode: newSelection.first));
      },
      showSelectedIcon: false,
    );
}
