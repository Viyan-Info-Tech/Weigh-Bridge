import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/services/preprinted_ticket_layout.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';

void main() {
  final weighmentAt = DateTime(2026, 9, 10, 16, 27);

  Weighment bill({
    String billNumber = 'WB-00042',
    String vehicleNumber = 'TN31CM2026',
    double grossWeightKg = 100000,
    double? secondWeightKg = 20000,
    double? netWeightKg,
    double? charges = 250.5,
    String? material = 'Cement',
    String? remarks,
  }) => Weighment(
    id: 1,
    billNumber: billNumber,
    vehicleNumber: vehicleNumber,
    firstWeightKg: grossWeightKg,
    firstWeightType: 'GROSS',
    secondWeightKg: secondWeightKg,
    netWeightKg: netWeightKg,
    charges: charges,
    material: material,
    remarks: remarks,
    createdAt: weighmentAt,
    updatedAt: weighmentAt,
  );

  BillingSettings settingsWith({String? printFieldGrid, int? printCpi}) =>
      BillingSettings(
        updatedAt: weighmentAt,
        printFieldGrid: printFieldGrid,
        printCpi: printCpi ?? 12,
      );

  /// The 11 x 5.5 in continuous form with typical dot-matrix margins.
  const sheet = PdfPageFormat(
    792,
    396,
    marginLeft: 18,
    marginRight: 18,
    marginTop: 18,
    marginBottom: 18,
  );

  group('PrePrintedField grid', () {
    test('every dynamic field carries the label printed on the stationery', () {
      expect(PrePrintedField.serial.prePrintedLabel, 'SERIAL NO.');
      expect(PrePrintedField.vehicle.prePrintedLabel, 'VEHICLE NO.');
      expect(PrePrintedField.charges.prePrintedLabel, 'WT. CHARGES (Rs.)');
      expect(PrePrintedField.material.prePrintedLabel, 'MATERIAL');
      expect(PrePrintedField.gross.prePrintedLabel, 'GROSS');
      expect(PrePrintedField.tare.prePrintedLabel, 'TARE');
      expect(PrePrintedField.net.prePrintedLabel, 'Nett');
      expect(PrePrintedField.customer.prePrintedLabel, 'CUSTOMER');

      // Nothing that is already printed by HMB Enterprises is part of the
      // enum, so the app can never draw it: no logo, name, address, heading,
      // border or footer.
      final labels = PrePrintedField.values
          .map((f) => f.prePrintedLabel.toLowerCase())
          .join('|');
      expect(labels, isNot(contains('logo')));
      expect(labels, isNot(contains('address')));
      expect(labels, isNot(contains('certificate')));
    });

    test(
      'an absent or malformed persisted grid falls back to the defaults',
      () {
        for (final raw in <String?>[
          null,
          '',
          '   ',
          'not json',
          '[1,2,3]',
          '{"vehicle":"oops"}',
        ]) {
          expect(
            decodePrePrintedGrid(raw),
            kDefaultPrePrintedGrid,
            reason: 'raw grid "$raw" must never break a print job',
          );
        }
      },
    );

    test('a partial grid overrides only the fields it mentions', () {
      final grid = decodePrePrintedGrid('{"vehicle":{"c":18,"l":1,"w":20}}');

      // The stored entry mentions only position/width, so the vehicle keeps
      // its default size (12) and weight (bold).
      expect(
        grid[PrePrintedField.vehicle],
        const PrePrintedFieldPlacement(
          column: 18,
          line: 1,
          widthChars: 20,
          fontSize: 12,
          isBold: true,
        ),
      );
      expect(
        grid[PrePrintedField.serial],
        kDefaultPrePrintedGrid[PrePrintedField.serial],
      );
      expect(grid, hasLength(PrePrintedField.values.length));
    });

    test('every default field carries its own size and weight', () {
      const expected = {
        PrePrintedField.serial: (12.0, true),
        PrePrintedField.date: (10.0, true),
        PrePrintedField.time: (10.0, true),
        PrePrintedField.vehicle: (12.0, true),
        PrePrintedField.charges: (11.0, true),
        PrePrintedField.material: (10.0, false),
        PrePrintedField.gross: (12.0, true),
        PrePrintedField.tare: (12.0, true),
        PrePrintedField.net: (12.0, true),
        PrePrintedField.customer: (10.0, false),
      };

      for (final entry in expected.entries) {
        final placement = kDefaultPrePrintedGrid[entry.key]!;
        expect(placement.fontSize, entry.value.$1, reason: '${entry.key}');
        expect(placement.isBold, entry.value.$2, reason: '${entry.key}');
      }
    });

    test('font size and bold survive the encode/decode round trip', () {
      final edited = Map<PrePrintedField, PrePrintedFieldPlacement>.from(
        kDefaultPrePrintedGrid,
      );
      edited[PrePrintedField.vehicle] = const PrePrintedFieldPlacement(
        column: 14,
        line: 1,
        widthChars: 22,
        fontSize: 14,
        isBold: false,
      );

      final decoded = decodePrePrintedGrid(encodePrePrintedGrid(edited));
      expect(decoded[PrePrintedField.vehicle], edited[PrePrintedField.vehicle]);
      expect(decoded[PrePrintedField.serial]?.fontSize, 12);
    });

    test('a grid stored before sizing existed falls back to the defaults', () {
      // Legacy JSON carried only c/l/w; the mentioned field now resolves its
      // size and weight from the same defaults a fresh grid gets.
      final grid = decodePrePrintedGrid('{"material":{"c":14,"l":3,"w":26}}');

      expect(grid[PrePrintedField.material]!.fontSize, 10);
      expect(grid[PrePrintedField.material]!.isBold, isFalse);
    });

    test('encode and decode round-trip the operator\'s alignment', () {
      final edited = Map<PrePrintedField, PrePrintedFieldPlacement>.from(
        kDefaultPrePrintedGrid,
      );
      edited[PrePrintedField.charges] = const PrePrintedFieldPlacement(
        column: 22,
        line: 2,
        widthChars: 14,
      );
      edited[PrePrintedField.customer] = const PrePrintedFieldPlacement(
        column: -1,
        line: -1,
      );

      final decoded = decodePrePrintedGrid(encodePrePrintedGrid(edited));
      expect(decoded, edited);
      expect(decoded[PrePrintedField.customer]!.isPrintable, isFalse);
    });

    test('a negative column or line disables that field', () {
      final placement = const PrePrintedFieldPlacement(column: -1, line: 3);
      expect(placement.isPrintable, isFalse);
      expect(
        const PrePrintedFieldPlacement(column: 3, line: -1).isPrintable,
        isFalse,
      );
      expect(
        const PrePrintedFieldPlacement(column: 0, line: 0).isPrintable,
        isTrue,
      );
    });
  });

  group('PrePrintedTicketData values', () {
    final data = PrePrintedTicketData(
      bill: bill(),
      settings: settingsWith(),
      printedAt: DateTime(2026, 10, 5, 9, 15),
    );

    test('reads every value from the saved weighment record', () {
      expect(data.valueFor(PrePrintedField.serial), 'WB-00042');
      expect(data.valueFor(PrePrintedField.vehicle), 'TN31CM2026');
      expect(data.valueFor(PrePrintedField.material), 'Cement');
      expect(data.valueFor(PrePrintedField.charges), '250.50');
      expect(data.valueFor(PrePrintedField.gross), '100.000 ton');
      expect(data.valueFor(PrePrintedField.tare), '20.000 ton');
      expect(data.valueFor(PrePrintedField.net), '80.000 ton');
    });

    test(
      'uses the weighment\'s own date and time, never the re-print time',
      () {
        expect(data.dateText, '10/09/2026');
        expect(data.timeText, '16:27:00');
        expect(data.weighmentAt, weighmentAt);
      },
    );

    test('leaves the CUSTOMER row blank - there is no customer source', () {
      expect(data.valueFor(PrePrintedField.customer), '');
    });

    test(
      'leaves rows with no value blank instead of printing a placeholder',
      () {
        final legacy = PrePrintedTicketData(
          bill: bill(charges: null, material: null),
          settings: settingsWith(),
        );
        expect(legacy.valueFor(PrePrintedField.charges), '');
        expect(legacy.valueFor(PrePrintedField.material), '');
        expect(legacy.valueFor(PrePrintedField.customer), '');
      },
    );

    test('drops the unit when the pre-printed paper already carries it', () {
      final bare = PrePrintedTicketData(
        bill: bill(),
        settings: settingsWith().copyWith(printWeightUnit: false),
      );
      expect(bare.valueFor(PrePrintedField.gross), '100.000');
      expect(bare.valueFor(PrePrintedField.tare), '20.000');
      expect(bare.valueFor(PrePrintedField.net), '80.000');
    });
  });

  group('PrePrintedTicketLayout', () {
    test('places both identical copies on one horizontal row', () {
      final settings = settingsWith();
      final layout = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settings,
      );
      final texts = layout.buildPrintedTexts(
        PrePrintedTicketData(bill: bill(), settings: settings),
      );

      const printable = [
        PrePrintedField.serial,
        PrePrintedField.date,
        PrePrintedField.time,
        PrePrintedField.vehicle,
        PrePrintedField.charges,
        PrePrintedField.material,
        PrePrintedField.gross,
        PrePrintedField.tare,
        PrePrintedField.net,
      ];

      for (final field in printable) {
        final copies = texts.where((t) => t.field == field).toList()
          ..sort((a, b) => a.copy.compareTo(b.copy));

        expect(copies, hasLength(2), reason: '$field must print twice');
        expect(copies.first.copy, 0, reason: 'left section first');
        expect(copies.last.copy, 1, reason: 'right section second');

        // Identical values, identical vertical position - one print job, one
        // row of the continuous form.
        expect(copies.last.text, copies.first.text);
        expect(copies.last.y, copies.first.y);
        expect(
          copies.last.x - copies.first.x,
          closeTo(layout.columnWidth, 0.001),
          reason: 'the right copy starts one column width along',
        );

        // Everything stays inside the reported sheet.
        expect(copies.first.x, greaterThanOrEqualTo(0));
        expect(copies.last.x, lessThan(sheet.width));
        expect(copies.first.y, inInclusiveRange(0, sheet.height));
      }

      // Both sections share the same origin row.
      expect(layout.copyOriginY, 18);
      expect(layout.copyOriginX(0), 18);
      expect(layout.copyOriginX(1), 18 + layout.columnWidth);
      expect(layout.columnWidth, closeTo(378, 0.001));

      // The CUSTOMER row carries no data, so nothing is drawn for it.
      expect(texts.where((t) => t.field == PrePrintedField.customer), isEmpty);
    });

    test('a disabled field is never printed', () {
      final settings = settingsWith(
        printFieldGrid: '{"vehicle":{"c":-1,"l":-1,"w":0}}',
      );
      final layout = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settings,
      );
      final texts = layout.buildPrintedTexts(
        PrePrintedTicketData(bill: bill(), settings: settings),
      );

      expect(texts.where((t) => t.field == PrePrintedField.vehicle), isEmpty);
      // Every other field still prints twice.
      expect(
        texts.where((t) => t.field == PrePrintedField.serial),
        hasLength(2),
      );
    });

    test('a field with no charge value leaves its row untouched', () {
      final settings = settingsWith();
      final layout = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settings,
      );
      final texts = layout.buildPrintedTexts(
        PrePrintedTicketData(bill: bill(charges: null), settings: settings),
      );

      expect(texts.where((t) => t.field == PrePrintedField.charges), isEmpty);
    });

    test('a value that would land off the sheet is dropped, not clipped', () {
      final settings = settingsWith(
        // Line 100 is far below a 5.5 in sheet; column 300 is far right of it.
        printFieldGrid:
            '{"serial":{"c":14,"l":100,"w":18},"material":{"c":300,"l":3,'
            '"w":26}}',
      );
      final layout = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settings,
      );
      final texts = layout.buildPrintedTexts(
        PrePrintedTicketData(bill: bill(), settings: settings),
      );

      expect(texts.where((t) => t.field == PrePrintedField.serial), isEmpty);
      expect(texts.where((t) => t.field == PrePrintedField.material), isEmpty);
      expect(
        texts.where((t) => t.field == PrePrintedField.vehicle),
        hasLength(2),
      );
    });

    test('10 CPI and 12 CPI produce the right character and line pitch', () {
      final at12 = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settingsWith(printCpi: 12),
      );
      expect(at12.cpi, 12);
      expect(at12.charWidth, closeTo(6.0, 0.0001));
      expect(at12.linePitch, closeTo(12.0, 0.0001)); // 6 LPI
      expect(at12.fontSize, closeTo(10.0, 0.0001));

      final at10 = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settingsWith(printCpi: 10),
      );
      expect(at10.cpi, 10);
      expect(at10.charWidth, closeTo(7.2, 0.0001));
      expect(at10.fontSize, closeTo(12.0, 0.0001));
      expect(at10.columnWidthChars, closeTo(53, 1));

      // One character step really is one character wide.
      final settings = settingsWith();
      final layout = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settings,
      );
      final texts = layout.buildPrintedTexts(
        PrePrintedTicketData(bill: bill(), settings: settings),
      );
      final serial = texts.firstWhere((t) => t.field == PrePrintedField.serial);
      final vehicle = texts.firstWhere(
        (t) => t.field == PrePrintedField.vehicle,
      );
      expect(vehicle.x, serial.x);
      expect(vehicle.y - serial.y, closeTo(layout.linePitch, 0.0001));
    });

    test('an unusable pitch falls back to 12 CPI / 6 LPI', () {
      final layout = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: BillingSettings(
          updatedAt: weighmentAt,
          printCpi: 0,
          printLpi: -5,
        ),
      );
      expect(layout.usedFallbackPitch, isTrue);
      expect(layout.cpi, 12);
      expect(layout.lpi, 6);
      expect(layout.fontSize, closeTo(10.0, 0.0001));
    });

    test('every printed value carries its own configured size and weight', () {
      final settings = settingsWith();
      final layout = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settings,
      );
      final texts = layout.buildPrintedTexts(
        PrePrintedTicketData(bill: bill(), settings: settings),
      );

      // Both copies of a field always share the same size and weight.
      for (final field in PrePrintedField.values) {
        final copies = texts.where((t) => t.field == field).toList();
        if (copies.isEmpty) continue;
        expect(copies, hasLength(2), reason: '$field must print twice');
        expect(copies.last.fontSize, copies.first.fontSize, reason: '$field');
        expect(copies.last.isBold, copies.first.isBold, reason: '$field');
      }

      double sizeOf(PrePrintedField field) =>
          texts.firstWhere((t) => t.field == field).fontSize;
      bool boldOf(PrePrintedField field) =>
          texts.firstWhere((t) => t.field == field).isBold;

      expect(sizeOf(PrePrintedField.serial), 12);
      expect(sizeOf(PrePrintedField.date), 10);
      expect(sizeOf(PrePrintedField.vehicle), 12);
      expect(sizeOf(PrePrintedField.charges), 11);
      expect(sizeOf(PrePrintedField.material), 10);
      expect(sizeOf(PrePrintedField.gross), 12);
      expect(boldOf(PrePrintedField.serial), isTrue);
      expect(boldOf(PrePrintedField.material), isFalse);
    });

    test('a tuned size and weight reach both copies of that field', () {
      final settings = settingsWith(
        printFieldGrid:
            '{"vehicle":{"c":14,"l":1,"w":22,"fs":14,"b":false},'
            '"material":{"c":14,"l":3,"w":26,"fs":9,"b":true}}',
      );
      final layout = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settings,
      );
      final texts = layout.buildPrintedTexts(
        PrePrintedTicketData(bill: bill(), settings: settings),
      );

      final vehicle = texts.where((t) => t.field == PrePrintedField.vehicle);
      expect(vehicle.map((t) => t.fontSize), [14.0, 14.0]);
      expect(vehicle.map((t) => t.isBold), [false, false]);

      final material = texts.where((t) => t.field == PrePrintedField.material);
      expect(material.map((t) => t.fontSize), [9.0, 9.0]);
      expect(material.map((t) => t.isBold), [true, true]);
    });

    test('a field without an explicit size falls back to the pitch size', () {
      final layout = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settingsWith(),
      );
      expect(
        layout.fontSizeFor(const PrePrintedFieldPlacement(column: 1, line: 1)),
        closeTo(layout.fontSize, 0.0001),
      );
      expect(
        layout.fontSizeFor(
          const PrePrintedFieldPlacement(column: 1, line: 1, fontSize: 14),
        ),
        14,
      );
    });

    test('a configured column width wins over half the printable width', () {
      final layout = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settingsWith().copyWith(printColumnWidthMm: 127.0),
      );
      expect(layout.columnWidth, closeTo(127.0 * mmToPoint, 0.001));
    });

    test('offsets nudge the whole grid from the printer\'s own margins', () {
      final layout = PrePrintedTicketLayout(
        pageFormat: sheet,
        settings: settingsWith().copyWith(
          printLeftOffsetMm: 2.0,
          printTopOffsetMm: 1.0,
        ),
      );
      expect(layout.printableLeft, closeTo(18 + 2.0 * mmToPoint, 0.001));
      expect(layout.printableTop, closeTo(18 + 1.0 * mmToPoint, 0.001));
      expect(layout.copyOriginX(0), layout.printableLeft);
      expect(layout.copyOriginY, layout.printableTop);
    });

    test('the hinted paper size is only used before the dialog answers', () {
      // No configured size: the standard continuous-form hint. The operator can
      // still pick any paper in the print dialog - the job is rebuilt from
      // whatever the driver finally reports.
      expect(
        PrePrintedTicketLayout.initialPaperFormat(settingsWith()).width,
        closeTo(10 * 72, 0.001),
      );
      expect(
        PrePrintedTicketLayout.initialPaperFormat(settingsWith()).height,
        closeTo(8 * 72, 0.001),
      );

      // A configured custom size is converted from millimetres to points.
      final custom = PrePrintedTicketLayout.initialPaperFormat(
        settingsWith().copyWith(
          printPaperWidthMm: 279.4,
          printPaperLengthMm: 140.0,
        ),
      );
      expect(custom.width, closeTo(792, 0.01));
      expect(custom.height, closeTo(396.85, 0.01));
    });
  });
}
