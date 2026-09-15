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
  Future<Vehicle?> getVehicleById(int id) =>
      _localDataSource.getVehicleById(id);

  @override
  Future<Vehicle?> getVehicleByNumber(String number) =>
      _localDataSource.getVehicleByNumber(number);

  @override
  Future<int> createVehicle({
    required String vehicleNumber,
    required int vehicleTypeId,
    String? driverName,
    String? driverPhone,
  }) => _localDataSource.insertVehicle(
    vehicleNumber: vehicleNumber.trim().toUpperCase(),
    vehicleTypeId: vehicleTypeId,
    driverName: driverName,
    driverPhone: driverPhone,
  );

  @override
  Future<bool> updateVehicle({
    required int id,
    required String vehicleNumber,
    required int vehicleTypeId,
    String? driverName,
    String? driverPhone,
  }) => _localDataSource.updateVehicle(
    id: id,
    vehicleNumber: vehicleNumber.trim().toUpperCase(),
    vehicleTypeId: vehicleTypeId,
    driverName: driverName,
    driverPhone: driverPhone,
  );

  @override
  Future<void> deactivateVehicle(int id) =>
      _localDataSource.deactivateVehicle(id);

  @override
  Future<void> deleteVehicle(int id) => _localDataSource.deleteVehicle(id);

  @override
  Future<List<Vehicle>> searchVehicles(String query) =>
      _localDataSource.searchVehicles(query);
}
