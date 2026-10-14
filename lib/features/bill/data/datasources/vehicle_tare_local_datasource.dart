import '../../../../core/database/app_database.dart' hide VehicleTareRecord;
import '../../domain/entities/vehicle_tare_record.dart';

class VehicleTareLocalDataSource {
  final AppDatabase _database;

  VehicleTareLocalDataSource(this._database);

  Future<List<VehicleTareRecord>> loadVehicleTares() async {
    final rows = await _database.vehicleTareRecordsDao.getAllOrdered();
    return rows.map(_toEntity).toList();
  }

  Stream<List<VehicleTareRecord>> watchVehicleTares() {
    return _database.vehicleTareRecordsDao
        .watchTareWeights()
        .map((rows) => rows.map(_toEntity).toList());
  }

  Future<VehicleTareRecord> saveVehicleTare({
    required String vehicleNumber,
    required double tareKg,
  }) async {
    final normalized = vehicleNumber.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw ArgumentError('Vehicle number is required.');
    }
    if (!tareKg.isFinite || tareKg <= 0) {
      throw ArgumentError('Tare weight must be greater than zero.');
    }
    final row = await _database.vehicleTareRecordsDao.upsert(
      vehicleNumber: normalized,
      tareKg: tareKg,
    );
    return _toEntity(row);
  }

  Future<VehicleTareRecord> updateVehicleTare({
    required int id,
    required String vehicleNumber,
    required double tareKg,
  }) async {
    final normalized = vehicleNumber.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw ArgumentError('Vehicle number is required.');
    }
    if (!tareKg.isFinite || tareKg <= 0) {
      throw ArgumentError('Tare weight must be greater than zero.');
    }
    return _toEntity(
      await _database.vehicleTareRecordsDao.updateById(
        id: id,
        vehicleNumber: normalized,
        tareKg: tareKg,
      ),
    );
  }

  Future<void> deleteVehicleTare(String vehicleNumber) async {
    await _database.vehicleTareRecordsDao.deleteByVehicleNumber(vehicleNumber);
  }

  VehicleTareRecord _toEntity(dynamic row) {
    return VehicleTareRecord(
      id: row.id as int?,
      vehicleNumber: row.vehicleNumber as String,
      tareKg: (row.tareKg as num).toDouble(),
      createdAt: row.createdAt as DateTime?,
      updatedAt: row.updatedAt as DateTime?,
    );
  }
}
