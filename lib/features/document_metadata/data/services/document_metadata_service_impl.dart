import 'package:fpdart/fpdart.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/document_metadata.dart';
import '../../domain/services/document_metadata_service.dart';
import '../models/document_metadata_model.dart';
import '../cache/metadata_cache.dart';

class DocumentMetadataServiceImpl implements DocumentMetadataService {

  DocumentMetadataServiceImpl(this.dbHelper, this.cache);
  final DatabaseHelper dbHelper;
  final MetadataCache cache;

  @override
  Future<Either<Failure, DocumentMetadata>> getMetadata(String id) async {
    try {
      final cached = cache.get(id);
      if (cached != null) {
        return Right(cached);
      }

      final db = await dbHelper.database;
      final results = await db.query(
        DbConstants.workspaceFilesTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isEmpty) {
        return const Left(DatabaseFailure('Metadata not found'));
      }

      final metadata = DocumentMetadataModel.fromMap(results.first);
      cache.put(id, metadata);
      return Right(metadata);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get metadata: $e'));
    }
  }

  @override
  Future<Either<Failure, DocumentMetadata>> createMetadata(DocumentMetadata metadata) async {
    try {
      final db = await dbHelper.database;
      final model = DocumentMetadataModel.fromEntity(metadata);
      await db.insert(DbConstants.workspaceFilesTable, model.toMap());
      cache.put(metadata.id, metadata);
      AppLogger.info('DocumentMetadataService: Created metadata for ${metadata.id}');
      return Right(metadata);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create metadata: $e'));
    }
  }

  @override
  Future<Either<Failure, DocumentMetadata>> updateMetadata(DocumentMetadata metadata) async {
    try {
      final db = await dbHelper.database;
      final model = DocumentMetadataModel.fromEntity(metadata);
      await db.update(
        DbConstants.workspaceFilesTable,
        model.toMap(),
        where: 'id = ?',
        whereArgs: [metadata.id],
      );
      cache.put(metadata.id, metadata);
      AppLogger.info('DocumentMetadataService: Updated metadata for ${metadata.id}');
      return Right(metadata);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update metadata: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMetadata(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        DbConstants.workspaceFilesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      cache.remove(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete metadata: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementOpenCount(String id) async {
    try {
      final db = await dbHelper.database;
      await db.rawUpdate('''
        UPDATE ${DbConstants.workspaceFilesTable} 
        SET open_count = open_count + 1 
        WHERE id = ?
      ''', [id]);
      
      final cached = cache.get(id);
      if (cached != null) {
        cache.put(id, cached.copyWith(openCount: cached.openCount + 1));
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to increment open count: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLastOpened(String id) async {
    try {
      final db = await dbHelper.database;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await db.rawUpdate('''
        UPDATE ${DbConstants.workspaceFilesTable} 
        SET last_opened_at = ? 
        WHERE id = ?
      ''', [timestamp, id]);
      
      final cached = cache.get(id);
      if (cached != null) {
        cache.put(id, cached.copyWith(lastOpenedAt: timestamp));
      }
      AppLogger.info('DocumentMetadataService: Updated last opened for $id');
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update last opened: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDocumentStatistics(
    String id, {
    int? pageCount,
    String? resolution,
    int? wordCount,
    int? paragraphCount,
    int? characterCount,
  }) async {
    try {
      final db = await dbHelper.database;
      final Map<String, dynamic> updates = {};
      if (pageCount != null) updates['page_count'] = pageCount;
      if (resolution != null) updates['resolution'] = resolution;
      if (wordCount != null) updates['word_count'] = wordCount;
      if (paragraphCount != null) updates['paragraph_count'] = paragraphCount;
      if (characterCount != null) updates['character_count'] = characterCount;
      
      if (updates.isEmpty) return const Right(null);
      
      await db.update(
        DbConstants.workspaceFilesTable,
        updates,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      final cached = cache.get(id);
      if (cached != null) {
        cache.put(id, cached.copyWith(
          pageCount: pageCount ?? cached.pageCount,
          resolution: resolution ?? cached.resolution,
          wordCount: wordCount ?? cached.wordCount,
          paragraphCount: paragraphCount ?? cached.paragraphCount,
          characterCount: characterCount ?? cached.characterCount,
        ));
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update statistics: $e'));
    }
  }
}
