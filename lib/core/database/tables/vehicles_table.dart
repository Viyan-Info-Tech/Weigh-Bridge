import 'package:drift/drift.dart';

import 'parties_table.dart';

class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get vehicleNumber => text().withLength(min: 1, max: 30).unique()();
  IntColumn get partyId => integer().references(Parties, #id)();
  TextColumn get vehicleType => text().withLength(min: 0, max: 50).nullable()();
  TextColumn get driverName => text().withLength(min: 0, max: 100).nullable()();
  TextColumn get driverPhone => text().withLength(min: 0, max: 20).nullable()();
  RealColumn get tareWeight => real().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
