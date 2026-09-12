import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getAllVehicles();
  Future<List<Vehicle>> getVehiclesByStatus({required bool isActive});
  Future<Vehicle?> getVehicleById(int id);
  Future<Vehicle?> getVehicleByNumber(String number);
  Future<int> createVehicle({
    required String vehicleNumber,
    required int vehicleTypeId,
    String? driverName,
    String? driverPhone,
  });
  Future<bool> updateVehicle({
    required int id,
    required String vehicleNumber,
    required int vehicleTypeId,
    String? driverName,
    String? driverPhone,
  });
  Future<void> deactivateVehicle(int id);
  Future<void> deleteVehicle(int id);
  Future<List<Vehicle>> searchVehicles(String query);
}
