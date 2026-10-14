import '../repositories/vehicle_tare_repository.dart';

/// Removes one per-vehicle tare record, used when a record's vehicle number
/// itself is edited (the renamed record is saved as new, the old row is
/// removed). Never touches weighments or bills.
class DeleteVehicleTareUseCase {
  final VehicleTareRepository _repository;

  DeleteVehicleTareUseCase(this._repository);

  Future<void> call(String vehicleNumber) {
    return _repository.deleteVehicleTare(vehicleNumber);
  }
}
