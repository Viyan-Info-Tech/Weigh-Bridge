import '../entities/material.dart';

abstract class MaterialRepository {
  Future<List<Material>> getActiveMaterials();
  Future<Material?> getMaterialById(int id);
  Future<List<Material>> searchMaterials(String query);
}
