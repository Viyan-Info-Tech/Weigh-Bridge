import '../entities/material_item.dart';
import '../repositories/material_repository.dart';

class UpdateMaterial {
  final MaterialRepository repository;

  const UpdateMaterial(this.repository);

  Future<MaterialItem> call(MaterialItem material) async {
    await repository.updateMaterial(
      material.id!,
      material.name,
      material.vehicleType,
      material.isActive,
    );
    return repository.getById(material.id!);
  }
}
