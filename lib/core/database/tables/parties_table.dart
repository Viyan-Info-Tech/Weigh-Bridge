import 'package:drift/drift.dart';

class Parties extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get contactPerson =>
      text().withLength(min: 0, max: 100).nullable()();
  TextColumn get mobile => text().withLength(min: 0, max: 20).nullable()();
  TextColumn get email => text().withLength(min: 0, max: 100).nullable()();
  TextColumn get address => text().withLength(min: 0, max: 255).nullable()();
  TextColumn get gstNumber => text().withLength(min: 0, max: 50).nullable()();
  TextColumn get city => text().withLength(min: 0, max: 50).nullable()();
  TextColumn get state => text().withLength(min: 0, max: 50).nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
