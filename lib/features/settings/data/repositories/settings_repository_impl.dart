import '../datasources/settings_local_datasource.dart';
import '../../domain/entities/billing_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl({required SettingsLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<BillingSettings> getSettings() async {
    return _localDataSource.getSettings();
  }

  @override
  Future<void> updateSettings(BillingSettings settings) async {
    return _localDataSource.updateSettings(settings);
  }

  @override
  Future<String> generateNextBillNumber() async {
    return _localDataSource.generateNextBillNumber();
  }
}
