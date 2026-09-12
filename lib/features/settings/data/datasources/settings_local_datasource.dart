import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/billing_settings.dart';

class SettingsLocalDataSource {
  final AppDatabase _database;

  SettingsLocalDataSource(this._database);

  Future<BillingSettings> getSettings() async {
    final record = await _database.appSettingsDao.getSettings();
    return _toEntity(record);
  }

  Future<void> updateSettings(BillingSettings settings) async {
    await _database.appSettingsDao.updateSettings(
      AppSettingsCompanion(
        weightUnit: Value(settings.weightUnit),
        billPrefix: Value(settings.billPrefix),
        billStartingNumber: Value(settings.billStartingNumber),
        billNumberDigits: Value(settings.billNumberDigits),
        businessName: Value(settings.businessName),
        businessSubtitle: Value(settings.businessSubtitle),
        serviceText: Value(settings.serviceText),
        address: Value(settings.address),
        phoneNumber: Value(settings.phoneNumber),
        email: Value(settings.email),
        gstin: Value(settings.gstin),
        logoPath: Value(settings.logoPath),
        receiptTitle: Value(settings.receiptTitle),
        showSerialNumber: Value(settings.showSerialNumber),
        showDate: Value(settings.showDate),
        showTime: Value(settings.showTime),
        showVehicleNumber: Value(settings.showVehicleNumber),
        showMaterial: Value(settings.showMaterial),
        showParty: Value(settings.showParty),
        showVehicleType: Value(settings.showVehicleType),
        showGrossWeight: Value(settings.showGrossWeight),
        showTareWeight: Value(settings.showTareWeight),
        showNetWeight: Value(settings.showNetWeight),
        showAmount: Value(settings.showAmount),
        showPaymentMode: Value(settings.showPaymentMode),
        showCashReceived: Value(settings.showCashReceived),
        showPendingAmount: Value(settings.showPendingAmount),
        showRemarks: Value(settings.showRemarks),
        showFooterNote: Value(settings.showFooterNote),
        footerNote: Value(settings.footerNote),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<String> generateNextBillNumber() async {
    final settings = await getSettings();
    return _database.appSettingsDao.generateNextBillNumber(
      prefix: settings.billPrefix,
      digits: settings.billNumberDigits,
      startingNumber: settings.billStartingNumber,
    );
  }

  BillingSettings _toEntity(dynamic record) {
    return BillingSettings(
      weightUnit: record.weightUnit,
      billPrefix: record.billPrefix,
      billStartingNumber: record.billStartingNumber,
      billNumberDigits: record.billNumberDigits,
      businessName: record.businessName,
      businessSubtitle: record.businessSubtitle,
      serviceText: record.serviceText,
      address: record.address,
      phoneNumber: record.phoneNumber,
      email: record.email,
      gstin: record.gstin,
      logoPath: record.logoPath,
      receiptTitle: record.receiptTitle,
      showSerialNumber: record.showSerialNumber,
      showDate: record.showDate,
      showTime: record.showTime,
      showVehicleNumber: record.showVehicleNumber,
      showMaterial: record.showMaterial,
      showParty: record.showParty,
      showVehicleType: record.showVehicleType,
      showGrossWeight: record.showGrossWeight,
      showTareWeight: record.showTareWeight,
      showNetWeight: record.showNetWeight,
      showAmount: record.showAmount,
      showPaymentMode: record.showPaymentMode,
      showCashReceived: record.showCashReceived,
      showPendingAmount: record.showPendingAmount,
      showRemarks: record.showRemarks,
      showFooterNote: record.showFooterNote,
      footerNote: record.footerNote,
      updatedAt: record.updatedAt,
    );
  }
}
