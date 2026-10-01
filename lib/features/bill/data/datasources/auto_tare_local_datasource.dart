import '../../../../core/database/app_database.dart' hide Weighment;
import '../../domain/entities/auto_tare_entry.dart';

class AutoTareLocalDataSource {
  final AppDatabase _database;

  AutoTareLocalDataSource(this._database);

  Future<AutoTareEntry?> getAutoTare(DateTime date) async {
    final record = await _database.autoTareSettingsDao.getForDate(date);
    if (record == null) return null;
    return AutoTareEntry(
      tareDate: record.tareDate,
      tareKg: record.tareKg,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  Future<AutoTareEntry> saveAutoTare({
    required DateTime date,
    required double tareKg,
  }) async {
    await _database.autoTareSettingsDao.upsertForDate(
      date: date,
      tareKg: tareKg,
    );
    return (await getAutoTare(date)) ??
        AutoTareEntry(tareDate: date, tareKg: tareKg);
  }

  Future<void> deleteAutoTare(DateTime date) =>
      _database.autoTareSettingsDao.deleteForDate(date);
}
