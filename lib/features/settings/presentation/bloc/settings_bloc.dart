import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettingsUseCase _getSettingsUseCase;
  final UpdateSettingsUseCase _updateSettingsUseCase;

  SettingsBloc({
    required GetSettingsUseCase getSettingsUseCase,
    required UpdateSettingsUseCase updateSettingsUseCase,
  })  : _getSettingsUseCase = getSettingsUseCase,
        _updateSettingsUseCase = updateSettingsUseCase,
        super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateBillingSettings>(_onUpdateSettings);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading, clearError: true, clearSuccess: true));

    try {
      final settings = await _getSettingsUseCase();
      emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: settings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: 'Failed to load settings: $e',
      ));
    }
  }

  Future<void> _onUpdateSettings(UpdateBillingSettings event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.saving, clearError: true, clearSuccess: true));

    try {
      await _updateSettingsUseCase(event.settings);
      emit(state.copyWith(
        status: SettingsStatus.saved,
        settings: event.settings,
        successMessage: 'Settings saved successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: 'Failed to save settings: $e',
      ));
    }
  }
}
