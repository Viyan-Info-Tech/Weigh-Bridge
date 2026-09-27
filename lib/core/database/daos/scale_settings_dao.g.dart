// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scale_settings_dao.dart';

// ignore_for_file: type=lint
mixin _$ScaleSettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ScaleSettingsTable get scaleSettings => attachedDatabase.scaleSettings;
  ScaleSettingsDaoManager get managers => ScaleSettingsDaoManager(this);
}

class ScaleSettingsDaoManager {
  final _$ScaleSettingsDaoMixin _db;
  ScaleSettingsDaoManager(this._db);
  $$ScaleSettingsTableTableManager get scaleSettings =>
      $$ScaleSettingsTableTableManager(_db.attachedDatabase, _db.scaleSettings);
}
