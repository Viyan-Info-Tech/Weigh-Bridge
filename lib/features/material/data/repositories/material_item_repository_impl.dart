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
  Future<MaterialItem?> getMaterialById(int id) =>
      _localDataSource.getMaterialById(id);

  @override
  Future<MaterialItem?> getMaterialByCode(String code) =>
      _localDataSource.getMaterialByCode(code);

  @override
  Future<MaterialItem?> getMaterialByName(String name) =>
      _localDataSource.getMaterialByName(name);

  @override
  Future<int> createMaterial({required String code, required String name}) =>
      _localDataSource.insertMaterial(code: code, name: name);

  @override
  Future<bool> updateMaterial({
    required int id,
    required String code,
    required String name,
  }) => _localDataSource.updateMaterial(id: id, code: code, name: name);

  @override
  Future<void> deactivateMaterial(int id) =>
      _localDataSource.deactivateMaterial(id);

  @override
  Future<void> activateMaterial(int id) =>
      _localDataSource.activateMaterial(id);

  @override
  Future<void> deleteMaterial(int id) => _localDataSource.deleteMaterial(id);

  @override
  Future<List<MaterialItem>> searchMaterials(String query) =>
      _localDataSource.searchMaterials(query);
}
