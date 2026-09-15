import '../datasources/material_item_local_datasource.dart';
import '../../domain/entities/material_item.dart';
import '../../domain/repositories/material_item_repository.dart';

class MaterialItemRepositoryImpl implements MaterialItemRepository {
  final MaterialItemLocalDataSource _localDataSource;

  MaterialItemRepositoryImpl({
    required MaterialItemLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<List<MaterialItem>> getAllMaterials() =>
      _localDataSource.getAllMaterials();

  @override
  Future<List<MaterialItem>> getMaterialsByStatus({required bool isActive}) =>
      _localDataSource.getMaterialsByStatus(isActive: isActive);

  @override
  Future<List<MaterialItem>> getMaterialsByCategory(String category) =>
      _localDataSource.getMaterialsByCategory(category);

  @override
  Future<MaterialItem?> getMaterialById(int id) =>
      _localDataSource.getMaterialById(id);

  @override
  Future<int> createMaterial({required String name, String? category}) =>
      _localDataSource.insertMaterial(name: name, category: category);

  @override
  Future<bool> updateMaterial({
    required int id,
    required String name,
    String? category,
  }) => _localDataSource.updateMaterial(id: id, name: name, category: category);

  @override
  Future<void> deactivateMaterial(int id) =>
      _localDataSource.deactivateMaterial(id);

  @override
  Future<void> deleteMaterial(int id) => _localDataSource.deleteMaterial(id);

  @override
  Future<List<MaterialItem>> searchMaterials(String query) =>
      _localDataSource.searchMaterials(query);
}
