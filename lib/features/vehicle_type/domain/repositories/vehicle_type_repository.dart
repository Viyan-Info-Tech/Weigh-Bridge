import '../entities/vehicle_type.dart';

abstract class VehicleTypeRepository {
  Future<List<VehicleType>> getAllVehicleTypes();
  Future<List<VehicleType>> getVehicleTypesByStatus({required bool isActive});
  Future<VehicleType?> getVehicleTypeById(int id);
  Future<int> createVehicleType({
    required String name,
    double emptyPrice = 0,
    double loadPrice = 0,
  });
  Future<bool> updateVehicleType({
    required int id,
    required String name,
    double emptyPrice = 0,
    double loadPrice = 0,
  });
  Future<void> deactivateVehicleType(int id);
  Future<List<VehicleType>> searchVehicleTypes(String query);
}
