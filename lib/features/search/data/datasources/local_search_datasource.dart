import 'package:flutter/foundation.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../document_metadata/domain/entities/document_metadata.dart';
import '../../../document_metadata/data/models/document_metadata_model.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_failure.dart';

class LocalSearchDatasource {

  LocalSearchDatasource(this._dbHelper);
  final DatabaseHelper _dbHelper;

  /// Builds the candidate-selection query.
  ///
  /// Candidates are the documents a search is allowed to consider. Selection
  /// applies *structural* filters only — workspace, file type, favorite, pin
  /// and date range. It deliberately does not look at [SearchQuery.keyword].
  ///
  /// Keyword relevance is decided downstream against the persisted search
  /// index, which is the only thing that knows document *content*. Filtering
  /// candidates by `file_name LIKE %keyword%` here used to short-circuit that:
  /// a term appearing only in the body produced zero candidates, so the engine
  /// returned early and the index was never consulted. Filename matching is
  /// not lost — the matching strategy scores `fileName` directly, with a title
  /// boost.
  @visibleForTesting
  static ({String sql, List<Object?> args}) buildCandidateQuery(
      SearchQuery query) {
    String sql = 'SELECT * FROM ${DbConstants.workspaceFilesTable} WHERE 1=1';
    final args = <Object?>[];

    // Filter by workspace
    if (query.workspaceId != null) {
      sql += ' AND workspace_id = ?';
      args.add(query.workspaceId);
    }

    // Filter by fileTypes
    if (query.filter.fileTypes.isNotEmpty) {
      final placeholders =
          List.filled(query.filter.fileTypes.length, '?').join(',');
      sql += ' AND extension IN ($placeholders)';
      args.addAll(query.filter.fileTypes);
    }

    // Filter by favorites
    if (query.filter.favoritesOnly) {
      sql += ' AND is_favorite = 1';
    }

    // Filter by pinned
    if (query.filter.pinnedOnly) {
      sql += ' AND is_pinned = 1';
    }

    // Filter by date range
    if (query.filter.startDate != null) {
      sql += ' AND created_at >= ?';
      args.add(query.filter.startDate!.millisecondsSinceEpoch);
    }
    if (query.filter.endDate != null) {
      sql += ' AND created_at <= ?';
      args.add(query.filter.endDate!.millisecondsSinceEpoch);
    }

    // Limits
    sql += ' LIMIT ? OFFSET ?';
    args.add(query.limit);
    args.add(query.offset);

    return (sql: sql, args: args);
  }

  Future<List<DocumentMetadata>> getCandidateMetadata(SearchQuery query) async {
    try {
      final db = await _dbHelper.database;
      final built = buildCandidateQuery(query);
      final results = await db.rawQuery(built.sql, built.args);

      return results.map(DocumentMetadataModel.fromMap).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to execute metadata search query', e);
    }
  }
}
