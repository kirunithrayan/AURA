import 'package:equatable/equatable.dart';

class SearchCacheKey extends Equatable {
  final String normalizedKeyword;
  final String filterHash;
  final int offset;
  final int limit;

  const SearchCacheKey({
    required this.normalizedKeyword,
    required this.filterHash,
    required this.offset,
    required this.limit,
  });

  @override
  List<Object?> get props => [normalizedKeyword, filterHash, offset, limit];
}
