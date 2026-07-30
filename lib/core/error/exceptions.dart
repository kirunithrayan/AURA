/// Base exception for all AURA exceptions.
abstract class AuraException implements Exception {
  const AuraException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a database operation fails.
class DatabaseException extends AuraException {
  const DatabaseException(super.message);
}

/// Thrown when file system operations fail (e.g., copy, delete, read).
class FileSystemException extends AuraException {
  const FileSystemException(super.message);
}

/// Thrown when an AI model (embedding, retrieval) fails.
class AIModelException extends AuraException {
  const AIModelException(super.message);
}

/// Thrown when a document cannot be parsed or processed.
class DocumentProcessingException extends AuraException {
  const DocumentProcessingException(super.message);
}

/// Thrown when the scheduler encounters an error scheduling or executing a job.
class SchedulerException extends AuraException {
  const SchedulerException(super.message);
}

/// Thrown when an item is not found (e.g., workspace, file, or embedding).
class NotFoundException extends AuraException {
  const NotFoundException(super.message);
}
