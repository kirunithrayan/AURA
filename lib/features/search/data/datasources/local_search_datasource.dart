import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../document_metadata/domain/entities/document_metadata.dart';
import '../../../document_metadata/data/models/document_metadata_model.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/entities/search_failure.dart';

class LocalSearchDatasource {
  final DatabaseHelper _dbHelper;

  LocalSearchDatasource(this._dbHelper);

  Future<List<DocumentMetadata>> getCandidateMetadata(SearchQuery query) async {
    try {
      final db = await _dbHelper.database;
      
      // Base query
      String sql = 'SELECT * FROM ${DbConstants.workspaceFilesTable} WHERE 1=1';
      List<dynamic> args = [];
    
    // Filter by workspace
    if (query.workspaceId != null) {
      sql += ' AND workspace_id = ?';
      args.add(query.workspaceId);
    }
    
    // Filter by fileTypes
    if (query.filter.fileTypes.isNotEmpty) {
      final placeholders = List.filled(query.filter.fileTypes.length, '?').join(',');
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
    
    // Simple metadata keyword search
    if (query.keyword.isNotEmpty) {
      // Escape SQL wildcards to prevent malicious inputs
      final escapedKeyword = query.keyword
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      
      sql += ' AND (file_name LIKE ? ESCAPE \'\\\' OR tags LIKE ? ESCAPE \'\\\')';
      args.add('%$escapedKeyword%');
      args.add('%$escapedKeyword%');
    }
    
    // Limits
    sql += ' LIMIT ? OFFSET ?';
    args.add(query.limit);
    args.add(query.offset);

      final results = await db.rawQuery(sql, args);
      
      return results.map((map) => DocumentMetadataModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to execute metadata search query', e);
    }
  }
}
