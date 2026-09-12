import '../entities/billing_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository _repository;

  GetSettingsUseCase(this._repository);

  Future<BillingSettings> call() async {
    return _repository.getSettings();
  }
}
