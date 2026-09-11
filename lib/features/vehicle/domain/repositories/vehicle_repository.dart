import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getAllVehicles();
  Future<List<Vehicle>> getVehiclesByStatus({required bool isActive});
  Future<Vehicle?> getVehicleById(int id);
  Future<Vehicle?> getVehicleByNumber(String number);
  Future<List<Vehicle>> getVehiclesByPartyId(int partyId);
  Future<int> createVehicle({
    required String vehicleNumber,
    required int partyId,
    String? vehicleType,
    String? driverName,
    String? driverPhone,
    double? tareWeight,
  });
  Future<bool> updateVehicle({
    required int id,
    required String vehicleNumber,
    required int partyId,
    String? vehicleType,
    String? driverName,
    String? driverPhone,
    double? tareWeight,
  });
  Future<void> deactivateVehicle(int id);
  Future<List<Vehicle>> searchVehicles(String query);
}
