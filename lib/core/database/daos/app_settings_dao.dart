import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_settings_table.dart';

part 'app_settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Future<AppSetting> getSettings() async {
    final result = await select(appSettings).getSingleOrNull();
    if (result != null) return result;
    return await _createDefaults();
  }

  Future<AppSetting> _createDefaults() async {
    final id = await into(appSettings).insert(
      AppSettingsCompanion.insert(
        weightUnit: const Value('ton'),
        billPrefix: const Value('WB'),
        billStartingNumber: const Value(1),
        billNumberDigits: const Value(5),
        businessName: const Value('VIYAN WEIGHBRIDGE'),
        businessSubtitle: const Value('Computer Weigh Bridge'),
        serviceText: const Value('24 HOURS SERVICE'),
        receiptTitle: const Value('WEIGHMENT RECEIPT'),
        footerNote: const Value(
          'Please check the weight before leaving the weighbridge.',
        ),
      ),
    );
    return (select(appSettings)..where((s) => s.id.equals(id))).getSingle();
  }

  Future<void> updateSettings(AppSettingsCompanion companion) async {
    final existing = await select(appSettings).getSingleOrNull();
    if (existing != null) {
      await (update(
        appSettings,
      )..where((s) => s.id.equals(existing.id))).write(companion);
    } else {
      await into(appSettings).insert(companion);
    }
  }

  /// Previews the bill number the next saved weighment would receive.
  ///
  /// This does not reserve the number. Allocation happens inside
  /// [BillDao.insertWeighmentWithNextBillNumber], which is what a save must
  /// use; this exists only so the screen can show the upcoming serial number
  /// before anything is written.
  Future<String> generateNextBillNumber({
    required String prefix,
    required int digits,
    int? startingNumber,
  }) {
    return db.billDao.peekNextBillNumber(
      prefix: prefix,
      digits: digits,
      startingNumber: startingNumber,
    );
  }
}
