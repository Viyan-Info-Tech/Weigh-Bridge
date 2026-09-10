import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getActiveVehicles();
  Future<Vehicle?> getVehicleById(int id);
  Future<List<Vehicle>> searchVehicles(String query);
  Future<List<Vehicle>> getVehiclesByPartyId(int partyId);
}
