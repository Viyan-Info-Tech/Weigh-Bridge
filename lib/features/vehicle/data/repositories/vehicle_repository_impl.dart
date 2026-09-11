import '../datasources/vehicle_local_datasource.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleLocalDataSource _localDataSource;

  VehicleRepositoryImpl({required VehicleLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<Vehicle>> getAllVehicles() => _localDataSource.getAllVehicles();

  @override
  Future<List<Vehicle>> getVehiclesByStatus({required bool isActive}) =>
      _localDataSource.getVehiclesByStatus(isActive: isActive);

  @override
  Future<Vehicle?> getVehicleById(int id) => _localDataSource.getVehicleById(id);

  @override
  Future<Vehicle?> getVehicleByNumber(String number) => _localDataSource.getVehicleByNumber(number);

  @override
  Future<List<Vehicle>> getVehiclesByPartyId(int partyId) => _localDataSource.getVehiclesByPartyId(partyId);

  @override
  Future<int> createVehicle({
    required String vehicleNumber,
    required int partyId,
    String? vehicleType,
    String? driverName,
    String? driverPhone,
    double? tareWeight,
  }) =>
      _localDataSource.insertVehicle(
        vehicleNumber: vehicleNumber,
        partyId: partyId,
        vehicleType: vehicleType,
        driverName: driverName,
        driverPhone: driverPhone,
        tareWeight: tareWeight,
      );

  @override
  Future<bool> updateVehicle({
    required int id,
    required String vehicleNumber,
    required int partyId,
    String? vehicleType,
    String? driverName,
    String? driverPhone,
    double? tareWeight,
  }) =>
      _localDataSource.updateVehicle(
        id: id,
        vehicleNumber: vehicleNumber,
        partyId: partyId,
        vehicleType: vehicleType,
        driverName: driverName,
        driverPhone: driverPhone,
        tareWeight: tareWeight,
      );

  @override
  Future<void> deactivateVehicle(int id) => _localDataSource.deactivateVehicle(id);

  @override
  Future<List<Vehicle>> searchVehicles(String query) => _localDataSource.searchVehicles(query);
}
