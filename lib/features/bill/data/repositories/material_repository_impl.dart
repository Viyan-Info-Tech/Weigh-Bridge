import '../datasources/material_local_datasource.dart';
import '../../domain/entities/material.dart';
import '../../domain/repositories/material_repository.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  final MaterialLocalDataSource _localDataSource;

  MaterialRepositoryImpl({required MaterialLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<Material>> getActiveMaterials() async {
    return _localDataSource.getActiveMaterials();
  }

  @override
  Future<Material?> getMaterialById(int id) async {
    return _localDataSource.getMaterialById(id);
  }

  @override
  Future<List<Material>> searchMaterials(String query) async {
    return _localDataSource.searchMaterials(query);
  }
}
