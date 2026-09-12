import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/materials_table.dart';

part 'material_dao.g.dart';

@DriftAccessor(tables: [Materials])
class MaterialDao extends DatabaseAccessor<AppDatabase> with _$MaterialDaoMixin {
  MaterialDao(super.db);

  Future<List<Material>> getAllActiveMaterials() async {
    final query = select(materials)..where((m) => m.isActive.equals(true));
    return query.get();
  }

  Future<List<Material>> getAllMaterials() async {
    return select(materials).get();
  }

  Future<List<Material>> getMaterialsByStatus({required bool isActive}) async {
    final query = select(materials)..where((m) => m.isActive.equals(isActive));
    return query.get();
  }

  Future<List<Material>> getMaterialsByCategory(String category) async {
    final query = select(materials)
      ..where((m) => m.category.equals(category) & m.isActive.equals(true));
    return query.get();
  }

  Future<Material?> getMaterialById(int id) async {
    final query = select(materials)..where((m) => m.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<Material?> getMaterialByName(String name) async {
    final query = select(materials)..where((m) => m.name.equals(name));
    return query.getSingleOrNull();
  }

  Future<int> insertMaterial(MaterialsCompanion entry) async {
    return into(materials).insert(entry);
  }

  Future<bool> updateMaterial(MaterialsCompanion entry) async {
    return update(materials).replace(entry);
  }

  Future<List<Material>> searchMaterials(String query) async {
    final q = select(materials)
      ..where((m) =>
          m.name.like('%$query%') |
          m.category.like('%$query%'))
      ..limit(20);
    return q.get();
  }

  Future<void> deactivateMaterial(int id) async {
    final now = DateTime.now();
    await (update(materials)..where((m) => m.id.equals(id)))
        .write(MaterialsCompanion(
      isActive: const Value(false),
      updatedAt: Value(now),
    ));
  }

  Future<int> deleteMaterial(int id) async {
    return await (delete(materials)..where((m) => m.id.equals(id))).go();
  }
}
