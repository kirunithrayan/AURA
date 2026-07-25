import 'package:equatable/equatable.dart';
import 'search_index_entry.dart';

/// Represents a fully built search index for a single document.
class SearchIndex extends Equatable {
  final String documentId;
  final String workspaceId;
  final String documentType;
  final DateTime indexedAt;
  final int wordCount;
  final String checksum;
  final String parserVersion;
  final List<SearchIndexEntry> entries;

  const SearchIndex({
    required this.documentId,
    required this.workspaceId,
    required this.documentType,
    required this.indexedAt,
    required this.wordCount,
    required this.checksum,
    required this.parserVersion,
    required this.entries,
  });

  SearchIndex copyWith({
    String? documentId,
    String? workspaceId,
    String? documentType,
    DateTime? indexedAt,
    int? wordCount,
    String? checksum,
    String? parserVersion,
    List<SearchIndexEntry>? entries,
  }) {
    return SearchIndex(
      documentId: documentId ?? this.documentId,
      workspaceId: workspaceId ?? this.workspaceId,
      documentType: documentType ?? this.documentType,
      indexedAt: indexedAt ?? this.indexedAt,
      wordCount: wordCount ?? this.wordCount,
      checksum: checksum ?? this.checksum,
      parserVersion: parserVersion ?? this.parserVersion,
      entries: entries ?? this.entries,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'document_id': documentId,
      'workspace_id': workspaceId,
      'document_type': documentType,
      'indexed_at': indexedAt.millisecondsSinceEpoch,
      'word_count': wordCount,
      'checksum': checksum,
      'parser_version': parserVersion,
    };
  }

  factory SearchIndex.fromMap(Map<String, dynamic> map, List<SearchIndexEntry> entries) {
    return SearchIndex(
      documentId: map['document_id'] as String,
      workspaceId: map['workspace_id'] as String,
      documentType: map['document_type'] as String,
      indexedAt: DateTime.fromMillisecondsSinceEpoch(map['indexed_at'] as int),
      wordCount: map['word_count'] as int,
      checksum: map['checksum'] as String,
      parserVersion: map['parser_version'] as String,
      entries: entries,
    );
  }

  @override
  List<Object?> get props => [
        documentId,
        workspaceId,
        documentType,
        indexedAt,
        wordCount,
        checksum,
        parserVersion,
        entries,
      ];
}
