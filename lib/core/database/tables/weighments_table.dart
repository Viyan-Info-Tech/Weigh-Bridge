import 'package:drift/drift.dart';

import 'customers_table.dart';
import 'materials_table.dart';

class Weighments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get billNumber => text().withLength(min: 1, max: 20).unique()();
  IntColumn get customerId => integer().references(Customers, #id)();
  TextColumn get vehicleNumber => text().withLength(min: 1, max: 30)();

  /// Nullable because a tare-only weighment (tare captured, no gross) has no
  /// net weight and therefore nothing to price against a material. Gross
  /// weighments still always carry one; that is enforced by the form rules in
  /// `BillBloc`, not by this column.
  IntColumn get materialId => integer().references(Materials, #id).nullable()();
  TextColumn get paymentMode => text().withLength(min: 1, max: 20)();
  RealColumn get firstWeightKg => real()();
  TextColumn get firstWeightType =>
      text().withLength(min: 1, max: 20).withDefault(const Constant('GROSS'))();
  RealColumn get secondWeightKg => real().nullable()();
  TextColumn get secondWeightType =>
      text().withLength(min: 1, max: 20).nullable()();
  RealColumn get netWeightKg => real().nullable()();
  RealColumn get vehicleCharge => real().withDefault(const Constant(0))();
  RealColumn get amount => real().withDefault(const Constant(0))();
  TextColumn get remarks => text().withLength(min: 0, max: 500).nullable()();
  TextColumn get weightUnit =>
      text().withLength(min: 1, max: 10).withDefault(const Constant('ton'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
