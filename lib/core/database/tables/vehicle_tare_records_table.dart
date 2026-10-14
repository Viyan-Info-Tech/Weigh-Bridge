import 'package:drift/drift.dart';

/// Per-vehicle tare weight registry managed from the Auto Tare popup.
///
/// One row per vehicle: [vehicleNumber] is stored upper-cased and unique so
/// re-adding a vehicle updates its tare instead of duplicating it. This is
/// separate from [AutoTareSettings], which keeps the single common tare for
/// a calendar day used by the F3 apply flow; rows here never create bills.
class VehicleTareRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get vehicleNumber => text().withLength(min: 1, max: 30).unique()();
  RealColumn get tareKg => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
