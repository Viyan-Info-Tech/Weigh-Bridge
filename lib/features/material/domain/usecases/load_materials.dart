import '../entities/material_item.dart';
import '../repositories/material_repository.dart';

class LoadMaterials {
  final MaterialRepository repository;

  const LoadMaterials(this.repository);

  Future<List<MaterialItem>> call() => repository.getAll();
}
