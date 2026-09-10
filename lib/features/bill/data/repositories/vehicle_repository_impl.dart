import '../datasources/vehicle_local_datasource.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleLocalDataSource _localDataSource;

  VehicleRepositoryImpl({required VehicleLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<Vehicle>> getActiveVehicles() async {
    return _localDataSource.getActiveVehicles();
  }

  @override
  Future<Vehicle?> getVehicleById(int id) async {
    return _localDataSource.getVehicleById(id);
  }

  @override
  Future<List<Vehicle>> searchVehicles(String query) async {
    return _localDataSource.searchVehicles(query);
  }

  @override
  Future<List<Vehicle>> getVehiclesByPartyId(int partyId) async {
    return _localDataSource.getVehiclesByPartyId(partyId);
  }
}
