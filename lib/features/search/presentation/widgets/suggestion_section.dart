import 'package:flutter/material.dart';
import '../../domain/entities/search_suggestion.dart';

class SuggestionSection extends StatelessWidget {
  final List<SearchSuggestion> suggestions;
  final ValueChanged<String> onSuggestionTap;

  const SuggestionSection({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Suggestions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              leading: Icon(
                suggestion.type == SuggestionType.history 
                    ? Icons.history 
                    : Icons.trending_up,
                color: Colors.grey,
              ),
              title: Text(suggestion.text),
              onTap: () => onSuggestionTap(suggestion.text),
            );
          },
        ),
      ],
    );
  }
}
