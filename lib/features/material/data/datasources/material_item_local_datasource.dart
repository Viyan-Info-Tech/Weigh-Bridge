import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide Material;
import '../../domain/entities/material_item.dart';

class MaterialItemLocalDataSource {
  final AppDatabase _database;

  MaterialItemLocalDataSource(this._database);

  Future<List<MaterialItem>> getAllMaterials() async {
    final records = await _database.materialDao.getAllMaterials();
    return records.map(_toEntity).toList();
  }

  Future<List<MaterialItem>> getMaterialsByStatus({
    required bool isActive,
  }) async {
    final records = await _database.materialDao.getMaterialsByStatus(
      isActive: isActive,
    );
    return records.map(_toEntity).toList();
  }

  Future<List<MaterialItem>> getMaterialsByCategory(String category) async {
    final records = await _database.materialDao.getMaterialsByCategory(
      category,
    );
    return records.map(_toEntity).toList();
  }

  Future<MaterialItem?> getMaterialById(int id) async {
    final record = await _database.materialDao.getMaterialById(id);
    return record != null ? _toEntity(record) : null;
  }

  Future<int> insertMaterial({
    required String name,
    String? category,
    bool isActive = true,
  }) async {
    final now = DateTime.now();
    return _database.materialDao.insertMaterial(
      MaterialsCompanion(
        name: Value(name),
        category: Value(category),
        isActive: Value(isActive),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<bool> updateMaterial({
    required int id,
    required String name,
    String? category,
  }) async {
    return _database.materialDao.updateMaterial(
      MaterialsCompanion(
        id: Value(id),
        name: Value(name),
        category: Value(category),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deactivateMaterial(int id) async {
    await _database.materialDao.deactivateMaterial(id);
  }

  Future<void> activateMaterial(int id) async {
    await _database.materialDao.activateMaterial(id);
  }

  Future<void> deleteMaterial(int id) async {
    await _database.materialDao.deleteMaterial(id);
  }

  Future<List<MaterialItem>> searchMaterials(String query) async {
    final records = await _database.materialDao.searchMaterials(query);
    return records.map(_toEntity).toList();
  }

  MaterialItem _toEntity(dynamic record) {
    return MaterialItem(
      id: record.id,
      name: record.name,
      category: record.category,
      isActive: record.isActive,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
