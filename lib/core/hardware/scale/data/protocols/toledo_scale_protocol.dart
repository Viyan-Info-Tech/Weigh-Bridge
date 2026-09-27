import '../../domain/scale_models.dart';
import '../../domain/scale_protocol.dart';

/// Mettler Toledo continuous data protocol.
///
/// Typical frame format (17 bytes):
/// `[STX][Status A][Status B][Status C][6 weight chars][6 tare chars][CR]`
class ToledoScaleProtocol implements ScaleProtocol {
  const ToledoScaleProtocol();

  @override
  String get name => 'toledo-continuous';

  @override
  ScaleProtocolType get protocolType => ScaleProtocolType.toledo;

  @override
  ParsedScaleFrame? parse(ScaleFrame frame) {
    final bytes = frame.bytes;
    if (bytes.length < 16) {
      // Fallback: try ASCII extraction if parsed as text
      final text = frame.asciiValue
          .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
          .trim();
      final weight = double.tryParse(text);
      if (weight != null) {
        return ParsedScaleFrame(weightKg: weight, stable: true);
      }
      return null;
    }

    final int stx = bytes.indexOf(0x02);
    final int offset = stx >= 0 ? stx : 0;
    if (bytes.length - offset < 10) return null;

    final statusB = bytes.length > offset + 2 ? bytes[offset + 2] : 0;
    final isOverload = (statusB & 0x04) != 0;
    final isMotion = (statusB & 0x08) != 0;
    final isNegative = (statusB & 0x02) != 0;

    final weightStart = offset + 4;
    final weightEnd = offset + 10;
    if (bytes.length < weightEnd) return null;

    final weightBytes = bytes.sublist(weightStart, weightEnd);
    final weightStr = String.fromCharCodes(weightBytes).trim();
    var weight = double.tryParse(weightStr);
    if (weight == null) return null;

    if (isNegative) weight = -weight;

    return ParsedScaleFrame(
      weightKg: weight,
      stable: !isMotion,
      isMotion: isMotion,
      isOverload: isOverload,
    );
  }
}
