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
  TextColumn get entryType => text().withLength(min: 1, max: 20)();
  TextColumn get paymentMode => text().withLength(min: 1, max: 20)();
  RealColumn get firstWeightKg => real()();
  RealColumn get secondWeightKg => real()();
  RealColumn get netWeightKg => real()();
  RealColumn get ratePerTon => real()();
  RealColumn get amount => real()();
  TextColumn get remarks => text().withLength(min: 0, max: 500).nullable()();
  TextColumn get status => text().withLength(min: 1, max: 20).withDefault(const Constant('completed'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
