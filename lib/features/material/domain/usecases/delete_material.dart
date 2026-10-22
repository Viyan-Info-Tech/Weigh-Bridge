import '../repositories/material_repository.dart';

class DeleteMaterial {
  final MaterialRepository repository;

  const DeleteMaterial(this.repository);

  Future<void> call(int id) => repository.deleteMaterial(id);
}
