import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/vehicle_tare_records_table.dart';

part 'vehicle_tare_records_dao.g.dart';

@DriftAccessor(tables: [VehicleTareRecords])
class VehicleTareRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$VehicleTareRecordsDaoMixin {
  VehicleTareRecordsDao(super.db);

  Future<List<VehicleTareRecord>> getAllOrdered() {
    return (select(
      vehicleTareRecords,
    )..orderBy([(t) => OrderingTerm.asc(t.vehicleNumber)])).get();
  }

  Future<VehicleTareRecord?> getByVehicleNumber(String vehicleNumber) {
    final normalized = vehicleNumber.trim().toUpperCase();
    return (select(
      vehicleTareRecords,
    )..where((t) => t.vehicleNumber.equals(normalized))).getSingleOrNull();
  }

  /// Removes the tare record for [vehicleNumber], if one exists.
  Future<void> deleteByVehicleNumber(String vehicleNumber) async {
    final normalized = vehicleNumber.trim().toUpperCase();
    await (delete(
      vehicleTareRecords,
    )..where((t) => t.vehicleNumber.equals(normalized))).go();
  }

  /// Inserts a new vehicle tare or updates the existing row for the vehicle.
  Future<VehicleTareRecord> upsert({
    required String vehicleNumber,
    required double tareKg,
  }) async {
    final normalized = vehicleNumber.trim().toUpperCase();
    final now = DateTime.now();
    final existing = await getByVehicleNumber(normalized);
    if (existing != null) {
      await (update(
        vehicleTareRecords,
      )..where((t) => t.id.equals(existing.id))).write(
        VehicleTareRecordsCompanion(
          tareKg: Value(tareKg),
          updatedAt: Value(now),
        ),
      );
      final updated = await getByVehicleNumber(normalized);
      return updated!;
    }
    final id = await into(vehicleTareRecords).insert(
      VehicleTareRecordsCompanion.insert(
        vehicleNumber: normalized,
        tareKg: tareKg,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    final inserted = await (select(
      vehicleTareRecords,
    )..where((t) => t.id.equals(id))).getSingle();
    return inserted;
  }

  Future<VehicleTareRecord> updateById({
    required int id,
    required String vehicleNumber,
    required double tareKg,
  }) async {
    final normalized = vehicleNumber.trim().toUpperCase();
    final duplicate = await getByVehicleNumber(normalized);
    if (duplicate != null && duplicate.id != id) {
      throw ArgumentError('A tare record for $normalized already exists.');
    }
    await (update(vehicleTareRecords)..where((t) => t.id.equals(id))).write(
      VehicleTareRecordsCompanion(
        vehicleNumber: Value(normalized),
        tareKg: Value(tareKg),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return (select(
      vehicleTareRecords,
    )..where((t) => t.id.equals(id))).getSingle();
  }
}
