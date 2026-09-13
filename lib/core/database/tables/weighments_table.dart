import 'package:drift/drift.dart';

import 'parties_table.dart';
import 'vehicles_table.dart';
import 'materials_table.dart';

class Weighments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get billNumber => text().withLength(min: 1, max: 20).unique()();
  IntColumn get partyId => integer().references(Parties, #id)();
  IntColumn get vehicleId => integer().references(Vehicles, #id)();
  IntColumn get materialId => integer().references(Materials, #id)();
  TextColumn get paymentMode => text().withLength(min: 1, max: 20)();
  RealColumn get firstWeightKg => real()();
  TextColumn get firstWeightType => text().withLength(min: 1, max: 20).withDefault(const Constant('GROSS'))();
  RealColumn get secondWeightKg => real().nullable()();
  TextColumn get secondWeightType => text().withLength(min: 1, max: 20).nullable()();
  RealColumn get netWeightKg => real().nullable()();
  RealColumn get vehicleCharge => real().withDefault(const Constant(0))();
  RealColumn get amount => real().withDefault(const Constant(0))();
  TextColumn get remarks => text().withLength(min: 0, max: 500).nullable()();
  TextColumn get status => text().withLength(min: 1, max: 20).withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
