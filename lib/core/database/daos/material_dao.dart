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

  Future<Material?> getMaterialById(int id) async {
    final query = select(materials)..where((m) => m.id.equals(id));
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
      ..where((m) => m.name.like('%$query%') & m.isActive.equals(true))
      ..limit(20);
    return q.get();
  }
}
