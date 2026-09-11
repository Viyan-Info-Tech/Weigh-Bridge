import '../repositories/vehicle_type_repository.dart';

class CreateVehicleTypeUseCase {
  final VehicleTypeRepository _repository;

  CreateVehicleTypeUseCase(this._repository);

  Future<int> call({
    required String name,
    double emptyPrice = 0,
    double loadPrice = 0,
  }) async {
    final existing = await _repository.searchVehicleTypes(name);
    if (existing.any((vt) => vt.name.toLowerCase() == name.toLowerCase())) {
      throw Exception('Vehicle type with this name already exists');
    }
    return _repository.createVehicleType(
      name: name,
      emptyPrice: emptyPrice,
      loadPrice: loadPrice,
    );
  }
}
