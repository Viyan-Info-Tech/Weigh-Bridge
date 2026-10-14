import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/services/weighment_ticket_pdf_generator.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';

/// Decodes the visible text of a PDF produced by the `pdf` package.
///
/// The package writes glyph ids into content streams, so plain extraction
/// does not work. This helper parses the embedded ToUnicode CMaps and maps
/// every `<hex>` run in the text-showing operators back to characters.
String decodePdfText(Uint8List bytes) {
  final raw = latin1.decode(bytes);
  final objRe = RegExp(r'(\d+) 0 obj(.*?)endobj', dotAll: true);
  final streamRe = RegExp(r'stream\r?\n(.*?)\r?\nendstream', dotAll: true);

  // Decompress every FlateDecode stream, keyed by object number.
  final streams = <int, String>{};
  for (final obj in objRe.allMatches(raw)) {
    final body = obj.group(2)!;
    final stream = streamRe.firstMatch(body);
    if (stream == null) continue;
    try {
      final data = ZLibDecoder().convert(stream.group(1)!.codeUnits);
      streams[int.parse(obj.group(1)!)] = utf8.decode(
        data,
        allowMalformed: true,
      );
    } catch (_) {}
  }

  // Parse the ToUnicode CMap of every font object.
  final cmaps = <int, Map<int, String>>{};
  for (final obj in objRe.allMatches(raw)) {
    final body = obj.group(2)!;
    final toUnicode = RegExp(r'/ToUnicode\s+(\d+)\s+0\s+R').firstMatch(body);
    if (toUnicode == null) continue;
    final cmapText = streams[int.parse(toUnicode.group(1)!)];
    if (cmapText == null) continue;
    cmaps[int.parse(obj.group(1)!)] = _parseCMap(cmapText);
  }

  // Font resource name -> font object number.
  final fontResources = <int, int>{};
  for (final m in RegExp(r'/F(\d+)\s+(\d+)\s+0\s+R').allMatches(raw)) {
    fontResources[int.parse(m.group(1)!)] = int.parse(m.group(2)!);
  }

  final buffer = StringBuffer();
  final tokenRe = RegExp(r'BT|ET|/F(\d+)\s+[\d.]+\s+Tf|<([0-9A-Fa-f]+)>');
  for (final text in streams.values) {
    if (!text.contains('BT') || !text.contains('Tf')) continue;
    var insideText = false;
    Map<int, String>? activeMap;
    for (final token in tokenRe.allMatches(text)) {
      final value = token.group(0)!;
      if (value == 'BT') {
        insideText = true;
        continue;
      }
      if (value == 'ET') {
        insideText = false;
        buffer.write(' ');
        continue;
      }
      if (token.group(1) != null) {
        final fontObj = fontResources[int.parse(token.group(1)!)];
        activeMap = fontObj == null ? null : cmaps[fontObj];
        continue;
      }
      final hex = token.group(2);
      if (!insideText || hex == null || activeMap == null) continue;
      for (var i = 0; i + 4 <= hex.length; i += 4) {
        buffer.write(
          activeMap[int.parse(hex.substring(i, i + 4), radix: 16)] ?? '',
        );
      }
    }
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

Map<int, String> _parseCMap(String cmapText) {
  final map = <int, String>{};
  String decodeDestination(String hex) {
    final out = StringBuffer();
    for (var i = 0; i + 4 <= hex.length; i += 4) {
      out.write(
        String.fromCharCode(int.parse(hex.substring(i, i + 4), radix: 16)),
      );
    }
    return out.toString();
  }

  for (final block in RegExp(
    r'beginbfchar(.*?)endbfchar',
    dotAll: true,
  ).allMatches(cmapText)) {
    for (final m in RegExp(
      r'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>',
    ).allMatches(block.group(1)!)) {
      map[int.parse(m.group(1)!, radix: 16)] = decodeDestination(m.group(2)!);
    }
  }
  for (final block in RegExp(
    r'beginbfrange(.*?)endbfrange',
    dotAll: true,
  ).allMatches(cmapText)) {
    for (final m in RegExp(
      r'<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>',
    ).allMatches(block.group(1)!)) {
      final lo = int.parse(m.group(1)!, radix: 16);
      final hi = int.parse(m.group(2)!, radix: 16);
      final dst = int.parse(m.group(3)!, radix: 16);
      for (var code = lo; code <= hi; code++) {
        map[code] = String.fromCharCode(dst + (code - lo));
      }
    }
  }
  return map;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const generator = WeighmentTicketPdfGenerator();
  final settings = BillingSettings(updatedAt: DateTime(2026, 9, 18));
  final printedAt = DateTime(2026, 9, 18, 12, 0);

  Weighment weighment({
    double firstWeightKg = 0,
    String firstWeightType = 'GROSS',
    double? secondWeightKg,
    double? grossWeightKg,
    double? tareWeightKg,
    double? netWeightKg,
    String remarks = '',
  }) {
    return Weighment(
      id: 1,
      billNumber: 'WB-00042',
      vehicleNumber: 'TN31CM2026',
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
      grossWeightKg: grossWeightKg,
      tareWeightKg: tareWeightKg,
      netWeightKg: netWeightKg,
      remarks: remarks.isEmpty ? null : remarks,
      createdAt: DateTime(2026, 9, 18, 10, 30),
      updatedAt: DateTime(2026, 9, 18, 10, 30),
    );
  }

  Future<String> decodeTicket(Weighment bill) async {
    final bytes = await generator.generateTicketPdf(
      bill: bill,
      settings: settings,
      printedAt: printedAt,
    );
    expect(bytes, isNotEmpty);
    expect(
      String.fromCharCodes(bytes.take(4)),
      '%PDF',
      reason: 'generated ticket must be a PDF document',
    );
    return decodePdfText(bytes);
  }

  /// The [count] whitespace-separated tokens printed right after [label].
  String valueAfter(String text, String label, [int count = 1]) {
    final tokens = text.split(' ');
    final words = label.split(' ');
    for (var i = 0; i + words.length < tokens.length; i++) {
      var matches = true;
      for (var j = 0; j < words.length; j++) {
        if (tokens[i + j] != words[j]) {
          matches = false;
          break;
        }
      }
      if (matches) {
        return tokens
            .sublist(i + words.length, i + words.length + count)
            .join(' ');
      }
    }
    fail('missing row "$label" in: $text');
  }

  group('WeighmentTicketPdfGenerator', () {
    test(
      'gross-only weighment prints captured gross and dashes for the rest',
      () async {
        final text = await decodeTicket(weighment(firstWeightKg: 20000));

        expect(text, contains('WB-00042'));
        expect(text, contains('VIYAN WEIGHBRIDGE'));
        expect(text, contains('WEIGHMENT RECEIPT'));
        expect(text, contains('TN31CM2026'));

        // Missing weights must render as dashes, never as zero or a
        // fabricated net weight.
        expect(valueAfter(text, 'Gross Weight', 2), '20.000 ton');
        expect(valueAfter(text, 'Tare Weight'), '--');
        expect(valueAfter(text, 'Net Weight'), '--');
        expect(text, isNot(contains('0 kg')));

        expect(valueAfter(text, 'Status'), 'COMPLETED');
        expect(text, isNot(contains('INCOMPLETE')));
      },
    );

    test('two-weight weighment prints gross, tare and derived net', () async {
      final text = await decodeTicket(
        weighment(firstWeightKg: 20000, secondWeightKg: 5000),
      );

      expect(valueAfter(text, 'Gross Weight', 2), '20.000 ton');
      expect(valueAfter(text, 'Tare Weight', 2), '5.000 ton');
      expect(valueAfter(text, 'Net Weight', 2), '15.000 ton');
      expect(valueAfter(text, 'Status'), 'COMPLETED');
      expect(text, isNot(contains(' -- ')));
    });

    test(
      'weighment without any weight prints dashes and INCOMPLETE status',
      () async {
        final text = await decodeTicket(weighment());

        expect(valueAfter(text, 'Gross Weight'), '--');
        expect(valueAfter(text, 'Tare Weight'), '--');
        expect(valueAfter(text, 'Net Weight'), '--');
        expect(valueAfter(text, 'Status'), 'INCOMPLETE');
        expect(text, isNot(contains('0 kg')));
      },
    );

    test('prints remarks when present', () async {
      final text = await decodeTicket(
        weighment(firstWeightKg: 20000, remarks: 'Deliver to site gate 4'),
      );

      expect(text, contains('Deliver'));
      expect(text, contains('gate'));
    });
  });
}
