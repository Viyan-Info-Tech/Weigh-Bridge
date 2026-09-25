import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/materials_table.dart';

part 'material_dao.g.dart';

@DriftAccessor(tables: [Materials])
class MaterialDao extends DatabaseAccessor<AppDatabase>
    with _$MaterialDaoMixin {
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

  Future<Material?> getMaterialById(int id) async {
    final query = select(materials)..where((m) => m.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<Material?> getMaterialByCode(String code) async {
    final query = select(materials)
      ..where((m) => m.code.equals(code.trim()));
    return query.getSingleOrNull();
  }

  Future<Material?> getMaterialByName(String name) async {
    final result = await customSelect(
      'SELECT id FROM materials WHERE lower(trim(name)) = lower(trim(?)) LIMIT 1',
      variables: [Variable.withString(name)],
    ).getSingleOrNull();
    return result == null ? null : getMaterialById(result.read<int>('id'));
  }

  Future<int> insertMaterial(MaterialsCompanion entry) async {
    final code = entry.code.value.trim();
    final name = entry.name.value.trim();
    if (await getMaterialByCode(code) != null) {
      throw Exception('Material code "$code" already exists.');
    }
    if (await getMaterialByName(name) != null) {
      throw Exception('Material name "$name" already exists.');
    }
    return into(materials).insert(entry);
  }

  Future<bool> updateMaterial(MaterialsCompanion entry) async {
    final id = entry.id.value;
    final code = entry.code.value.trim();
    final name = entry.name.value.trim();
    final duplicateCode = await getMaterialByCode(code);
    if (duplicateCode != null && duplicateCode.id != id) {
      throw Exception('Material code "$code" already exists.');
    }
    final duplicateName = await getMaterialByName(name);
    if (duplicateName != null && duplicateName.id != id) {
      throw Exception('Material name "$name" already exists.');
    }
    return update(materials).replace(entry);
  }

  Future<List<Material>> searchMaterials(String query) async {
    final q = select(materials)
      ..where((m) => m.code.like('%$query%') | m.name.like('%$query%'))
      ..limit(20);
    return q.get();
  }

  Future<void> deactivateMaterial(int id) async {
    final now = DateTime.now();
    await (update(materials)..where((m) => m.id.equals(id))).write(
      MaterialsCompanion(isActive: const Value(false), updatedAt: Value(now)),
    );
  }

  Future<void> activateMaterial(int id) async {
    final now = DateTime.now();
    await (update(materials)..where((m) => m.id.equals(id))).write(
      MaterialsCompanion(isActive: const Value(true), updatedAt: Value(now)),
    );
  }

  Future<int> deleteMaterial(int id) async {
    return await (delete(materials)..where((m) => m.id.equals(id))).go();
  }
}
