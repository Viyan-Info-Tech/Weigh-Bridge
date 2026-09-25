import '../entities/material_item.dart';

abstract class MaterialItemRepository {
  Future<List<MaterialItem>> getAllMaterials();
  Future<List<MaterialItem>> getMaterialsByStatus({required bool isActive});
  Future<MaterialItem?> getMaterialById(int id);
  Future<MaterialItem?> getMaterialByCode(String code);
  Future<MaterialItem?> getMaterialByName(String name);
  Future<int> createMaterial({required String code, required String name});
  Future<bool> updateMaterial({
    required int id,
    required String code,
    required String name,
  });
  Future<void> deactivateMaterial(int id);
  Future<void> activateMaterial(int id);
  Future<void> deleteMaterial(int id);
  Future<List<MaterialItem>> searchMaterials(String query);
}
