import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/document_metadata.dart';

abstract class DocumentMetadataService {
  Future<Either<Failure, DocumentMetadata>> getMetadata(String id);
  Future<Either<Failure, DocumentMetadata>> createMetadata(DocumentMetadata metadata);
  Future<Either<Failure, DocumentMetadata>> updateMetadata(DocumentMetadata metadata);
  Future<Either<Failure, void>> deleteMetadata(String id);
  Future<Either<Failure, void>> incrementOpenCount(String id);
  Future<Either<Failure, void>> updateLastOpened(String id);
  Future<Either<Failure, void>> updateDocumentStatistics(
      String id, {
        int? pageCount,
        String? resolution,
        int? wordCount,
        int? paragraphCount,
        int? characterCount,
      });
}
