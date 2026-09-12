import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide VehicleType;
import '../../domain/entities/vehicle_type.dart';

class VehicleTypeLocalDataSource {
  final AppDatabase _database;

  VehicleTypeLocalDataSource(this._database);

  Future<List<VehicleType>> getAllActiveVehicleTypes() async {
    final records = await _database.vehicleTypeDao.getAllActiveVehicleTypes();
    return records.map(_toEntity).toList();
  }

  Future<List<VehicleType>> getAllVehicleTypes() async {
    final records = await _database.vehicleTypeDao.getAllVehicleTypes();
    return records.map(_toEntity).toList();
  }

  Future<VehicleType?> getVehicleTypeById(int id) async {
    final record = await _database.vehicleTypeDao.getVehicleTypeById(id);
    if (record == null) return null;
    return _toEntity(record);
  }

  Future<int> insertVehicleType(VehicleType vehicleType) async {
    return _database.vehicleTypeDao.insertVehicleType(
      VehicleTypesCompanion.insert(
        name: vehicleType.name,
        emptyPrice: Value(vehicleType.emptyPrice),
        loadPrice: Value(vehicleType.loadPrice),
      ),
    );
  }

  Future<bool> updateVehicleType(VehicleType vehicleType) async {
    return _database.vehicleTypeDao.updateVehicleType(
      VehicleTypesCompanion(
        id: Value(vehicleType.id),
        name: Value(vehicleType.name),
        emptyPrice: Value(vehicleType.emptyPrice),
        loadPrice: Value(vehicleType.loadPrice),
        isActive: Value(vehicleType.isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deactivateVehicleType(int id) async {
    return _database.vehicleTypeDao.deactivateVehicleType(id);
  }

  Future<void> deleteVehicleType(int id) async {
    await _database.vehicleTypeDao.deleteVehicleType(id);
  }

  Future<List<VehicleType>> searchVehicleTypes(String query) async {
    final records = await _database.vehicleTypeDao.searchVehicleTypes(query);
    return records.map(_toEntity).toList();
  }

  VehicleType _toEntity(dynamic record) {
    return VehicleType(
      id: record.id,
      name: record.name,
      emptyPrice: record.emptyPrice,
      loadPrice: record.loadPrice,
      isActive: record.isActive,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
