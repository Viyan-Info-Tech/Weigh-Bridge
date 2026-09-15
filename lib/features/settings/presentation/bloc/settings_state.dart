import 'package:equatable/equatable.dart';

import '../../domain/entities/billing_settings.dart';

enum SettingsStatus { initial, loading, loaded, saving, saved, error }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final BillingSettings? settings;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings,
    this.errorMessage,
    this.successMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    BillingSettings? settings,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage, successMessage];
}
