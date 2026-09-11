import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide Vehicle;
import '../../domain/entities/vehicle.dart';

class VehicleLocalDataSource {
  final AppDatabase _database;

  VehicleLocalDataSource(this._database);

  Future<List<Vehicle>> getAllVehicles() async {
    final records = await _database.vehicleDao.getAllVehicles();
    return records.map(_toEntity).toList();
  }

  Future<List<Vehicle>> getAllActiveVehicles() async {
    final records = await _database.vehicleDao.getAllActiveVehicles();
    return records.map(_toEntity).toList();
  }

  Future<List<Vehicle>> getVehiclesByStatus({required bool isActive}) async {
    final records = await _database.vehicleDao.getVehiclesByStatus(isActive: isActive);
    return records.map(_toEntity).toList();
  }

  Future<Vehicle?> getVehicleById(int id) async {
    final record = await _database.vehicleDao.getVehicleById(id);
    return record != null ? _toEntity(record) : null;
  }

  Future<Vehicle?> getVehicleByNumber(String number) async {
    final record = await _database.vehicleDao.getVehicleByNumber(number);
    return record != null ? _toEntity(record) : null;
  }

  Future<List<Vehicle>> getVehiclesByPartyId(int partyId) async {
    final records = await _database.vehicleDao.getVehiclesByPartyId(partyId);
    return records.map(_toEntity).toList();
  }

  Future<List<Vehicle>> getVehiclesByPartyIdAll(int partyId) async {
    final records = await _database.vehicleDao.getVehiclesByPartyIdAll(partyId);
    return records.map(_toEntity).toList();
  }

  Future<int> insertVehicle({
    required String vehicleNumber,
    required int partyId,
    String? vehicleType,
    String? driverName,
    String? driverPhone,
    double? tareWeight,
  }) async {
    return _database.vehicleDao.insertVehicle(VehiclesCompanion(
      vehicleNumber: Value(vehicleNumber),
      partyId: Value(partyId),
      vehicleType: Value(vehicleType),
      driverName: Value(driverName),
      driverPhone: Value(driverPhone),
      tareWeight: Value(tareWeight),
    ));
  }

  Future<bool> updateVehicle({
    required int id,
    required String vehicleNumber,
    required int partyId,
    String? vehicleType,
    String? driverName,
    String? driverPhone,
    double? tareWeight,
  }) async {
    return _database.vehicleDao.updateVehicle(VehiclesCompanion(
      id: Value(id),
      vehicleNumber: Value(vehicleNumber),
      partyId: Value(partyId),
      vehicleType: Value(vehicleType),
      driverName: Value(driverName),
      driverPhone: Value(driverPhone),
      tareWeight: Value(tareWeight),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deactivateVehicle(int id) async {
    await _database.vehicleDao.deactivateVehicle(id);
  }

  Future<List<Vehicle>> searchVehicles(String query) async {
    final records = await _database.vehicleDao.searchVehicles(query);
    return records.map(_toEntity).toList();
  }

  Vehicle _toEntity(dynamic record) {
    return Vehicle(
      id: record.id,
      vehicleNumber: record.vehicleNumber,
      partyId: record.partyId,
      vehicleType: record.vehicleType,
      driverName: record.driverName,
      driverPhone: record.driverPhone,
      tareWeight: record.tareWeight,
      isActive: record.isActive,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
