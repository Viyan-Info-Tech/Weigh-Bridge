/// Parity setting for the serial connection to the weigh indicator.
enum ScaleParity { none, odd, even }

/// The weight-indicator protocol the parser will use.
///
/// Concrete parser implementations are added once the indicator model,
/// its manual, and a sample of its output are known. Until then the value
/// remains [unconfigured] and readings only populate connection diagnostics.
enum ScaleProtocolType {
  unconfigured('Not configured'),
  universal('Auto-Detect / Universal (Recommended)'),
  asciiContinuous('Continuous ASCII Stream'),
  yaohua('Yaohua XK3190 / D2008'),
  toledo('Mettler Toledo Continuous'),
  avery('Avery Weigh-Tronix'),
  cardinal('Cardinal / Detecto');

  const ScaleProtocolType(this.label);

  final String label;

  static ScaleProtocolType fromStorage(String value) {
    return ScaleProtocolType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => ScaleProtocolType.unconfigured,
    );
  }
}

/// Connection parameters for the weigh indicator's serial interface.
///
/// The defaults mirror the most common indicator settings but are always
/// overridden by the persisted settings held in `scale_settings`.
class ScaleConfig {
  final String port;
  final int baudRate;
  final int dataBits;
  final ScaleParity parity;
  final int stopBits;
  final ScaleProtocolType protocol;
  final bool enabled;

  const ScaleConfig({
    this.port = 'COM3',
    this.baudRate = 2400,
    this.dataBits = 8,
    this.parity = ScaleParity.none,
    this.stopBits = 1,
    this.protocol = ScaleProtocolType.unconfigured,
    this.enabled = true,
  });

  ScaleConfig copyWith({
    String? port,
    int? baudRate,
    int? dataBits,
    ScaleParity? parity,
    int? stopBits,
    ScaleProtocolType? protocol,
    bool? enabled,
  }) {
    return ScaleConfig(
      port: port ?? this.port,
      baudRate: baudRate ?? this.baudRate,
      dataBits: dataBits ?? this.dataBits,
      parity: parity ?? this.parity,
      stopBits: stopBits ?? this.stopBits,
      protocol: protocol ?? this.protocol,
      enabled: enabled ?? this.enabled,
    );
  }

  /// Human readable summary, e.g. `COM3 | 9600/8/none/1`.
  String get description =>
      '$port | $baudRate/$dataBits/${parity.name}/$stopBits';
}
