import '../repositories/vehicle_type_repository.dart';

class DeleteVehicleTypeUseCase {
  final VehicleTypeRepository _repository;

  DeleteVehicleTypeUseCase(this._repository);

  Future<void> call(int vehicleTypeId) async {
    await _repository.deleteVehicleType(vehicleTypeId);
  }
}
