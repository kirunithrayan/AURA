import 'package:equatable/equatable.dart';

class SearchCacheKey extends Equatable {

  const SearchCacheKey({
    required this.normalizedKeyword,
    required this.filterHash,
    required this.offset,
    required this.limit,
  });
  final String normalizedKeyword;
  final String filterHash;
  final int offset;
  final int limit;

  @override
  List<Object?> get props => [normalizedKeyword, filterHash, offset, limit];
}
