import '../entities/vehicle_tare_record.dart';
import '../repositories/vehicle_tare_repository.dart';

/// Loads every stored per-vehicle tare record for the Auto Tare popup table.
class LoadVehicleTaresUseCase {
  final VehicleTareRepository _repository;

  LoadVehicleTaresUseCase(this._repository);

  Future<List<VehicleTareRecord>> call() =>
      _repository.loadVehicleTares();
}
