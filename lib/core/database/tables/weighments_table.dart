import 'package:drift/drift.dart';

class Weighments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get billNumber => text().withLength(min: 1, max: 20).unique()();
  TextColumn get vehicleNumber => text().withLength(min: 1, max: 30)();
  RealColumn get firstWeightKg => real()();
  TextColumn get firstWeightType =>
      text().withLength(min: 1, max: 20).withDefault(const Constant('GROSS'))();
  RealColumn get secondWeightKg => real().nullable()();
  TextColumn get secondWeightType =>
      text().withLength(min: 1, max: 20).nullable()();
  RealColumn get netWeightKg => real().nullable()();
  TextColumn get material => text().withLength(min: 0, max: 100).nullable()();
  TextColumn get description => text().withLength(min: 0, max: 500).nullable()();
  TextColumn get remarks => text().withLength(min: 0, max: 500).nullable()();
  TextColumn get mobileNumber =>
      text().withLength(min: 0, max: 20).nullable()();
  TextColumn get weightUnit =>
      text().withLength(min: 1, max: 10).withDefault(const Constant('ton'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
