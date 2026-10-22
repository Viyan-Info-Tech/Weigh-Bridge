import '../../domain/entities/material_item.dart';
import '../../domain/repositories/material_repository.dart';
import '../datasources/material_local_datasource.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  final MaterialLocalDataSource localDataSource;

  MaterialRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MaterialItem>> getAll() => localDataSource.getAllMaterials();

  @override
  Future<List<MaterialItem>> getActive() =>
      localDataSource.getActiveMaterials();

  @override
  Future<MaterialItem> getById(int id) async {
    final material = await localDataSource.getMaterialById(id);
    if (material == null) {
      throw StateError('Material $id not found');
    }
    return material;
  }

  @override
  Future<int> createMaterial(String name, String vehicleType) async {
    _validate(name, vehicleType);
    final trimmedName = name.trim();
    final trimmedType = vehicleType.trim();
    final existing = await localDataSource.getMaterialByNameAndType(
      trimmedName,
      trimmedType,
    );
    if (existing != null) {
      throw DuplicateMaterialException(
        'Material "$trimmedName - $trimmedType" already exists.',
      );
    }
    return localDataSource.insertMaterial(
      name: trimmedName,
      vehicleType: trimmedType,
    );
  }

  @override
  Future<void> updateMaterial(
    int id,
    String name,
    String vehicleType,
    bool isActive,
  ) async {
    _validate(name, vehicleType);
    final trimmedName = name.trim();
    final trimmedType = vehicleType.trim();
    final existing = await localDataSource.getMaterialByNameAndType(
      trimmedName,
      trimmedType,
    );
    if (existing != null && existing.id != id) {
      throw DuplicateMaterialException(
        'Material "$trimmedName - $trimmedType" already exists.',
      );
    }
    await localDataSource.updateMaterial(
      id: id,
      name: trimmedName,
      vehicleType: trimmedType,
    );
    // Keep the active flag in sync with the requested state.
    await setActive(id, isActive);
  }

  @override
  Future<void> setActive(int id, bool isActive) => isActive
      ? localDataSource.activateMaterial(id)
      : localDataSource.deactivateMaterial(id);

  @override
  Future<int> countWeighmentsUsing(int materialId) =>
      localDataSource.countWeighmentsUsing(materialId);

  @override
  Future<void> deleteMaterial(int id) async {
    if (await localDataSource.countWeighmentsUsing(id) > 0) {
      throw const MaterialInUseException(
        'This material is used by existing weighments and cannot be deleted. '
        'Deactivate it instead.',
      );
    }
    await localDataSource.deleteMaterial(id);
  }

  void _validate(String name, String vehicleType) {
    if (name.trim().isEmpty) {
      throw const InvalidMaterialException('Material name cannot be empty.');
    }
    if (vehicleType.trim() != 'Empty' && vehicleType.trim() != 'Load') {
      throw const InvalidMaterialException(
        'Vehicle type must be either Empty or Load.',
      );
    }
  }
}
