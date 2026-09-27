import '../../domain/scale_models.dart';
import '../../domain/scale_protocol.dart';

/// Standard ASCII continuous stream protocol.
///
/// Typical formats:
/// - `+0012500 kg\r\n`
/// - `ST,GS,+0012500.0 kg\r\n`
/// - ` 12500 kg\r\n`
/// - `12500\r\n`
class AsciiContinuousProtocol implements ScaleProtocol {
  const AsciiContinuousProtocol();

  @override
  String get name => 'ascii-continuous';

  @override
  ScaleProtocolType get protocolType => ScaleProtocolType.asciiContinuous;

  static final RegExp _regex = RegExp(
    r'([+-]?\s*\d+(?:\.\d+)?)\s*(kg|kgs)?',
    caseSensitive: false,
  );

  @override
  ParsedScaleFrame? parse(ScaleFrame frame) {
    final text = frame.asciiValue
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ')
        .trim();
    if (text.isEmpty) return null;

    final upper = text.toUpperCase();
    final isOverload = upper.contains('OL') || upper.contains('OVER');
    final isMotion =
        upper.contains('US') ||
        upper.contains('MOT') ||
        upper.contains('DYNAMIC');
    final isStable = !isMotion;

    final match = _regex.firstMatch(text);
    if (match == null) return null;

    final numStr = match.group(1)?.replaceAll(' ', '');
    if (numStr == null) return null;

    final weight = double.tryParse(numStr);
    if (weight == null) return null;

    return ParsedScaleFrame(
      weightKg: weight,
      stable: isStable,
      isMotion: isMotion,
      isOverload: isOverload,
    );
  }
}
