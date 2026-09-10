import '../entities/material.dart';
import '../repositories/material_repository.dart';

class LoadMaterialsUseCase {
  final MaterialRepository _repository;

  LoadMaterialsUseCase(this._repository);

  Future<List<Material>> call() async {
    return _repository.getActiveMaterials();
  }
}

class SearchMaterialsUseCase {
  final MaterialRepository _repository;

  SearchMaterialsUseCase(this._repository);

  Future<List<Material>> call(String query) async {
    return _repository.searchMaterials(query);
  }
}
