import '../../domain/scale_models.dart';
import '../../domain/scale_protocol.dart';

/// Intelligent universal protocol that automatically detects and extracts weight,
/// stability, motion, and overload states from common weighbridge and scale indicators.
///
/// Supports:
/// - Continuous ASCII weight streams (e.g. `+0012500 kg`, `ST,GS,+0012500.0 kg`, `12500`)
/// - Yaohua XK3190 / D2008 series (e.g. reversed digit payloads `=005210`)
/// - Mettler Toledo continuous data stream
/// - Multi-unit conversion (tonnes `t` -> kg, pounds `lb` -> kg)
class UniversalScaleProtocol implements ScaleProtocol {
  const UniversalScaleProtocol();

  @override
  String get name => 'universal-auto';

  @override
  ScaleProtocolType get protocolType => ScaleProtocolType.universal;

  // Regex to extract numeric weight with optional sign and optional unit
  static final RegExp _weightRegex = RegExp(
    r'([+-]?\s*\d+(?:\.\d+)?)\s*(kg|kgs|t|ton|tons|tonne|tonnes|lb|lbs)?',
    caseSensitive: false,
  );

  // Regex for Yaohua reversed indicator `=005210`
  static final RegExp _yaohuaRegex = RegExp(r'=([+-]?\d+(?:\.\d+)?)');

  @override
  ParsedScaleFrame? parse(ScaleFrame frame) {
    // 1. Try Toledo Continuous packet (16-18 bytes, starting with 0x02)
    if (_isToledoContinuous(frame.bytes)) {
      final parsed = _parseToledo(frame.bytes);
      if (parsed != null) return parsed;
    }

    final rawAscii = frame.asciiValue;
    if (rawAscii.isEmpty) return null;

    final upper = rawAscii.toUpperCase();

    // 2. Overload detection
    final isOverload =
        upper.contains('OL') ||
        upper.contains('OVER') ||
        upper.contains('^ ^ ^ ^') ||
        upper.contains('++++++');

    // 3. Stability & Motion detection
    final isMotion =
        upper.contains('US') ||
        upper.contains('MOT') ||
        upper.contains('(M)') ||
        upper.contains('DYNAMIC') ||
        upper.startsWith('US,') ||
        upper.startsWith('U ') ||
        upper.contains('UNSTABLE');

    final isStable =
        !isMotion &&
        (upper.contains('ST') ||
            upper.contains('(S)') ||
            upper.startsWith('S ') ||
            upper.startsWith('ST,') ||
            upper.contains('STABLE') ||
            !upper.contains('U'));

    // 4. Check Yaohua reversed format (starts with '=')
    final yaohuaMatch = _yaohuaRegex.firstMatch(rawAscii);
    if (yaohuaMatch != null) {
      final reversedDigits = yaohuaMatch.group(1)!;
      final normalDigits = reversedDigits.split('').reversed.join('');
      final weight = double.tryParse(normalDigits);
      if (weight != null) {
        return ParsedScaleFrame(
          weightKg: weight,
          stable: isStable,
          isMotion: isMotion,
          isOverload: isOverload,
        );
      }
    }

    // 5. Clean string of control characters
    final cleanText = rawAscii
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ')
        .trim();

    // Avoid misinterpreting date/time strings (e.g. 2026-09-27 17:25:00)
    final textWithoutDates = cleanText.replaceAll(
      RegExp(r'\d{4}[-/]\d{2}[-/]\d{2}|\d{2}:\d{2}(?::\d{2})?'),
      '',
    );

    // 6. Generic weight extraction
    final matches = _weightRegex.allMatches(textWithoutDates).toList();
    if (matches.isEmpty) return null;

    // Typically, the last or only weight match represents the current gross/net reading
    for (final match in matches.reversed) {
      final rawNum = match.group(1)?.replaceAll(' ', '');
      if (rawNum == null) continue;

      var weight = double.tryParse(rawNum);
      if (weight == null) continue;

      final unit = match.group(2)?.toLowerCase();
      if (unit != null) {
        if (unit == 't' ||
            unit == 'ton' ||
            unit == 'tons' ||
            unit == 'tonne' ||
            unit == 'tonnes') {
          weight = weight * 1000.0;
        } else if (unit == 'lb' || unit == 'lbs') {
          weight = weight * 0.45359237;
        }
      }

      return ParsedScaleFrame(
        weightKg: weight,
        stable: isStable,
        isMotion: isMotion,
        isOverload: isOverload,
      );
    }

    return null;
  }

  bool _isToledoContinuous(List<int> bytes) {
    if (bytes.length < 16) return false;
    return bytes.first == 0x02 || (bytes.length >= 17 && bytes[16] == 0x0D);
  }

  ParsedScaleFrame? _parseToledo(List<int> bytes) {
    try {
      int offset = bytes.indexOf(0x02);
      if (offset < 0 || bytes.length - offset < 16) return null;

      // Toledo continuous structure:
      // [STX][Status A][Status B][Status C][6 weight chars][6 tare chars][CR]
      final statusB = bytes[offset + 2];
      final isOverload = (statusB & 0x04) != 0;
      final isMotion = (statusB & 0x08) != 0;
      final isNegative = (statusB & 0x02) != 0;

      final weightBytes = bytes.sublist(offset + 4, offset + 10);
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
    } catch (_) {
      return null;
    }
  }
}
