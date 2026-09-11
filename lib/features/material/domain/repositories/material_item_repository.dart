import '../entities/material_item.dart';

abstract class MaterialItemRepository {
  Future<List<MaterialItem>> getAllMaterials();
  Future<List<MaterialItem>> getMaterialsByStatus({required bool isActive});
  Future<List<MaterialItem>> getMaterialsByCategory(String category);
  Future<MaterialItem?> getMaterialById(int id);
  Future<int> createMaterial({
    required String name,
    String? category,
    String unit = 'ton',
    double defaultRate = 0,
  });
  Future<bool> updateMaterial({
    required int id,
    required String name,
    String? category,
    String unit = 'ton',
    double defaultRate = 0,
  });
  Future<void> deactivateMaterial(int id);
  Future<List<MaterialItem>> searchMaterials(String query);
}
