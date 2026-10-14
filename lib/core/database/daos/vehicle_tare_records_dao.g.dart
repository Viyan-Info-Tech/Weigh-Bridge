// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_tare_records_dao.dart';

// ignore_for_file: type=lint
mixin _$VehicleTareRecordsDaoMixin on DatabaseAccessor<AppDatabase> {
  $VehicleTareRecordsTable get vehicleTareRecords =>
      attachedDatabase.vehicleTareRecords;
  VehicleTareRecordsDaoManager get managers =>
      VehicleTareRecordsDaoManager(this);
}

class VehicleTareRecordsDaoManager {
  final _$VehicleTareRecordsDaoMixin _db;
  VehicleTareRecordsDaoManager(this._db);
  $$VehicleTareRecordsTableTableManager get vehicleTareRecords =>
      $$VehicleTareRecordsTableTableManager(
        _db.attachedDatabase,
        _db.vehicleTareRecords,
      );
}
