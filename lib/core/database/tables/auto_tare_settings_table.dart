import 'package:drift/drift.dart';

/// Date-based common (platform) tare weight captured by the operator.
///
/// One row per calendar day. [tareDate] is stored as the day-only midnight
/// timestamp so a day's value can be looked up with a simple equality match.
/// Bills copy the tare value into their own row when they are saved, so
/// changing today's value never rewrites historical weighments.
class AutoTareSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get tareDate => dateTime().unique()();
  RealColumn get tareKg => real()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
