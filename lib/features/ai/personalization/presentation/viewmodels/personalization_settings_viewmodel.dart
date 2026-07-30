import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/interaction_repository.dart';
import '../../../../../core/di/injection_container.dart';
// Assuming we have interactionRepositoryProvider

class PersonalizationSettingsState {
  
  const PersonalizationSettingsState({
    this.isLoading = false,
    this.error,
  });
  final bool isLoading;
  final String? error;

  PersonalizationSettingsState copyWith({
    bool? isLoading,
    String? error,
  }) => PersonalizationSettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
}

class PersonalizationSettingsViewModel extends StateNotifier<PersonalizationSettingsState> {

  PersonalizationSettingsViewModel(this._interactionRepository) : super(const PersonalizationSettingsState());
  final InteractionRepository _interactionRepository;

  Future<void> clearMemory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _interactionRepository.clearMemory();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final personalizationSettingsViewModelProvider = StateNotifierProvider<PersonalizationSettingsViewModel, PersonalizationSettingsState>((ref) => PersonalizationSettingsViewModel(sl<InteractionRepository>()));
