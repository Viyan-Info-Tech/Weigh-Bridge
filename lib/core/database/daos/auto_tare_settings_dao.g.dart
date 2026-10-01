// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_tare_settings_dao.dart';

// ignore_for_file: type=lint
mixin _$AutoTareSettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AutoTareSettingsTable get autoTareSettings =>
      attachedDatabase.autoTareSettings;
  AutoTareSettingsDaoManager get managers => AutoTareSettingsDaoManager(this);
}

class AutoTareSettingsDaoManager {
  final _$AutoTareSettingsDaoMixin _db;
  AutoTareSettingsDaoManager(this._db);
  $$AutoTareSettingsTableTableManager get autoTareSettings =>
      $$AutoTareSettingsTableTableManager(
        _db.attachedDatabase,
        _db.autoTareSettings,
      );
}
