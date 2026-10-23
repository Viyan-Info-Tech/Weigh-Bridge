import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/services/preprinted_ticket_pdf_generator.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';

/// One text run found in the job's content stream, with the translation that
/// was active when it was drawn.
class PlacedText {
  const PlacedText(this.x, this.y, this.text);

  final double x;
  final double y;
  final String text;
}

/// Reads every text run of a generated job, in drawing order.
///
/// Supports both font paths the generator can take:
/// * the PDF base-14 Courier fallback, which writes literal `[(text)]TJ` runs;
/// * an embedded TrueType font (`fonts/PlusJakartaSans-*.ttf`), which writes
///   glyph ids as `<hex>` runs that only the embedded ToUnicode CMap can map
///   back to characters.
List<PlacedText> placedTexts(Uint8List bytes) {
  final raw = latin1.decode(bytes);
  final objRe = RegExp(r'(\d+) 0 obj(.*?)endobj', dotAll: true);
  final streamRe = RegExp(r'stream\r?\n(.*?)\r?\nendstream', dotAll: true);

  // Decompress every stream, keyed by object number.
  final streams = <int, String>{};
  for (final obj in objRe.allMatches(raw)) {
    final stream = streamRe.firstMatch(obj.group(2)!);
    if (stream == null) continue;
    try {
      streams[int.parse(obj.group(1)!)] = utf8.decode(
        ZLibDecoder().convert(stream.group(1)!.codeUnits),
        allowMalformed: true,
      );
    } catch (_) {
      // Not a Flate stream (or binary): nothing to read here.
    }
  }

  // Font object -> glyph id to character table (embedded TrueType only).
  final cmaps = <int, Map<int, String>>{};
  for (final obj in objRe.allMatches(raw)) {
    final toUnicode = RegExp(
      r'/ToUnicode\s+(\d+)\s+0\s+R',
    ).firstMatch(obj.group(2)!);
    if (toUnicode == null) continue;
    final cmapText = streams[int.parse(toUnicode.group(1)!)];
    if (cmapText == null) continue;
    cmaps[int.parse(obj.group(1)!)] = _parseCMap(cmapText);
  }

  // Resource name (/F5) -> font object number.
  final fontObjects = <int, int>{};
  for (final m in RegExp(r'/F(\d+)\s+(\d+)\s+0\s+R').allMatches(raw)) {
    fontObjects[int.parse(m.group(1)!)] = int.parse(m.group(2)!);
  }

  String decodeLiteral(String source) => source
      .replaceAll(r'\(', '(')
      .replaceAll(r'\)', ')')
      .replaceAll(r'\\', r'\');

  String decodeHex(String hex, Map<int, String>? cmap) {
    if (cmap == null) return '';
    final out = StringBuffer();
    for (var i = 0; i + 4 <= hex.length; i += 4) {
      out.write(cmap[int.parse(hex.substring(i, i + 4), radix: 16)] ?? '');
    }
    return out.toString();
  }

  final placed = <PlacedText>[];
  final tokenRe = RegExp(
    r'1 0 0 1 (\d+(?:\.\d+)?) (\d+(?:\.\d+)?) cm'
    r'|/F(\d+)\s+[\d.]+\s+Tf'
    r'|\[((?:[^\[\]])*)\]\s*TJ'
    r'|\((.*?)\)\s*Tj'
    r'|<([0-9A-Fa-f]+)>\s*Tj',
    dotAll: true,
  );

  for (final stream in streams.values) {
    if (!stream.contains('Tf')) continue;
    var x = 0.0;
    var y = 0.0;
    Map<int, String>? cmap;
    for (final token in tokenRe.allMatches(stream)) {
      final translation = token.group(1);
      if (translation != null) {
        x = double.parse(translation);
        y = double.parse(token.group(2)!);
        continue;
      }
      final font = token.group(3);
      if (font != null) {
        final object = fontObjects[int.parse(font)];
        cmap = object == null ? null : cmaps[object];
        continue;
      }

      String text = '';
      final array = token.group(4);
      final literal = token.group(5);
      final hex = token.group(6);
      if (array != null) {
        final parts = <String>[];
        for (final piece in RegExp(
          r'\((.*?)\)|<([0-9A-Fa-f]+)>',
          dotAll: true,
        ).allMatches(array)) {
          parts.add(
            piece.group(1) != null
                ? decodeLiteral(piece.group(1)!)
                : decodeHex(piece.group(2)!, cmap),
          );
        }
        text = parts.join();
      } else if (literal != null) {
        text = decodeLiteral(literal);
      } else if (hex != null) {
        text = decodeHex(hex, cmap);
      }

      if (text.isNotEmpty) placed.add(PlacedText(x, y, text));
    }
  }
  return placed;
}

Map<int, String> _parseCMap(String cmapText) {
  final map = <int, String>{};
  String decode(String hex) {
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
      map[int.parse(m.group(1)!, radix: 16)] = decode(m.group(2)!);
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

/// The whole printed text of the job, spaces included.
String pdfText(Uint8List bytes) =>
    placedTexts(bytes).map((p) => p.text).join(' ');

/// The text-drawing operators of the job, after `FlateDecode`.
String contentStream(Uint8List bytes) {
  final raw = latin1.decode(bytes);
  final streamRe = RegExp(r'stream\r?\n(.*?)\r?\nendstream', dotAll: true);
  final buffer = StringBuffer();
  for (final match in streamRe.allMatches(raw)) {
    try {
      final text = utf8.decode(
        ZLibDecoder().convert(match.group(1)!.codeUnits),
        allowMalformed: true,
      );
      if (text.contains('Tf')) buffer.write(text);
    } catch (_) {}
  }
  return buffer.toString();
}

int occurrences(String text, String needle) =>
    RegExp(RegExp.escape(needle)).allMatches(text).length;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const generator = PrePrintedTicketPdfGenerator();
  final weighmentAt = DateTime(2026, 9, 10, 16, 27);
  final settings = BillingSettings(updatedAt: weighmentAt);

  Weighment weighment({
    double? charges = 4599.5,
    String? material = 'M-Sand',
  }) => Weighment(
    id: 7,
    billNumber: 'WB-00042',
    vehicleNumber: 'TN31CM2026',
    firstWeightKg: 100000,
    firstWeightType: 'GROSS',
    secondWeightKg: 20000,
    charges: charges,
    material: material,
    createdAt: weighmentAt,
    updatedAt: weighmentAt,
  );

  /// The 11 x 5.5 in continuous form as the driver reports it, with the
  /// printer's own printable-area offsets.
  const reported = PdfPageFormat(
    792,
    396,
    marginLeft: 18,
    marginRight: 18,
    marginTop: 18,
    marginBottom: 18,
  );

  /// The `[x y w h]` of the page's `/MediaBox`, as written by the generator.
  String mediaBox(Uint8List bytes) =>
      RegExp(
        r'/MediaBox\s*\[([^\]]*)\]',
      ).firstMatch(utf8.decode(bytes, allowMalformed: true))?.group(1) ??
      'missing';

  group('PrePrintedTicketPdfGenerator', () {
    test('builds one page for the paper the printer reported', () async {
      final bytes = await generator.generate(
        bill: weighment(),
        settings: settings,
        pageFormat: reported,
        printedAt: DateTime(2026, 10, 5, 9, 15),
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      expect(mediaBox(bytes), '0 0 792 396');

      // Both copies live on that single page: no second page, no second job.
      expect(utf8.decode(bytes, allowMalformed: true), contains('/Count 1'));
    });

    test(
      'honours a non-A4 sheet instead of assuming a fixed page size',
      () async {
        const odd = PdfPageFormat(
          612,
          420,
          marginLeft: 10,
          marginRight: 10,
          marginTop: 12,
          marginBottom: 12,
        );
        final bytes = await generator.generate(
          bill: weighment(),
          settings: settings,
          pageFormat: odd,
        );

        expect(mediaBox(bytes), '0 0 612 420');
      },
    );

    test(
      'prints every dynamic value exactly twice - the two identical copies',
      () async {
        final bytes = await generator.generate(
          bill: weighment(),
          settings: settings,
          pageFormat: reported,
        );
        final text = pdfText(bytes);
        expect(
          text,
          isNotEmpty,
          reason: 'the job must draw the weighment data',
        );

        for (final value in <String>[
          'WB-00042',
          'TN31CM2026',
          '10/09/2026',
          'M-Sand',
          '4,599.50',
          '100.000',
          '20.000',
          '80.000',
        ]) {
          expect(
            occurrences(text, value),
            2,
            reason: '"$value" must land in the left and the right copy',
          );
        }
      },
    );

    test(
      'never prints the letterhead - the stationery already carries it',
      () async {
        final bytes = await generator.generate(
          bill: weighment(),
          settings: settings,
          pageFormat: reported,
        );
        final text = pdfText(bytes);

        for (final prePrinted in <String>[
          'VIYAN WEIGHBRIDGE',
          'WEIGHMENT RECEIPT',
          'Computer Weigh Bridge',
          '24 HOURS SERVICE',
          'Weight Certificate',
          'SERIAL NO.',
          'VEHICLE NO.',
          'WT. CHARGES',
          'CUSTOMER',
          'Thank you',
        ]) {
          expect(
            text.contains(prePrinted),
            isFalse,
            reason:
                '"$prePrinted" is printed by HMB Enterprises, not by the app',
          );
        }
      },
    );

    test('leaves rows with no saved value completely blank', () async {
      final bytes = await generator.generate(
        bill: weighment(charges: null, material: null),
        settings: settings,
        pageFormat: reported,
      );
      final text = pdfText(bytes);

      // No placeholder, no dash, no fabricated figure.
      expect(text, isNot(contains('4,599.50')));
      expect(text, isNot(contains('M-Sand')));
      expect(occurrences(text, 'TN31CM2026'), 2);
    });

    test('draws at the configured character pitch (10 or 12 CPI)', () async {
      final at12 = await generator.generate(
        bill: weighment(),
        settings: settings,
        pageFormat: reported,
      );
      // 12 CPI = 6 pt advance = a 10 pt face.
      expect(contentStream(at12), matches(RegExp(r'\b10\b\s+Tf')));

      final at10 = await generator.generate(
        bill: weighment(),
        settings: settings.copyWith(printCpi: 10, printLpi: 8),
        pageFormat: reported,
      );
      // 10 CPI = 7.2 pt advance = a 12 pt face.
      expect(contentStream(at10), matches(RegExp(r'\b12\b\s+Tf')));
    });

    test('prints each field at its own configured size', () async {
      // Serial jumps to 14 pt, material shrinks to 9 pt - every other field
      // keeps its own default size from the grid.
      final grid = jsonEncode({
        'serial': {'c': 14, 'l': 0, 'w': 18, 'fs': 14, 'b': true},
        'material': {'c': 14, 'l': 3, 'w': 26, 'fs': 9, 'b': false},
      });
      final bytes = await generator.generate(
        bill: weighment(),
        settings: settings.copyWith(printFieldGrid: grid),
        pageFormat: reported,
      );
      final content = contentStream(bytes);

      expect(
        content,
        matches(RegExp(r'\b14\b\s+Tf')),
        reason: 'serial prints at its tuned 14 pt',
      );
      expect(
        content,
        matches(RegExp(r'\b9\b\s+Tf')),
        reason: 'material prints at its tuned 9 pt',
      );
      // Untouched fields keep their defaults, e.g. date at 10 pt.
      expect(content, matches(RegExp(r'\b10\b\s+Tf')));
    });

    test('a regular-weight field draws with the base font, not the bold one',
        () async {
      // One font resource per weight is registered on the page; a job whose
      // every field is bold references exactly one of them, while a job with
      // a regular field must reference both.
      Future<String> fontNamesOf(String gridJson) async {
        final bytes = await generator.generate(
          bill: weighment(),
          settings: settings.copyWith(printFieldGrid: gridJson),
          pageFormat: reported,
        );
        return RegExp(r'/F\d+\s+[\d.]+\s+Tf')
            .allMatches(contentStream(bytes))
            .map((m) => m.group(0)!)
            .toSet()
            .join('|');
      }

      // Every printable field bold, stacked on one line, with the material
      // row's weight switching between the two jobs.
      String grid({required bool materialBold}) => jsonEncode({
        for (final name in [
          'serial',
          'date',
          'time',
          'vehicle',
          'charges',
          'gross',
          'tare',
          'net',
        ])
          name: {'c': 0, 'l': 0, 'w': 0, 'fs': 10, 'b': true},
        'material': {'c': 0, 'l': 0, 'w': 0, 'fs': 10, 'b': materialBold},
      });

      final allBold = await fontNamesOf(grid(materialBold: true));
      final withRegular = await fontNamesOf(grid(materialBold: false));

      expect(allBold, isNotEmpty);
      expect(
        withRegular.split('|').length,
        greaterThan(allBold.split('|').length),
        reason: 'a regular field must add the base font to the job',
      );
    });

    test('places the two copies side by side on the same row', () async {
      final bytes = await generator.generate(
        bill: weighment(),
        settings: settings,
        pageFormat: reported,
      );
      final vehicle = placedTexts(
        bytes,
      ).where((p) => p.text.contains('TN31CM2026')).toList();
      expect(vehicle, hasLength(2), reason: 'one placement per copy');

      // Same physical row of the sheet, one column width apart.
      expect(vehicle[1].y, vehicle[0].y);
      final delta = vehicle[1].x - vehicle[0].x;
      expect(delta, greaterThan(0));
      expect(delta, closeTo(378, 0.01), reason: 'half the printable width');
    });
  });
}
