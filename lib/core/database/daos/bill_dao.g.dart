// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_dao.dart';

// ignore_for_file: type=lint
mixin _$BillDaoMixin on DatabaseAccessor<AppDatabase> {
  $PartiesTable get parties => attachedDatabase.parties;
  $VehicleTypesTable get vehicleTypes => attachedDatabase.vehicleTypes;
  $VehiclesTable get vehicles => attachedDatabase.vehicles;
  $MaterialsTable get materials => attachedDatabase.materials;
  $WeighmentsTable get weighments => attachedDatabase.weighments;
  BillDaoManager get managers => BillDaoManager(this);
}

class BillDaoManager {
  final _$BillDaoMixin _db;
  BillDaoManager(this._db);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db.attachedDatabase, _db.parties);
  $$VehicleTypesTableTableManager get vehicleTypes =>
      $$VehicleTypesTableTableManager(_db.attachedDatabase, _db.vehicleTypes);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db.attachedDatabase, _db.vehicles);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db.attachedDatabase, _db.materials);
  $$WeighmentsTableTableManager get weighments =>
      $$WeighmentsTableTableManager(_db.attachedDatabase, _db.weighments);
}
