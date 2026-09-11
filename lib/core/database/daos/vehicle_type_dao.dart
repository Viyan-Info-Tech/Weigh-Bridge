import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/vehicle_types_table.dart';

part 'vehicle_type_dao.g.dart';

@DriftAccessor(tables: [VehicleTypes])
class VehicleTypeDao extends DatabaseAccessor<AppDatabase> with _$VehicleTypeDaoMixin {
  VehicleTypeDao(super.db);

  Future<List<VehicleType>> getAllActiveVehicleTypes() async {
    final query = select(vehicleTypes)..where((v) => v.isActive.equals(true));
    return query.get();
  }

  Future<List<VehicleType>> getAllVehicleTypes() async {
    return select(vehicleTypes).get();
  }

  Future<VehicleType?> getVehicleTypeById(int id) async {
    final query = select(vehicleTypes)..where((v) => v.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<VehicleType?> getVehicleTypeByName(String name) async {
    final query = select(vehicleTypes)..where((v) => v.name.equals(name));
    return query.getSingleOrNull();
  }

  Future<int> insertVehicleType(VehicleTypesCompanion entry) async {
    return into(vehicleTypes).insert(entry);
  }

  Future<bool> updateVehicleType(VehicleTypesCompanion entry) async {
    return update(vehicleTypes).replace(entry);
  }

  Future<List<VehicleType>> searchVehicleTypes(String query) async {
    final q = select(vehicleTypes)
      ..where((v) => v.name.like('%$query%'))
      ..limit(20);
    return q.get();
  }

  Future<void> deactivateVehicleType(int id) async {
    final now = DateTime.now();
    await (update(vehicleTypes)..where((v) => v.id.equals(id)))
        .write(VehicleTypesCompanion(
      isActive: const Value(false),
      updatedAt: Value(now),
    ));
  }
}
