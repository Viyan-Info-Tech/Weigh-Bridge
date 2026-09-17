import '../entities/material_item.dart';

abstract class MaterialItemRepository {
  Future<List<MaterialItem>> getAllMaterials();
  Future<List<MaterialItem>> getMaterialsByStatus({required bool isActive});
  Future<List<MaterialItem>> getMaterialsByCategory(String category);
  Future<MaterialItem?> getMaterialById(int id);
  Future<int> createMaterial({required String name, String? category});
  Future<bool> updateMaterial({
    required int id,
    required String name,
    String? category,
  });
  Future<void> deactivateMaterial(int id);
  Future<void> activateMaterial(int id);
  Future<void> deleteMaterial(int id);
  Future<List<MaterialItem>> searchMaterials(String query);
}
