import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';

/// Base generic architecture for Riverpod AsyncNotifiers in AURA.
/// Standardizes loading states, error catching, and repository response handling.
abstract class BaseViewModel<T> extends AsyncNotifier<T> {
  
  /// Helper method to execute a repository call returning an Either<Failure, T>.
  /// Automatically manages AsyncLoading, AsyncData, and AsyncError states.
  Future<void> executeSafe(Future<Either<Failure, T>> Function() action) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await action();
      
      result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (data) {
          state = AsyncValue.data(data);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error('An unexpected error occurred: $e', stackTrace);
    }
  }

  /// Helper to partially update the state without a full reload, 
  /// provided the current state is already data.
  void updateState(T Function(T currentState) updateAction) {
    if (state.hasValue && state.value != null) {
      state = AsyncValue.data(updateAction(state.value as T));
    }
  }
}
