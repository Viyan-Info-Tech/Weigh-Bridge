import '../repositories/material_item_repository.dart';
import '../entities/material_item.dart';

class LoadMaterialsUseCase {
  final MaterialItemRepository _repository;

  LoadMaterialsUseCase(this._repository);

  Future<List<MaterialItem>> call({bool? isActive, String? category}) async {
    if (category != null) {
      return _repository.getMaterialsByCategory(category);
    }
    if (isActive != null) {
      return _repository.getMaterialsByStatus(isActive: isActive);
    }
    return _repository.getAllMaterials();
  }
}
