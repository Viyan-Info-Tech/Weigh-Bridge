import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/scale_settings_table.dart';

part 'scale_settings_dao.g.dart';

@DriftAccessor(tables: [ScaleSettings])
class ScaleSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$ScaleSettingsDaoMixin {
  ScaleSettingsDao(super.db);

  Future<ScaleSetting> getSettings() async {
    final result = await select(scaleSettings).getSingleOrNull();
    if (result != null) return result;
    return await _createDefaults();
  }

  Future<ScaleSetting> _createDefaults() async {
    final id = await into(scaleSettings).insert(
      ScaleSettingsCompanion.insert(
        port: Value('COM3'),
        baudRate: Value(9600),
        dataBits: Value(8),
        parity: Value(0),
        stopBits: Value(1),
        protocol: Value('unconfigured'),
        enabled: Value(true),
      ),
    );
    return (select(scaleSettings)..where((s) => s.id.equals(id))).getSingle();
  }

  Future<void> updateSettings(ScaleSettingsCompanion companion) async {
    final existing = await select(scaleSettings).getSingleOrNull();
    if (existing != null) {
      await (update(
        scaleSettings,
      )..where((s) => s.id.equals(existing.id))).write(companion);
    } else {
      await into(scaleSettings).insert(companion);
    }
  }
}
