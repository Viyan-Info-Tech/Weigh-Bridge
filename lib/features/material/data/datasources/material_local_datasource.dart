import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide Material;
import '../../domain/entities/material_item.dart';

class MaterialLocalDataSource {
  final AppDatabase _database;

  MaterialLocalDataSource(this._database);

  Future<List<MaterialItem>> getAllMaterials() async {
    final records = await _database.materialDao.getAllMaterials();
    return records.map(_toEntity).toList();
  }

  Future<List<MaterialItem>> getActiveMaterials() async {
    final records = await _database.materialDao.getAllActiveMaterials();
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

  Future<MaterialItem?> getMaterialById(int id) async {
    final record = await _database.materialDao.getMaterialById(id);
    return record != null ? _toEntity(record) : null;
  }

  Future<MaterialItem?> getMaterialByNameAndType(
    String name,
    String vehicleType,
  ) async {
    final record = await _database.materialDao.getMaterialByNameAndType(
      name,
      vehicleType,
    );
    return record != null ? _toEntity(record) : null;
  }

  Future<int> insertMaterial({
    required String name,
    required String vehicleType,
    bool isActive = true,
  }) async {
    final now = DateTime.now();
    return _database.materialDao.insertMaterial(
      MaterialsCompanion(
        name: Value(name.trim()),
        vehicleType: Value(vehicleType.trim()),
        isActive: Value(isActive),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<bool> updateMaterial({
    required int id,
    required String name,
    required String vehicleType,
  }) async {
    return _database.materialDao.updateMaterial(
      MaterialsCompanion(
        id: Value(id),
        name: Value(name.trim()),
        vehicleType: Value(vehicleType.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deactivateMaterial(int id) =>
      _database.materialDao.deactivateMaterial(id);

  Future<void> activateMaterial(int id) =>
      _database.materialDao.activateMaterial(id);

  Future<void> deleteMaterial(int id) =>
      _database.materialDao.deleteMaterial(id);

  Future<int> countWeighmentsUsing(int materialId) =>
      _database.materialDao.countWeighmentsUsing(materialId);

  Future<List<MaterialItem>> searchMaterials(String query) async {
    final records = await _database.materialDao.searchMaterials(query);
    return records.map(_toEntity).toList();
  }

  MaterialItem _toEntity(dynamic record) {
    return MaterialItem(
      id: record.id as int,
      name: record.name as String,
      vehicleType: record.vehicleType as String,
      isActive: record.isActive as bool,
      createdAt: record.createdAt as DateTime,
      updatedAt: record.updatedAt as DateTime,
    );
  }
}
