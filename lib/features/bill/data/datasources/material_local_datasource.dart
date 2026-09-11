import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide Material;
import '../../domain/entities/material.dart';

class MaterialLocalDataSource {
  final AppDatabase _database;

  MaterialLocalDataSource(this._database);

  Future<List<Material>> getAllMaterials() async {
    final records = await _database.materialDao.getAllMaterials();
    return records.map(_toEntity).toList();
  }

  Future<List<Material>> getAllActiveMaterials() async {
    final records = await _database.materialDao.getAllActiveMaterials();
    return records.map(_toEntity).toList();
  }

  Future<List<Material>> getMaterialsByStatus({required bool isActive}) async {
    final records = await _database.materialDao.getMaterialsByStatus(isActive: isActive);
    return records.map(_toEntity).toList();
  }

  Future<List<Material>> getMaterialsByCategory(String category) async {
    final records = await _database.materialDao.getMaterialsByCategory(category);
    return records.map(_toEntity).toList();
  }

  Future<Material?> getMaterialById(int id) async {
    final record = await _database.materialDao.getMaterialById(id);
    return record != null ? _toEntity(record) : null;
  }

  Future<Material?> getMaterialByName(String name) async {
    final record = await _database.materialDao.getMaterialByName(name);
    return record != null ? _toEntity(record) : null;
  }

  Future<int> insertMaterial({
    required String name,
    String? category,
    String unit = 'ton',
    double defaultRate = 0,
  }) async {
    return _database.materialDao.insertMaterial(MaterialsCompanion(
      name: Value(name),
      category: Value(category),
      unit: Value(unit),
      defaultRate: Value(defaultRate),
    ));
  }

  Future<bool> updateMaterial({
    required int id,
    required String name,
    String? category,
    String unit = 'ton',
    double defaultRate = 0,
  }) async {
    return _database.materialDao.updateMaterial(MaterialsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      unit: Value(unit),
      defaultRate: Value(defaultRate),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deactivateMaterial(int id) async {
    await _database.materialDao.deactivateMaterial(id);
  }

  Future<List<Material>> searchMaterials(String query) async {
    final records = await _database.materialDao.searchMaterials(query);
    return records.map(_toEntity).toList();
  }

  Material _toEntity(dynamic record) {
    return Material(
      id: record.id,
      name: record.name,
      category: record.category,
      unit: record.unit,
      defaultRate: record.defaultRate,
      isActive: record.isActive,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
