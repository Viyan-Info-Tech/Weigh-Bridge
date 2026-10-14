import '../entities/vehicle_tare_record.dart';
import '../repositories/vehicle_tare_repository.dart';

/// Persists one per-vehicle tare record from the Auto Tare popup.
///
/// Re-adding a vehicle updates its tare instead of duplicating the row.
/// This never creates a weighment or a bill.
class SaveVehicleTareUseCase {
  final VehicleTareRepository _repository;

  SaveVehicleTareUseCase(this._repository);

  Future<VehicleTareRecord> call({
    required String vehicleNumber,
    required double tareKg,
  }) {
    return _repository.saveVehicleTare(
      vehicleNumber: vehicleNumber,
      tareKg: tareKg,
    );
  }
}
