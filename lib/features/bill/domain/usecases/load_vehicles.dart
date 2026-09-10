import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class LoadVehiclesUseCase {
  final VehicleRepository _repository;

  LoadVehiclesUseCase(this._repository);

  Future<List<Vehicle>> call() async {
    return _repository.getActiveVehicles();
  }
}

class SearchVehiclesUseCase {
  final VehicleRepository _repository;

  SearchVehiclesUseCase(this._repository);

  Future<List<Vehicle>> call(String query) async {
    return _repository.searchVehicles(query);
  }
}

class LoadVehiclesByPartyUseCase {
  final VehicleRepository _repository;

  LoadVehiclesByPartyUseCase(this._repository);

  Future<List<Vehicle>> call(int partyId) async {
    return _repository.getVehiclesByPartyId(partyId);
  }
}
