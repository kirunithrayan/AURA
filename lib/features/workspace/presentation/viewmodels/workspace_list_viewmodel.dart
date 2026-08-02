import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/riverpod_providers.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/usecases/get_workspaces.dart';
import '../../domain/usecases/delete_workspace.dart';
import '../../domain/usecases/update_workspace.dart';
import '../../domain/usecases/create_workspace.dart';

part 'workspace_list_viewmodel.g.dart';

enum WorkspaceSortOption { name, date, size }
enum WorkspaceViewMode { grid, list }

class WorkspaceListState {

  WorkspaceListState({
    this.workspaces = const [],
    this.sortOption = WorkspaceSortOption.date,
    this.viewMode = WorkspaceViewMode.grid,
  });
  final List<Workspace> workspaces;
  final WorkspaceSortOption sortOption;
  final WorkspaceViewMode viewMode;

  WorkspaceListState copyWith({
    List<Workspace>? workspaces,
    WorkspaceSortOption? sortOption,
    WorkspaceViewMode? viewMode,
  }) => WorkspaceListState(
      workspaces: workspaces ?? this.workspaces,
      sortOption: sortOption ?? this.sortOption,
      viewMode: viewMode ?? this.viewMode,
    );
}

@riverpod
class WorkspaceListViewModel extends _$WorkspaceListViewModel {
  GetWorkspaces get _getWorkspaces => GetWorkspaces(ref.read(workspaceRepositoryProvider));
  DeleteWorkspace get _deleteWorkspace => DeleteWorkspace(ref.read(workspaceRepositoryProvider));
  UpdateWorkspace get _updateWorkspace => UpdateWorkspace(ref.read(workspaceRepositoryProvider));
  CreateWorkspace get _createWorkspace => CreateWorkspace(ref.read(workspaceRepositoryProvider));

  @override
  FutureOr<WorkspaceListState> build() async {
    return _fetchWorkspaces();
  }

  Future<WorkspaceListState> _fetchWorkspaces() async {
    final result = await _getWorkspaces();
    return result.fold(
      (failure) => throw failure.message,
      (workspaces) => WorkspaceListState(workspaces: _sortWorkspaces(workspaces, WorkspaceSortOption.date)),
    );
  }
  
  List<Workspace> _sortWorkspaces(List<Workspace> items, WorkspaceSortOption option) {
    final sorted = List<Workspace>.from(items);
    switch (option) {
      case WorkspaceSortOption.name:
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case WorkspaceSortOption.date:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case WorkspaceSortOption.size:
        sorted.sort((a, b) => b.totalSize.compareTo(a.totalSize));
        break;
    }
    return sorted;
  }

  void setSortOption(WorkspaceSortOption option) {
    if (state.hasValue && state.value != null) {
      final current = state.value!;
      state = AsyncValue.data(current.copyWith(
        sortOption: option,
        workspaces: _sortWorkspaces(current.workspaces, option),
      ));
    }
  }

  void setViewMode(WorkspaceViewMode mode) {
    if (state.hasValue && state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(viewMode: mode));
    }
  }

  Future<void> removeWorkspace(String id) async {
    if (!state.hasValue || state.value == null) return;
    
    final result = await _deleteWorkspace(id);
    result.fold(
      (failure) {
        // Log failure
      },
      (_) {
        final current = state.value!;
        final updatedList = current.workspaces.where((w) => w.id != id).toList();
        state = AsyncValue.data(current.copyWith(workspaces: updatedList));
      },
    );
  }

  Future<void> updateWorkspaceDetails(Workspace updatedWorkspace) async {
    if (!state.hasValue || state.value == null) return;
    
    final result = await _updateWorkspace(updatedWorkspace);
    result.fold(
      (failure) {
        // Log failure
      },
      (savedWorkspace) {
        final current = state.value!;
        final updatedList = current.workspaces.map<Workspace>((w) => w.id == savedWorkspace.id ? savedWorkspace : w).toList();
        state = AsyncValue.data(current.copyWith(
          workspaces: _sortWorkspaces(updatedList, current.sortOption)
        ));
      },
    );
  }

  Future<bool> addWorkspace({
    required String name,
    String description = '',
    String icon = 'folder',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final newWorkspace = Workspace(
      id: now.toString(),
      name: name,
      description: description,
      icon: icon,
      createdAt: now,
      updatedAt: now,
      fileCount: 0,
      totalSize: 0,
      isPinned: false,
    );

    final result = await _createWorkspace(newWorkspace);
    return result.fold(
      (failure) => false,
      (savedWorkspace) {
        if (state.hasValue && state.value != null) {
          final current = state.value!;
          final updatedList = [savedWorkspace, ...current.workspaces];
          state = AsyncValue.data(current.copyWith(
            workspaces: _sortWorkspaces(updatedList, current.sortOption),
          ));
        } else {
          ref.invalidateSelf();
        }
        return true;
      },
    );
  }
}
