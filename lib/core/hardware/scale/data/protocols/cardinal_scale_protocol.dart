import '../../domain/scale_models.dart';
import '../../domain/scale_protocol.dart';

/// Cardinal / Detecto continuous stream protocol.
///
/// Typical format: `<P|M><Weight><SP><units><SP><G|N>`
class CardinalScaleProtocol implements ScaleProtocol {
  const CardinalScaleProtocol();

  @override
  String get name => 'cardinal-detecto';

  @override
  ScaleProtocolType get protocolType => ScaleProtocolType.cardinal;

  static final RegExp _regex = RegExp(
    r'(P|M|O)?\s*([+-]?\s*\d+(?:\.\d+)?)\s*(kg|lb)?',
    caseSensitive: false,
  );

  @override
  ParsedScaleFrame? parse(ScaleFrame frame) {
    final text = frame.asciiValue
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ')
        .trim();
    if (text.isEmpty) return null;

    final match = _regex.firstMatch(text);
    if (match == null) return null;

    final marker = match.group(1)?.toUpperCase();
    final isMotion = marker == 'M';
    final isOverload = marker == 'O';
    final isStable = marker == 'P' || (!isMotion && !isOverload);

    final numStr = match.group(2)?.replaceAll(' ', '');
    if (numStr == null) return null;

    var weight = double.tryParse(numStr);
    if (weight == null) return null;

    final unit = match.group(3)?.toLowerCase();
    if (unit == 'lb') {
      weight = weight * 0.45359237;
    }

    return ParsedScaleFrame(
      weightKg: weight,
      stable: isStable,
      isMotion: isMotion,
      isOverload: isOverload,
    );
  }
}
