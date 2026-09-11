// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_type_dao.dart';

// ignore_for_file: type=lint
mixin _$VehicleTypeDaoMixin on DatabaseAccessor<AppDatabase> {
  $VehicleTypesTable get vehicleTypes => attachedDatabase.vehicleTypes;
  VehicleTypeDaoManager get managers => VehicleTypeDaoManager(this);
}

class VehicleTypeDaoManager {
  final _$VehicleTypeDaoMixin _db;
  VehicleTypeDaoManager(this._db);
  $$VehicleTypesTableTableManager get vehicleTypes =>
      $$VehicleTypesTableTableManager(_db.attachedDatabase, _db.vehicleTypes);
}
