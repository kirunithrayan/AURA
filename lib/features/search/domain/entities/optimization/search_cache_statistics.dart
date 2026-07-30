import 'package:equatable/equatable.dart';

class SearchCacheStatistics extends Equatable {

  const SearchCacheStatistics({
    required this.totalHits,
    required this.totalMisses,
    required this.currentSize,
    required this.maxSize,
    required this.evictions,
  });
  final int totalHits;
  final int totalMisses;
  final int currentSize;
  final int maxSize;
  final int evictions;

  double get hitRate {
    final total = totalHits + totalMisses;
    return total == 0 ? 0.0 : totalHits / total;
  }

  @override
  List<Object?> get props => [totalHits, totalMisses, currentSize, maxSize, evictions];
}
