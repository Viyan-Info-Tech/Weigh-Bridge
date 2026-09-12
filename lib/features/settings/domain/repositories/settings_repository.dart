import '../entities/billing_settings.dart';

abstract class SettingsRepository {
  Future<BillingSettings> getSettings();
  Future<void> updateSettings(BillingSettings settings);
  Future<String> generateNextBillNumber();
}
