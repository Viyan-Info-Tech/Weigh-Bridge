import 'package:drift/drift.dart';

/// Single-row table holding the weigh indicator serial connection settings.
/// Mirrors the iconfig persistence style of [AppSettings].
class ScaleSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Serial connection
  TextColumn get port => text().withDefault(const Constant('COM3'))();
  IntColumn get baudRate => integer().withDefault(const Constant(9600))();
  IntColumn get dataBits => integer().withDefault(const Constant(8))();
  // 0 = none, 1 = odd, 2 = even
  IntColumn get parity => integer().withDefault(const Constant(0))();
  IntColumn get stopBits => integer().withDefault(const Constant(1))();
  // Stored as the ScaleProtocolType enum name; 'unconfigured' until the
  // indicator protocol is confirmed.
  TextColumn get protocol =>
      text().withDefault(const Constant('unconfigured'))();

  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
