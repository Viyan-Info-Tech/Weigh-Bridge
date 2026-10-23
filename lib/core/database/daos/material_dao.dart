import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/materials_table.dart';
import '../tables/weighments_table.dart';

part 'material_dao.g.dart';

/// CRUD + safeguards for the material master (name + Empty/Load type).
@DriftAccessor(tables: [Materials, Weighments])
class MaterialDao extends DatabaseAccessor<AppDatabase>
    with _$MaterialDaoMixin {
  MaterialDao(super.db);

  /// Every material, active first, then by name so the weighment dropdown
  /// and the management table share one stable order.
  Future<List<Material>> getAllMaterials() async {
    final query = select(materials)
      ..orderBy([
        (m) => OrderingTerm.desc(m.isActive),
        (m) => OrderingTerm.asc(m.name),
        (m) => OrderingTerm.asc(m.vehicleType),
      ]);
    return query.get();
  }

  /// Only active materials - what the weighment form dropdown offers.
  Future<List<Material>> getAllActiveMaterials() async {
    final query = select(materials)
      ..where((m) => m.isActive.equals(true))
      ..orderBy([
        (m) => OrderingTerm.asc(m.name),
        (m) => OrderingTerm.asc(m.vehicleType),
      ]);
    return query.get();
  }

  Future<List<Material>> getMaterialsByStatus({required bool isActive}) async {
    final query = select(materials)
      ..where((m) => m.isActive.equals(isActive))
      ..orderBy([
        (m) => OrderingTerm.asc(m.name),
        (m) => OrderingTerm.asc(m.vehicleType),
      ]);
    return query.get();
  }

  Future<Material?> getMaterialById(int id) {
    return (select(materials)..where((m) => m.id.equals(id))).getSingleOrNull();
  }

  /// Exact (case-insensitive) name + vehicle-type combination lookup.
  Future<Material?> getMaterialByNameAndType(
    String name,
    String vehicleType,
  ) async {
    final result = await customSelect(
      'SELECT id FROM materials '
      'WHERE lower(trim(name)) = lower(trim(?)) '
      'AND lower(trim(vehicle_type)) = lower(trim(?)) LIMIT 1',
      variables: [Variable.withString(name), Variable.withString(vehicleType)],
    ).getSingleOrNull();
    return result == null ? null : getMaterialById(result.read<int>('id'));
  }

  /// Inserts a material, rejecting duplicate name/type combinations.
  Future<int> insertMaterial(MaterialsCompanion entry) async {
    final name = entry.name.value.trim();
    final vehicleType = entry.vehicleType.value.trim();
    if (await getMaterialByNameAndType(name, vehicleType) != null) {
      throw Exception('Material "$name - $vehicleType" already exists.');
    }
    return into(materials).insert(entry);
  }

  /// Updates a material, rejecting duplicate name/type combinations on
  /// other rows.
  Future<bool> updateMaterial(MaterialsCompanion entry) async {
    final id = entry.id.value;
    final name = entry.name.value.trim();
    final vehicleType = entry.vehicleType.value.trim();
    final duplicate = await getMaterialByNameAndType(name, vehicleType);
    if (duplicate != null && duplicate.id != id) {
      throw Exception('Material "$name - $vehicleType" already exists.');
    }
    return update(materials).replace(entry);
  }

  /// Number of saved weighments referencing [materialId].
  ///
  /// Historical bills keep a denormalised material snapshot, but the id
  /// link is what delete protection is based on.
  Future<int> countWeighmentsUsing(int materialId) async {
    final countColumn = weighments.id.count();
    final query = selectOnly(weighments)
      ..addColumns([countColumn])
      ..where(weighments.materialId.equals(materialId));
    final row = await query.getSingle();
    return row.read(countColumn) ?? 0;
  }

  Future<bool> isMaterialInUse(int materialId) async {
    return await countWeighmentsUsing(materialId) > 0;
  }

  Future<void> deactivateMaterial(int id) async {
    await (update(materials)..where((m) => m.id.equals(id))).write(
      MaterialsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> activateMaterial(int id) async {
    await (update(materials)..where((m) => m.id.equals(id))).write(
      MaterialsCompanion(
        isActive: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a material only when no weighment references it.
  ///
  /// Throws when the material is in use so historical weighments can never
  /// lose their master reference behind the operator's back; the UI offers
  /// deactivation as the safe alternative.
  Future<int> deleteMaterial(int id) async {
    if (await isMaterialInUse(id)) {
      throw Exception(
        'This material is used by existing weighments and cannot be deleted. '
        'Deactivate it instead.',
      );
    }
    return (delete(materials)..where((m) => m.id.equals(id))).go();
  }

  Future<List<Material>> searchMaterials(String query) async {
    final q = select(materials)
      ..where((m) => m.name.like('%$query%') | m.vehicleType.like('%$query%'))
      ..orderBy([
        (m) => OrderingTerm.desc(m.isActive),
        (m) => OrderingTerm.asc(m.name),
      ]);
    return q.get();
  }
}
