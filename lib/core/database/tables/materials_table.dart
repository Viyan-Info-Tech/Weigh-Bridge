import 'package:drift/drift.dart';

/// The two fixed vehicle-type options a material can be registered with.
///
/// The values are the exact strings printed on bills (e.g. `Auto - Empty`),
/// so they must never be renamed without a data migration.
class MaterialVehicleTypes {
  const MaterialVehicleTypes._();

  static const String empty = 'Empty';
  static const String load = 'Load';

  /// Every selectable option, in display order.
  static const List<String> all = [empty, load];

  /// Whether [value] is one of the two allowed options (case-insensitive).
  static bool isValid(String value) => all.any(
    (option) => option.toLowerCase() == value.trim().toLowerCase(),
  );

  /// Returns the canonical casing for [value], or `null` when invalid.
  static String? normalize(String value) {
    for (final option in all) {
      if (option.toLowerCase() == value.trim().toLowerCase()) return option;
    }
    return null;
  }
}

/// Material master: a material name paired with a vehicle type (Empty/Load).
///
/// The same name may exist once per vehicle type (`Auto - Empty` and
/// `Auto - Load`), enforced by a unique index over
/// `lower(trim(name)) + lower(trim(vehicle_type))`.
class Materials extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// One of [MaterialVehicleTypes.all]: `Empty` or `Load`.
  TextColumn get vehicleType => text().withLength(min: 1, max: 20)();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
