import '../../domain/scale_models.dart';
import '../../domain/scale_protocol.dart';
import 'ascii_continuous_protocol.dart';
import 'avery_scale_protocol.dart';
import 'cardinal_scale_protocol.dart';
import 'toledo_scale_protocol.dart';
import 'universal_scale_protocol.dart';
import 'yaohua_scale_protocol.dart';

/// Registry providing concrete [ScaleProtocol] parsers and framing configurations
/// corresponding to each [ScaleProtocolType].
class ScaleProtocolRegistry {
  const ScaleProtocolRegistry._();

  static const UniversalScaleProtocol _universal = UniversalScaleProtocol();
  static const AsciiContinuousProtocol _ascii = AsciiContinuousProtocol();
  static const YaohuaScaleProtocol _yaohua = YaohuaScaleProtocol();
  static const ToledoScaleProtocol _toledo = ToledoScaleProtocol();
  static const AveryScaleProtocol _avery = AveryScaleProtocol();
  static const CardinalScaleProtocol _cardinal = CardinalScaleProtocol();

  /// Returns the protocol strategy for the given type.
  /// Defaults to [UniversalScaleProtocol] for unconfigured or unknown types.
  static ScaleProtocol getProtocol(ScaleProtocolType type) => switch (type) {
    ScaleProtocolType.universal => _universal,
    ScaleProtocolType.asciiContinuous => _ascii,
    ScaleProtocolType.yaohua => _yaohua,
    ScaleProtocolType.toledo => _toledo,
    ScaleProtocolType.avery => _avery,
    ScaleProtocolType.cardinal => _cardinal,
    ScaleProtocolType.unconfigured => _universal,
  };

  /// Returns the recommended framing terminator for the protocol.
  static FrameTerminator getTerminator(ScaleProtocolType type) =>
      switch (type) {
        ScaleProtocolType.toledo => FrameTerminator.auto,
        ScaleProtocolType.yaohua => FrameTerminator.auto,
        _ => FrameTerminator.auto,
      };
}
