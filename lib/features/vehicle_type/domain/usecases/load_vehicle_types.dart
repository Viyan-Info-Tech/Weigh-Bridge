import '../repositories/vehicle_type_repository.dart';
import '../../domain/entities/vehicle_type.dart';

class LoadVehicleTypesUseCase {
  final VehicleTypeRepository _repository;

  LoadVehicleTypesUseCase(this._repository);

  Future<List<VehicleType>> call({bool? isActive}) async {
    if (isActive != null) {
      return _repository.getVehicleTypesByStatus(isActive: isActive);
    }
    return _repository.getAllVehicleTypes();
  }
}
