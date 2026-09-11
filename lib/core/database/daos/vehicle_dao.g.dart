// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_dao.dart';

// ignore_for_file: type=lint
mixin _$VehicleDaoMixin on DatabaseAccessor<AppDatabase> {
  $VehicleTypesTable get vehicleTypes => attachedDatabase.vehicleTypes;
  $VehiclesTable get vehicles => attachedDatabase.vehicles;
  VehicleDaoManager get managers => VehicleDaoManager(this);
}

class VehicleDaoManager {
  final _$VehicleDaoMixin _db;
  VehicleDaoManager(this._db);
  $$VehicleTypesTableTableManager get vehicleTypes =>
      $$VehicleTypesTableTableManager(_db.attachedDatabase, _db.vehicleTypes);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db.attachedDatabase, _db.vehicles);
}
