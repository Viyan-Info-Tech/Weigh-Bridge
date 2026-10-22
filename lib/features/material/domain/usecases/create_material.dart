import '../repositories/material_repository.dart';

class CreateMaterial {
  final MaterialRepository repository;

  const CreateMaterial(this.repository);

  Future<int> call(String name, String vehicleType) =>
      repository.createMaterial(name, vehicleType);
}
