import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/vehicles_table.dart';
import '../tables/vehicle_types_table.dart';

part 'vehicle_dao.g.dart';

@DriftAccessor(tables: [Vehicles, VehicleTypes])
class VehicleDao extends DatabaseAccessor<AppDatabase> with _$VehicleDaoMixin {
  VehicleDao(super.db);

  Future<List<Vehicle>> getAllActiveVehicles() async {
    final query = select(vehicles)..where((v) => v.isActive.equals(true));
    return query.get();
  }

  Future<List<Vehicle>> getAllVehicles() async {
    return select(vehicles).get();
  }

  Future<List<Vehicle>> getVehiclesByStatus({required bool isActive}) async {
    final query = select(vehicles)..where((v) => v.isActive.equals(isActive));
    return query.get();
  }

  Future<Vehicle?> getVehicleById(int id) async {
    final query = select(vehicles)..where((v) => v.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<Vehicle?> getVehicleByNumber(String number) async {
    final query = select(vehicles)..where((v) => v.vehicleNumber.equals(number));
    return query.getSingleOrNull();
  }

  Future<int> insertVehicle(VehiclesCompanion entry) async {
    return into(vehicles).insert(entry);
  }

  Future<bool> updateVehicle(VehiclesCompanion entry) async {
    return update(vehicles).replace(entry);
  }

  Future<List<Vehicle>> searchVehicles(String query) async {
    final q = select(vehicles)
      ..where((v) =>
          v.vehicleNumber.like('%$query%') |
          v.driverName.like('%$query%'))
      ..limit(20);
    return q.get();
  }

  Future<List<Vehicle>> getVehiclesByType(int vehicleTypeId) async {
    final query = select(vehicles)
      ..where((v) =>
          v.vehicleTypeId.equals(vehicleTypeId) &
          v.isActive.equals(true));
    return query.get();
  }

  Future<void> deactivateVehicle(int id) async {
    final now = DateTime.now();
    await (update(vehicles)..where((v) => v.id.equals(id)))
        .write(VehiclesCompanion(
      isActive: const Value(false),
      updatedAt: Value(now),
    ));
  }
}
