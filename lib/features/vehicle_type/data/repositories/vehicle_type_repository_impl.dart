import '../../domain/entities/vehicle_type.dart';
import '../../domain/repositories/vehicle_type_repository.dart';
import '../datasources/vehicle_type_local_datasource.dart';

class VehicleTypeRepositoryImpl implements VehicleTypeRepository {
  final VehicleTypeLocalDataSource _localDataSource;

  VehicleTypeRepositoryImpl({required VehicleTypeLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<VehicleType>> getAllVehicleTypes() async {
    return _localDataSource.getAllVehicleTypes();
  }

  @override
  Future<List<VehicleType>> getVehicleTypesByStatus({required bool isActive}) async {
    if (isActive) {
      return _localDataSource.getAllActiveVehicleTypes();
    }
    return _localDataSource.getAllVehicleTypes();
  }

  @override
  Future<VehicleType?> getVehicleTypeById(int id) async {
    return _localDataSource.getVehicleTypeById(id);
  }

  @override
  Future<int> createVehicleType({
    required String name,
    double emptyPrice = 0,
    double loadPrice = 0,
  }) async {
    final now = DateTime.now();
    final vehicleType = VehicleType(
      id: 0,
      name: name,
      emptyPrice: emptyPrice,
      loadPrice: loadPrice,
      createdAt: now,
      updatedAt: now,
    );
    return _localDataSource.insertVehicleType(vehicleType);
  }

  @override
  Future<bool> updateVehicleType({
    required int id,
    required String name,
    double emptyPrice = 0,
    double loadPrice = 0,
  }) async {
    final existing = await _localDataSource.getVehicleTypeById(id);
    if (existing == null) return false;

    final updated = VehicleType(
      id: id,
      name: name,
      emptyPrice: emptyPrice,
      loadPrice: loadPrice,
      isActive: existing.isActive,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return _localDataSource.updateVehicleType(updated);
  }

  @override
  Future<void> deactivateVehicleType(int id) async {
    return _localDataSource.deactivateVehicleType(id);
  }

  @override
  Future<void> deleteVehicleType(int id) async {
    return _localDataSource.deleteVehicleType(id);
  }

  @override
  Future<List<VehicleType>> searchVehicleTypes(String query) async {
    return _localDataSource.searchVehicleTypes(query);
  }
}
