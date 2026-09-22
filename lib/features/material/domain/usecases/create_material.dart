import '../repositories/material_item_repository.dart';

class CreateMaterialUseCase {
  final MaterialItemRepository _repository;

  CreateMaterialUseCase(this._repository);

  Future<int> call({required String code, required String name}) async {
    final existing = await _repository.getMaterialByCode(code);
    if (existing != null) {
      throw Exception('Material with this code already exists');
    }
    return _repository.createMaterial(code: code, name: name);
  }
}
