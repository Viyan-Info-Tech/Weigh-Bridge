import '../repositories/material_item_repository.dart';

class CreateMaterialUseCase {
  final MaterialItemRepository _repository;

  CreateMaterialUseCase(this._repository);

  Future<int> call({required String name, String? category}) async {
    final existing = await _repository.searchMaterials(name);
    if (existing.any((m) => m.name.toLowerCase() == name.toLowerCase())) {
      throw Exception('Material with this name already exists');
    }
    return _repository.createMaterial(name: name, category: category);
  }
}
