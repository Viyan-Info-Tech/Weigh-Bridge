import 'package:equatable/equatable.dart';

import '../../domain/entities/billing_settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateBillingSettings extends SettingsEvent {
  final BillingSettings settings;
  const UpdateBillingSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}
