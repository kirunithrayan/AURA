import 'package:equatable/equatable.dart';

class SearchCacheStatistics extends Equatable {
  final int totalHits;
  final int totalMisses;
  final int currentSize;
  final int maxSize;
  final int evictions;

  const SearchCacheStatistics({
    required this.totalHits,
    required this.totalMisses,
    required this.currentSize,
    required this.maxSize,
    required this.evictions,
  });

  double get hitRate {
    final total = totalHits + totalMisses;
    return total == 0 ? 0.0 : totalHits / total;
  }

  @override
  List<Object?> get props => [totalHits, totalMisses, currentSize, maxSize, evictions];
}
