import 'package:drift/drift.dart';

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Weight
  TextColumn get weightUnit => text().withDefault(const Constant('kg'))();

  // Bill numbering
  TextColumn get billPrefix => text().withDefault(const Constant('WB'))();
  IntColumn get billStartingNumber =>
      integer().withDefault(const Constant(1))();
  IntColumn get billNumberDigits => integer().withDefault(const Constant(5))();

  // Receipt header
  TextColumn get businessName =>
      text().withDefault(const Constant('VIYAN WEIGHBRIDGE'))();
  TextColumn get businessSubtitle => text().nullable()();
  TextColumn get serviceText => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get gstin => text().nullable()();
  TextColumn get logoPath => text().nullable()();

  // Receipt
  TextColumn get receiptTitle =>
      text().withDefault(const Constant('WEIGHMENT RECEIPT'))();

  // Receipt field visibility
  BoolColumn get showSerialNumber =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get showDate => boolean().withDefault(const Constant(true))();
  BoolColumn get showTime => boolean().withDefault(const Constant(true))();
  BoolColumn get showVehicleNumber =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get showGrossWeight =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get showTareWeight =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get showNetWeight => boolean().withDefault(const Constant(true))();
  BoolColumn get showRemarks => boolean().withDefault(const Constant(true))();

  // Footer
  BoolColumn get showFooterNote =>
      boolean().withDefault(const Constant(true))();
  TextColumn get footerNote => text().nullable()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
