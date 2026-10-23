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

  /// Material name + vehicle type snapshot stored with the weighment
  /// (e.g. `Auto - Empty`).
  ///
  /// The value is denormalised on purpose: a saved bill must keep printing
  /// exactly what the operator selected even after the material master is
  /// edited or deactivated later. Nullable so legacy rows (schema 30-32)
  /// and tare-only weighments stay valid.
  TextColumn get material => text().withLength(min: 0, max: 100).nullable()();

  /// Stable reference to the material master row chosen on the form
  /// (schema 33). Nullable: legacy rows and tare-only weighments have none.
  ///
  /// No foreign-key constraint is declared so the schema-33 migration can be
  /// a plain additive `ALTER TABLE ADD COLUMN` instead of a table rebuild;
  /// deletion of referenced materials is blocked in the DAO instead.
  IntColumn get materialId => integer().nullable()();

  /// Manually entered charges for this weighment, in rupees.
  ///
  /// Nullable so legacy rows (created before this column existed) stay valid;
  /// NULL renders as an empty value in the form and zero total in reports.
  RealColumn get charges => real().nullable()();

  /// Id of the earlier weighment this bill completes (second-weight flow).
  ///
  /// Set only when the bill was created in SECOND WEIGHT mode: it points at
  /// the single-weight bill whose previous weight was reused. Nullable so
  /// every normal bill (and all legacy rows) simply read back NULL. No
  /// foreign-key constraint is declared so the schema-35 migration is a plain
  /// additive `ALTER TABLE ADD COLUMN`; the referenced bill is immutable
  /// history and is never deleted by the application.
  IntColumn get previousWeighmentId => integer().nullable()();

  /// Legacy weighment description (schema 30).
  ///
  /// No longer part of the weighment workflow: the UI, receipt, PDF, and
  /// application data flow never read or write it. The column is deliberately
  /// kept in the schema so no migration or schema-version bump is needed and
  /// description values already stored on existing weighment rows stay intact.
  TextColumn get description =>
      text().withLength(min: 0, max: 500).nullable()();
  TextColumn get remarks => text().withLength(min: 0, max: 500).nullable()();
  TextColumn get mobileNumber =>
      text().withLength(min: 0, max: 20).nullable()();
  TextColumn get weightUnit =>
      text().withLength(min: 1, max: 10).withDefault(const Constant('ton'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
