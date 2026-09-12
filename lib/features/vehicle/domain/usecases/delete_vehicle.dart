import '../repositories/vehicle_repository.dart';

class DeleteVehicleUseCase {
  final VehicleRepository _repository;

  DeleteVehicleUseCase(this._repository);

  Future<void> call(int vehicleId) async {
    await _repository.deleteVehicle(vehicleId);
  }
}
