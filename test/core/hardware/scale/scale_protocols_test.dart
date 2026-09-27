import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/hardware/scale/data/protocols/ascii_continuous_protocol.dart';
import 'package:weighbridge/core/hardware/scale/data/protocols/avery_scale_protocol.dart';
import 'package:weighbridge/core/hardware/scale/data/protocols/cardinal_scale_protocol.dart';
import 'package:weighbridge/core/hardware/scale/data/protocols/scale_protocol_registry.dart';
import 'package:weighbridge/core/hardware/scale/data/protocols/toledo_scale_protocol.dart';
import 'package:weighbridge/core/hardware/scale/data/protocols/universal_scale_protocol.dart';
import 'package:weighbridge/core/hardware/scale/data/protocols/yaohua_scale_protocol.dart';
import 'package:weighbridge/core/hardware/scale/domain/scale_models.dart';
import 'package:weighbridge/core/hardware/scale/domain/scale_protocol.dart';

void main() {
  final now = DateTime(2026, 9, 27, 12, 0, 0);

  ScaleFrame makeFrame(String ascii) =>
      ScaleFrame(ascii.codeUnits, receivedAt: now);

  group('UniversalScaleProtocol', () {
    const protocol = UniversalScaleProtocol();

    test('parses simple numeric weight', () {
      final parsed = protocol.parse(makeFrame('12500'));
      expect(parsed, isNotNull);
      expect(parsed!.weightKg, 12500);
      expect(parsed.isValid, isTrue);
    });

    test('parses zero weight (scale empty)', () {
      final parsed = protocol.parse(makeFrame('+0000000 kg'));
      expect(parsed, isNotNull);
      expect(parsed!.weightKg, 0);
      expect(parsed.isValid, isTrue);
    });

    test('parses continuous ASCII with sign and units', () {
      final parsed = protocol.parse(makeFrame('ST,GS,+0012500 kg'));
      expect(parsed, isNotNull);
      expect(parsed!.weightKg, 12500);
      expect(parsed.stable, isTrue);
      expect(parsed.isMotion, isFalse);
    });

    test('parses dynamic/motion readings', () {
      final parsed = protocol.parse(makeFrame('US,GS,+0004500 kg'));
      expect(parsed, isNotNull);
      expect(parsed!.weightKg, 4500);
      expect(parsed.isMotion, isTrue);
      expect(parsed.stable, isFalse);
    });

    test('parses overload readings', () {
      final parsed = protocol.parse(makeFrame('OL kg'));
      expect(parsed, isNull); // OL without weight returns null or invalid
    });

    test('converts tonnes (t) to kg', () {
      final parsed = protocol.parse(makeFrame('12.50 t'));
      expect(parsed, isNotNull);
      expect(parsed!.weightKg, 12500.0);
    });

    test('parses Yaohua reversed format (=005210 -> 012500 -> 12500)', () {
      final parsed = protocol.parse(makeFrame('=005210'));
      expect(parsed, isNotNull);
      expect(parsed!.weightKg, 12500);
    });
  });

  group('YaohuaScaleProtocol', () {
    const protocol = YaohuaScaleProtocol();

    test('parses reversed output', () {
      final parsed = protocol.parse(makeFrame('=000521'));
      expect(parsed, isNotNull);
      expect(parsed!.weightKg, 125000);
    });

    test('parses straight format', () {
      final parsed = protocol.parse(makeFrame('WN0012500'));
      expect(parsed, isNotNull);
      expect(parsed!.weightKg, 12500);
    });
  });

  group('ToledoScaleProtocol', () {
    const protocol = ToledoScaleProtocol();

    test('parses Toledo 17-byte stream', () {
      // [STX][Status A][Status B][Status C][012500][000000][CR]
      final bytes = <int>[
        0x02,
        0x20,
        0x20, // Status B (stable, not overload)
        0x20,
        0x30, 0x31, 0x32, 0x35, 0x30, 0x30, // '012500'
        0x30, 0x30, 0x30, 0x30, 0x30, 0x30,
        0x0D,
      ];
      final parsed = protocol.parse(ScaleFrame(bytes, receivedAt: now));
      expect(parsed, isNotNull);
      expect(parsed!.weightKg, 12500);
      expect(parsed.stable, isTrue);
    });
  });

  group('FrameDecoder auto slicing', () {
    test('slices frames delimited by CRLF and CR', () {
      final decoder = FrameDecoder(terminator: FrameTerminator.auto);
      final chunk1 = '12500\r\n125'.codeUnits;
      final frames1 = decoder.feed(chunk1, now);
      expect(frames1.length, 1);
      expect(frames1[0].asciiValue, '12500');

      final chunk2 = '50\r'.codeUnits;
      final frames2 = decoder.feed(chunk2, now);
      expect(frames2.length, 1);
      expect(frames2[0].asciiValue, '12550');
    });

    test('slices frames delimited by STX and ETX', () {
      final decoder = FrameDecoder(terminator: FrameTerminator.auto);
      final chunk = <int>[0x02, ...'12500'.codeUnits, 0x03];
      final frames = decoder.feed(chunk, now);
      expect(frames.length, 1);
      expect(frames[0].asciiValue, '12500');
    });
  });

  group('ScaleProtocolRegistry', () {
    test('resolves unconfigured to UniversalScaleProtocol', () {
      final protocol = ScaleProtocolRegistry.getProtocol(
        ScaleProtocolType.unconfigured,
      );
      expect(protocol, isA<UniversalScaleProtocol>());
    });

    test('resolves universal to UniversalScaleProtocol', () {
      final protocol = ScaleProtocolRegistry.getProtocol(
        ScaleProtocolType.universal,
      );
      expect(protocol, isA<UniversalScaleProtocol>());
    });

    test('resolves specific protocols', () {
      expect(
        ScaleProtocolRegistry.getProtocol(ScaleProtocolType.yaohua),
        isA<YaohuaScaleProtocol>(),
      );
      expect(
        ScaleProtocolRegistry.getProtocol(ScaleProtocolType.toledo),
        isA<ToledoScaleProtocol>(),
      );
      expect(
        ScaleProtocolRegistry.getProtocol(ScaleProtocolType.avery),
        isA<AveryScaleProtocol>(),
      );
      expect(
        ScaleProtocolRegistry.getProtocol(ScaleProtocolType.cardinal),
        isA<CardinalScaleProtocol>(),
      );
      expect(
        ScaleProtocolRegistry.getProtocol(ScaleProtocolType.asciiContinuous),
        isA<AsciiContinuousProtocol>(),
      );
    });
  });
}
