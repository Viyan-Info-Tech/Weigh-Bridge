import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/vehicle_tare_records_table.dart';

part 'vehicle_tare_records_dao.g.dart';

@DriftAccessor(tables: [VehicleTareRecords])
class VehicleTareRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$VehicleTareRecordsDaoMixin {
  VehicleTareRecordsDao(super.db);

  static const List<Map<String, dynamic>> defaultTareWeights = [
    {'vehicleNo': 'TN 14 L 1112', 'weight': 8200.0},
    {'vehicleNo': 'TN 21 AW 4924', 'weight': 7850.0},
    {'vehicleNo': 'TN 21 AV 2459', 'weight': 7510.0},
    {'vehicleNo': 'TN 21 AV 2463', 'weight': 7300.0},
    {'vehicleNo': 'TN 21 AV 2464', 'weight': 7540.0},
    {'vehicleNo': 'TN 01 X 0793', 'weight': 4700.0},
    {'vehicleNo': 'BULK QUARTZ', 'weight': 21500.0},
    {'vehicleNo': 'JCB - 11', 'weight': 7180.0},
    {'vehicleNo': 'JCB - 19', 'weight': 7470.0},
    {'vehicleNo': 'JCB - 33', 'weight': 7970.0},
    {'vehicleNo': 'JCB - 45', 'weight': 7700.0},
  ];

  /// Returns all stored vehicle tare records in sequential id order.
  Future<List<VehicleTareRecord>> getAllOrdered() {
    return (select(
      vehicleTareRecords,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
  }

  /// Reactive stream of all vehicle tare records.
  Stream<List<VehicleTareRecord>> watchTareWeights() {
    return (select(
      vehicleTareRecords,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();
  }

  /// Inserts the 11 default tare weights if they do not already exist,
  /// and applies a one-time correction for TN 21 AW 4924 to 7,850 kg.
  Future<void> seedDefaultTareWeights() async {
    final now = DateTime.now();

    // 1. One-time correction: Ensure TN 21 AW 4924 is updated to 7850 kg if it was 7550 kg
    final existingTn21 =
        await (select(vehicleTareRecords)..where(
              (t) =>
                  t.vehicleNumber.equals('TN 21 AW 4924') |
                  t.vehicleNumber.equals('TN21AW4924'),
            ))
            .getSingleOrNull();

    if (existingTn21 != null &&
        (existingTn21.tareKg == 7550 || existingTn21.tareKg == 7550.0)) {
      await (update(
        vehicleTareRecords,
      )..where((t) => t.id.equals(existingTn21.id))).write(
        VehicleTareRecordsCompanion(
          tareKg: const Value(7850.0),
          updatedAt: Value(now),
        ),
      );
    }

    // 2. Insert records only when they do not already exist
    for (final item in defaultTareWeights) {
      final vehicleNo = (item['vehicleNo'] as String).trim().toUpperCase();
      final weight = (item['weight'] as num).toDouble();
      final noSpaces = vehicleNo.replaceAll(' ', '');

      final existing =
          await (select(vehicleTareRecords)..where(
                (t) =>
                    t.vehicleNumber.equals(vehicleNo) |
                    t.vehicleNumber.equals(noSpaces),
              ))
              .getSingleOrNull();

      if (existing == null) {
        await into(vehicleTareRecords).insert(
          VehicleTareRecordsCompanion.insert(
            vehicleNumber: vehicleNo,
            tareKg: weight,
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    }
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
