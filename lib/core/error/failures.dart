import 'package:equatable/equatable.dart';

/// Base class for all failures in the domain layer.
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class FileSystemFailure extends Failure {
  const FileSystemFailure(super.message);
}

class AIModelFailure extends Failure {
  const AIModelFailure(super.message);
}

class DocumentProcessingFailure extends Failure {
  const DocumentProcessingFailure(super.message);
}

class SchedulerFailure extends Failure {
  const SchedulerFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
