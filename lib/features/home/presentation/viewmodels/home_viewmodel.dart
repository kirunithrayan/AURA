import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/riverpod_providers.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../../workspace/domain/entities/workspace_file.dart';

part 'home_viewmodel.g.dart';

class HomeState {
  const HomeState({
    this.stats,
    this.recentDocuments = const [],
    this.pinnedDocuments = const [],
  });
  final DashboardStats? stats;
  final List<WorkspaceFile> recentDocuments;
  final List<WorkspaceFile> pinnedDocuments;

  HomeState copyWith({
    DashboardStats? stats,
    List<WorkspaceFile>? recentDocuments,
    List<WorkspaceFile>? pinnedDocuments,
  }) => HomeState(
      stats: stats ?? this.stats,
      recentDocuments: recentDocuments ?? this.recentDocuments,
      pinnedDocuments: pinnedDocuments ?? this.pinnedDocuments,
    );
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  FutureOr<HomeState> build() async => _fetchData();

  Future<HomeState> _fetchData() async {
    final repo = ref.watch(homeRepositoryProvider);
    
    final statsResult = await repo.getDashboardStats();
    final stats = statsResult.fold((l) => null, (r) => r);

    final recentResult = await repo.getRecentDocuments(10);
    final recent = recentResult.fold((l) => <WorkspaceFile>[], (r) => r);

    final pinnedResult = await repo.getGlobalPinnedDocuments();
    final pinned = pinnedResult.fold((l) => <WorkspaceFile>[], (r) => r);

    return HomeState(
      stats: stats,
      recentDocuments: recent,
      pinnedDocuments: pinned,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _fetchData());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
