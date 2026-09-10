import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' hide Material;
import '../../domain/entities/material.dart';

class MaterialLocalDataSource {
  final AppDatabase _database;

  MaterialLocalDataSource(this._database);

  Future<List<Material>> getActiveMaterials() async {
    final records = await _database.materialDao.getAllActiveMaterials();
    return records.map(_toEntity).toList();
  }

  Future<Material?> getMaterialById(int id) async {
    final record = await _database.materialDao.getMaterialById(id);
    if (record == null) return null;
    return _toEntity(record);
  }

  Future<List<Material>> searchMaterials(String query) async {
    final records = await _database.materialDao.searchMaterials(query);
    return records.map(_toEntity).toList();
  }

  Future<int> insertMaterial(String name, {String unit = 'ton', double defaultRate = 0}) async {
    return _database.materialDao.insertMaterial(
      MaterialsCompanion.insert(
        name: name,
        unit: Value(unit),
        defaultRate: Value(defaultRate),
      ),
    );
  }

  Material _toEntity(dynamic record) {
    return Material(
      id: record.id,
      name: record.name,
      unit: record.unit,
      defaultRate: record.defaultRate,
      isActive: record.isActive,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
