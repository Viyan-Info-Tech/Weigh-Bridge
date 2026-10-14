import '../../domain/entities/vehicle_tare_record.dart';
import '../../domain/repositories/vehicle_tare_repository.dart';
import '../datasources/vehicle_tare_local_datasource.dart';

class VehicleTareRepositoryImpl implements VehicleTareRepository {
  final VehicleTareLocalDataSource localDataSource;

  VehicleTareRepositoryImpl(this.localDataSource);

  @override
  Future<List<VehicleTareRecord>> loadVehicleTares() =>
      localDataSource.loadVehicleTares();

  @override
  Future<VehicleTareRecord> saveVehicleTare({
    required String vehicleNumber,
    required double tareKg,
  }) {
    return localDataSource.saveVehicleTare(
      vehicleNumber: vehicleNumber,
      tareKg: tareKg,
    );
  }

  @override
  Future<void> deleteVehicleTare(String vehicleNumber) {
    return localDataSource.deleteVehicleTare(vehicleNumber);
  }
}
