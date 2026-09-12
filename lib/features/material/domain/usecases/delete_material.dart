import '../repositories/material_item_repository.dart';

class DeleteMaterialUseCase {
  final MaterialItemRepository _repository;

  DeleteMaterialUseCase(this._repository);

  Future<void> call(int materialId) async {
    await _repository.deleteMaterial(materialId);
  }
}
