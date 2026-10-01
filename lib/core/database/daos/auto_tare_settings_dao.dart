import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/auto_tare_settings_table.dart';

part 'auto_tare_settings_dao.g.dart';

@DriftAccessor(tables: [AutoTareSettings])
class AutoTareSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AutoTareSettingsDaoMixin {
  AutoTareSettingsDao(super.db);

  /// Returns the stored auto tare for the day containing [date], if any.
  Future<AutoTareSetting?> getForDate(DateTime date) async {
    final day = DateTime(date.year, date.month, date.day);
    return (select(
      autoTareSettings,
    )..where((t) => t.tareDate.equals(day))).getSingleOrNull();
  }

  /// Inserts or replaces the auto tare for the day containing [date].
  Future<void> upsertForDate({
    required DateTime date,
    required double tareKg,
    DateTime? savedAt,
  }) async {
    final day = DateTime(date.year, date.month, date.day);
    final now = savedAt ?? DateTime.now();
    final existing = await getForDate(day);
    if (existing != null) {
      await (update(
        autoTareSettings,
      )..where((t) => t.id.equals(existing.id))).write(
        AutoTareSettingsCompanion(tareKg: Value(tareKg), updatedAt: Value(now)),
      );
      return;
    }
    await into(autoTareSettings).insert(
      AutoTareSettingsCompanion.insert(
        tareDate: day,
        tareKg: tareKg,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> deleteForDate(DateTime date) async {
    final day = DateTime(date.year, date.month, date.day);
    return (delete(
      autoTareSettings,
    )..where((t) => t.tareDate.equals(day))).go();
  }
}
