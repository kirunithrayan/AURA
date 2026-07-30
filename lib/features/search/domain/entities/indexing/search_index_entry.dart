import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Represents a single indexed token with its metadata.
class SearchIndexEntry extends Equatable {

  const SearchIndexEntry({
    required this.normalizedToken,
    required this.originalToken,
    required this.frequency,
    required this.positions,
    required this.field,
  });

  factory SearchIndexEntry.fromMap(Map<String, dynamic> map) => SearchIndexEntry(
      normalizedToken: map['normalized_token'] as String,
      originalToken: map['original_token'] as String,
      frequency: map['frequency'] as int,
      positions: (jsonDecode(map['positions'] as String) as List<dynamic>)
          .cast<int>(),
      field: map['field'] as String,
    );
  final String normalizedToken;
  final String originalToken;
  final int frequency;
  final List<int> positions;
  final String field;

  Map<String, dynamic> toMap(String documentId) => {
      'document_id': documentId,
      'normalized_token': normalizedToken,
      'original_token': originalToken,
      'frequency': frequency,
      'positions': jsonEncode(positions),
      'field': field,
    };

  @override
  List<Object?> get props => [normalizedToken, originalToken, frequency, positions, field];
}
