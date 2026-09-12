import '../entities/billing_settings.dart';
import '../repositories/settings_repository.dart';

class UpdateSettingsUseCase {
  final SettingsRepository _repository;

  UpdateSettingsUseCase(this._repository);

  Future<void> call(BillingSettings settings) async {
    return _repository.updateSettings(settings);
  }
}
