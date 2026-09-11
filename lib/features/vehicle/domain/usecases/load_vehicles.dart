import '../repositories/vehicle_repository.dart';
import '../../domain/entities/vehicle.dart';

class LoadVehiclesUseCase {
  final VehicleRepository _repository;

  LoadVehiclesUseCase(this._repository);

  Future<List<Vehicle>> call({bool? isActive}) async {
    if (isActive != null) {
      return _repository.getVehiclesByStatus(isActive: isActive);
    }
    return _repository.getAllVehicles();
  }
}
