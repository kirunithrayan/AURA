import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class WorkspaceIconPicker extends StatelessWidget {

  const WorkspaceIconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });
  final String selectedIcon;
  final Function(String) onIconSelected;

  // Small curated list of icons for Phase 1
  static const Map<String, IconData> _icons = {
    'folder': Icons.folder,
    'school': Icons.school,
    'work': Icons.work,
    'menu_book': Icons.menu_book,
    'science': Icons.science,
    'flight': Icons.flight,
    'home': Icons.home,
    'code': Icons.code,
    'favorite': Icons.favorite,
    'star': Icons.star,
  };

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workspace Icon',
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _icons.entries.map((entry) {
            final isSelected = selectedIcon == entry.key;
            return InkWell(
              onTap: () => onIconSelected(entry.key),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? context.theme.colorScheme.primaryContainer : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                        ? context.theme.colorScheme.primary 
                        : context.theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  entry.value,
                  color: isSelected ? context.theme.colorScheme.primary : context.theme.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
}
