import '../entities/material_item.dart';

/// Thrown when a material name + vehicle-type pair already exists.
class DuplicateMaterialException implements Exception {
  final String message;
  const DuplicateMaterialException(this.message);

  @override
  String toString() => message;
}

/// Thrown when a material cannot be deleted because weighments reference it.
class MaterialInUseException implements Exception {
  final String message;
  const MaterialInUseException(this.message);

  @override
  String toString() => message;
}

/// Thrown for invalid material input (empty name, bad vehicle type).
class InvalidMaterialException implements Exception {
  final String message;
  const InvalidMaterialException(this.message);

  @override
  String toString() => message;
}

abstract class MaterialRepository {
  /// Returns all materials (active and inactive), sorted by name.
  Future<List<MaterialItem>> getAll();

  /// Returns only active materials - the ones shown in the bill dropdown.
  Future<List<MaterialItem>> getActive();

  Future<MaterialItem> getById(int id);

  /// Creates a material and returns its new id.
  ///
  /// Throws [InvalidMaterialException] when the name is empty or the vehicle
  /// type is not Empty/Load, and [DuplicateMaterialException] when the same
  /// name + type pair already exists.
  Future<int> createMaterial(String name, String vehicleType);

  /// Updates a material's name, vehicle type and active flag.
  ///
  /// Throws the same exceptions as [createMaterial], except a name/type pair
  /// that only collides with this same row is allowed.
  Future<void> updateMaterial(
    int id,
    String name,
    String vehicleType,
    bool isActive,
  );

  /// Flips only the active flag, leaving name and type untouched.
  Future<void> setActive(int id, bool isActive);

  /// Number of saved weighments that reference [materialId].
  Future<int> countWeighmentsUsing(int materialId);

  /// Deletes a material.
  ///
  /// Throws [MaterialInUseException] when weighments still reference it -
  /// deactivation is the supported way to retire a used material.
  Future<void> deleteMaterial(int id);
}
