import '../../domain/scale_models.dart';
import '../../domain/scale_protocol.dart';

/// Avery Weigh-Tronix continuous stream protocol.
///
/// Typical format: `<ST|US>,<GS|NT>,<Weight> <kg|lb>`
class AveryScaleProtocol implements ScaleProtocol {
  const AveryScaleProtocol();

  @override
  String get name => 'avery-weigh-tronix';

  @override
  ScaleProtocolType get protocolType => ScaleProtocolType.avery;

  static final RegExp _regex = RegExp(
    r'(ST|US|OL|MOT)?.*?(?:GS|NT|GR)?.*?([+-]?\s*\d+(?:\.\d+)?)\s*(kg|lb)?',
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

    final status = match.group(1)?.toUpperCase();
    final isMotion = status == 'US' || status == 'MOT';
    final isOverload = status == 'OL';
    final isStable = status == 'ST' || (!isMotion && !isOverload);

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
