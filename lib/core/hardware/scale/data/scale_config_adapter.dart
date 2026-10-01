import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../domain/scale_models.dart';

/// Maps between the persisted `scale_settings` row and the domain
/// [ScaleConfig].
class ScaleConfigAdapter {
  const ScaleConfigAdapter._();

  static ScaleConfig fromRow(ScaleSetting row) {
    return ScaleConfig(
      port: row.port,
      baudRate: row.baudRate,
      dataBits: row.dataBits,
      parity: _parityFromInt(row.parity),
      stopBits: row.stopBits,
      protocol: ScaleProtocolType.fromStorage(row.protocol),
      enabled: row.enabled,
    );
  }

  static ScaleSettingsCompanion toCompanion(ScaleConfig config) {
    return ScaleSettingsCompanion(
      port: Value(config.port),
      baudRate: Value(config.baudRate),
      dataBits: Value(config.dataBits),
      parity: Value(_parityToInt(config.parity)),
      stopBits: Value(config.stopBits),
      protocol: Value(config.protocol.name),
      enabled: Value(config.enabled),
      updatedAt: Value(DateTime.now()),
    );
  }

  static int _parityToInt(ScaleParity parity) => switch (parity) {
    ScaleParity.none => 0,
    ScaleParity.odd => 1,
    ScaleParity.even => 2,
  };

  static ScaleParity _parityFromInt(int value) => switch (value) {
    1 => ScaleParity.odd,
    2 => ScaleParity.even,
    _ => ScaleParity.none,
  };
}
