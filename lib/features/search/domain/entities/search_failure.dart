abstract class SearchFailure implements Exception {
  final String message;
  final dynamic cause;

  const SearchFailure(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

class CacheFailure extends SearchFailure {
  const CacheFailure(super.message, [super.cause]);
}

class DatabaseFailure extends SearchFailure {
  const DatabaseFailure(super.message, [super.cause]);
}

class ParserFailure extends SearchFailure {
  const ParserFailure(super.message, [super.cause]);
}

class IndexFailure extends SearchFailure {
  const IndexFailure(super.message, [super.cause]);
}

class QueryValidationFailure extends SearchFailure {
  const QueryValidationFailure(super.message, [super.cause]);
}

class BatchIndexFailure extends SearchFailure {
  const BatchIndexFailure(super.message, [super.cause]);
}

class SearchExecutionFailure extends SearchFailure {
  const SearchExecutionFailure(super.message, [super.cause]);
}

class UnknownSearchFailure extends SearchFailure {
  const UnknownSearchFailure(super.message, [super.cause]);
}
