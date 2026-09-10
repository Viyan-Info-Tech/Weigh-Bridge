import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide Vehicle;
import '../../domain/entities/vehicle.dart';

class VehicleLocalDataSource {
  final AppDatabase _database;

  VehicleLocalDataSource(this._database);

  Future<List<Vehicle>> getActiveVehicles() async {
    final records = await _database.vehicleDao.getAllActiveVehicles();
    return records.map(_toEntity).toList();
  }

  Future<Vehicle?> getVehicleById(int id) async {
    final record = await _database.vehicleDao.getVehicleById(id);
    if (record == null) return null;
    return _toEntity(record);
  }

  Future<List<Vehicle>> searchVehicles(String query) async {
    final records = await _database.vehicleDao.searchVehicles(query);
    return records.map(_toEntity).toList();
  }

  Future<List<Vehicle>> getVehiclesByPartyId(int partyId) async {
    final records = await _database.vehicleDao.getVehiclesByPartyId(partyId);
    return records.map(_toEntity).toList();
  }

  Future<int> insertVehicle(String vehicleNumber, int partyId, {String? vehicleType}) async {
    return _database.vehicleDao.insertVehicle(
      VehiclesCompanion.insert(
        vehicleNumber: vehicleNumber,
        partyId: partyId,
        vehicleType: Value(vehicleType),
      ),
    );
  }

  Vehicle _toEntity(dynamic record) {
    return Vehicle(
      id: record.id,
      vehicleNumber: record.vehicleNumber,
      partyId: record.partyId,
      vehicleType: record.vehicleType,
      isActive: record.isActive,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
