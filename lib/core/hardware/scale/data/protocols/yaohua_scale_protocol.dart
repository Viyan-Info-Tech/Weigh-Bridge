import '../../domain/scale_models.dart';
import '../../domain/scale_protocol.dart';

/// Protocol implementation for Yaohua XK3190 indicator series (A9, D2008, A12, DS3).
///
/// Handles both standard continuous stream and reversed ASCII output (`=005210`).
class YaohuaScaleProtocol implements ScaleProtocol {
  const YaohuaScaleProtocol();

  @override
  String get name => 'yaohua-xk3190';

  @override
  ScaleProtocolType get protocolType => ScaleProtocolType.yaohua;

  static final RegExp _reversedRegex = RegExp(r'=([+-]?\d+(?:\.\d+)?)');
  static final RegExp _standardRegex = RegExp(
    r'(?:WN|WW)?([+-]?\d+(?:\.\d+)?)',
  );

  @override
  ParsedScaleFrame? parse(ScaleFrame frame) {
    final raw = frame.asciiValue;
    if (raw.isEmpty) return null;

    final upper = raw.toUpperCase();
    final isOverload = upper.contains('OL') || upper.contains('OF');

    // 1. Check for reversed format `=005210`
    final revMatch = _reversedRegex.firstMatch(raw);
    if (revMatch != null) {
      final payload = revMatch.group(1)!;
      final reversed = payload.split('').reversed.join('');
      final weight = double.tryParse(reversed);
      if (weight != null) {
        return ParsedScaleFrame(
          weightKg: weight,
          stable: true,
          isMotion: false,
          isOverload: isOverload,
        );
      }
    }

    // 2. Straight format
    final stdMatch = _standardRegex.firstMatch(raw);
    if (stdMatch != null) {
      final numStr = stdMatch.group(1);
      if (numStr != null) {
        final weight = double.tryParse(numStr);
        if (weight != null) {
          return ParsedScaleFrame(
            weightKg: weight,
            stable: true,
            isMotion: false,
            isOverload: isOverload,
          );
        }
      }
    }

    return null;
  }
}
