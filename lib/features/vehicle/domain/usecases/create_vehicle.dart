import '../repositories/vehicle_repository.dart';

class CreateVehicleUseCase {
  final VehicleRepository _repository;

  CreateVehicleUseCase(this._repository);

  Future<int> call({
    required String vehicleNumber,
    required int partyId,
    String? vehicleType,
    String? driverName,
    String? driverPhone,
    double? tareWeight,
  }) async {
    final existing = await _repository.getVehicleByNumber(vehicleNumber);
    if (existing != null) {
      throw Exception('Vehicle with this number already exists');
    }
    return _repository.createVehicle(
      vehicleNumber: vehicleNumber,
      partyId: partyId,
      vehicleType: vehicleType,
      driverName: driverName,
      driverPhone: driverPhone,
      tareWeight: tareWeight,
    );
  }
}
