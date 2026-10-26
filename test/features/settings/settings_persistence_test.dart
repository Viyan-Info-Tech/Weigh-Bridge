import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/features/bill/domain/services/preprinted_ticket_layout.dart';
import 'package:weighbridge/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';

void main() {
  late AppDatabase db;
  late SettingsLocalDataSource dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = SettingsLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Settings persistence', () {
    test('getSettings returns defaults on fresh database', () async {
      final settings = await dataSource.getSettings();
      expect(settings.businessName, 'VIYAN WEIGHBRIDGE');
      expect(settings.billPrefix, 'WB');
      expect(settings.billStartingNumber, 1);
      expect(settings.billNumberDigits, 5);
      expect(settings.weightUnit, 'ton');
      expect(settings.receiptTitle, 'WEIGHMENT RECEIPT');
      expect(settings.showSerialNumber, isTrue);
      expect(settings.showGrossWeight, isTrue);
    });

    test('updateSettings persists in database', () async {
      await dataSource.getSettings();
      await dataSource.updateSettings(
        BillingSettings(
          businessName: 'Persisted Co',
          billPrefix: 'PC',
          billStartingNumber: 5,
          billNumberDigits: 4,
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );
      final settings = await dataSource.getSettings();
      expect(settings.businessName, 'Persisted Co');
      expect(settings.billPrefix, 'PC');
      expect(settings.billStartingNumber, 5);
      expect(settings.billNumberDigits, 4);
    });

    test('settings survive across multiple getSettings calls', () async {
      await dataSource.getSettings();
      await dataSource.updateSettings(
        BillingSettings(
          businessName: 'Stable',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );
      final first = await dataSource.getSettings();
      final second = await dataSource.getSettings();
      expect(first.businessName, second.businessName);
      expect(
        first.updatedAt.millisecondsSinceEpoch,
        second.updatedAt.millisecondsSinceEpoch,
      );
    });

    test('only one settings row exists', () async {
      await dataSource.getSettings();
      await dataSource.updateSettings(
        BillingSettings(
          businessName: 'Single',
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );
      await dataSource.updateSettings(
        BillingSettings(
          businessName: 'Second',
          updatedAt: DateTime.utc(2026, 2, 1),
        ),
      );
      final settings = await dataSource.getSettings();
      expect(settings.businessName, 'Second');
    });
  });

  group('Settings invalid values', () {
    test('updates with billPrefix up to 6 chars', () async {
      await dataSource.getSettings();
      await dataSource.updateSettings(
        BillingSettings(billPrefix: 'ABCDEF', updatedAt: DateTime.now()),
      );
      final settings = await dataSource.getSettings();
      expect(settings.billPrefix, 'ABCDEF');
    });

    test('updates with billNumberDigits 3', () async {
      await dataSource.getSettings();
      await dataSource.updateSettings(
        BillingSettings(billNumberDigits: 3, updatedAt: DateTime.now()),
      );
      final settings = await dataSource.getSettings();
      expect(settings.billNumberDigits, 3);
    });

    test('updates with billNumberDigits 10', () async {
      await dataSource.getSettings();
      await dataSource.updateSettings(
        BillingSettings(billNumberDigits: 10, updatedAt: DateTime.now()),
      );
      final settings = await dataSource.getSettings();
      expect(settings.billNumberDigits, 10);
    });

    test('updates with empty businessName', () async {
      await dataSource.getSettings();
      await dataSource.updateSettings(
        BillingSettings(businessName: '', updatedAt: DateTime.now()),
      );
      final settings = await dataSource.getSettings();
      expect(settings.businessName, '');
    });

    test('settings with null optional fields', () async {
      await dataSource.getSettings();
      await dataSource.updateSettings(
        BillingSettings(
          businessSubtitle: null,
          serviceText: null,
          address: null,
          phoneNumber: null,
          email: null,
          gstin: null,
          logoPath: null,
          footerNote: null,
          updatedAt: DateTime.now(),
        ),
      );
      final settings = await dataSource.getSettings();
      expect(settings.businessSubtitle, isNull);
      expect(settings.serviceText, isNull);
      expect(settings.address, isNull);
      expect(settings.phoneNumber, isNull);
      expect(settings.email, isNull);
      expect(settings.gstin, isNull);
      expect(settings.logoPath, isNull);
      expect(settings.footerNote, isNull);
    });
  });

  group('Continuous-form print settings', () {
    test('fresh database reads the documented print defaults', () async {
      final settings = await dataSource.getSettings();
      expect(settings.printCpi, 12);
      expect(settings.printLpi, 6);
      expect(settings.printPaperWidthMm, 0.0);
      expect(settings.printPaperLengthMm, 0.0);
      expect(settings.printLeftOffsetMm, 0.0);
      expect(settings.printTopOffsetMm, 0.0);
      expect(settings.printColumnWidthMm, 0.0);
      expect(settings.printFieldGrid, isNull);
      expect(settings.printRightFieldGrid, isNull);
      expect(settings.printWeightUnit, isTrue);
    });

    test('print alignment settings survive a save and reload', () async {
      const grid =
          '{"vehicle":{"c":18,"l":1,"w":20},"charges":{"c":20,"l":2,"w":14}}';
      await dataSource.getSettings();
      await dataSource.updateSettings(
        BillingSettings(
          printCpi: 10,
          printLpi: 8,
          printPaperWidthMm: 279.4,
          printPaperLengthMm: 140.0,
          printLeftOffsetMm: 1.5,
          printTopOffsetMm: 2.25,
          printColumnWidthMm: 139.7,
          printFieldGrid: grid,
          printWeightUnit: false,
          updatedAt: DateTime.utc(2026, 10, 1),
        ),
      );

      final settings = await dataSource.getSettings();
      expect(settings.printCpi, 10);
      expect(settings.printLpi, 8);
      expect(settings.printPaperWidthMm, 279.4);
      expect(settings.printPaperLengthMm, 140.0);
      expect(settings.printLeftOffsetMm, 1.5);
      expect(settings.printTopOffsetMm, 2.25);
      expect(settings.printColumnWidthMm, 139.7);
      expect(settings.printFieldGrid, grid);
      expect(settings.printWeightUnit, isFalse);
    });

    test('left and right grids persist separately and reload', () async {
      const left =
          '{"vehicle":{"c":18,"l":1,"w":20},"charges":{"c":20,"l":2,"w":14}}';
      const right = '{"vehicle":{"c":24,"l":4,"w":18,"fs":14,"b":false}}';
      await dataSource.getSettings();
      await dataSource.updateSettings(
        BillingSettings(
          printFieldGrid: left,
          printRightFieldGrid: right,
          updatedAt: DateTime.utc(2026, 10, 3),
        ),
      );

      final settings = await dataSource.getSettings();
      expect(settings.printFieldGrid, left);
      expect(settings.printRightFieldGrid, right);

      final leftGrid = decodePrePrintedGrid(settings.printFieldGrid);
      final rightGrid = decodePrePrintedGrid(settings.printRightFieldGrid);
      expect(leftGrid[PrePrintedField.vehicle]!.column, 18);
      expect(rightGrid[PrePrintedField.vehicle]!.column, 24);
      expect(rightGrid[PrePrintedField.vehicle]!.line, 4);
      expect(rightGrid[PrePrintedField.vehicle]!.fontSize, 14);
      expect(rightGrid[PrePrintedField.vehicle]!.isBold, isFalse);

      // Editing/reloading one grid must not mutate the other.
      expect(leftGrid[PrePrintedField.vehicle]!.line, 1);
      expect(leftGrid[PrePrintedField.vehicle]!.isBold, isTrue);
      expect(
        rightGrid[PrePrintedField.charges],
        kDefaultPrePrintedGrid[PrePrintedField.charges],
      );
    });

    test(
      'a legacy row with only a left grid keeps both copies aligned',
      () async {
        const legacy =
            '{"vehicle":{"c":18,"l":2,"w":20},"customer":{"c":-1,"l":-1,'
            '"w":0}}';
        await dataSource.getSettings();
        await dataSource.updateSettings(
          BillingSettings(
            printFieldGrid: legacy,
            updatedAt: DateTime.utc(2026, 10, 4),
          ),
        );

        final settings = await dataSource.getSettings();
        expect(settings.printRightFieldGrid, isNull);
        final rightGrid = decodePrePrintedGrid(
          settings.printRightFieldGrid ?? settings.printFieldGrid,
        );
        expect(
          rightGrid[PrePrintedField.vehicle],
          decodePrePrintedGrid(legacy)[PrePrintedField.vehicle],
        );
        expect(rightGrid[PrePrintedField.customer]!.isPrintable, isFalse);
      },
    );

    test('a saved grid still decodes into field placements', () async {
      await dataSource.getSettings();
      await dataSource.updateSettings(
        BillingSettings(
          printFieldGrid:
              '{"vehicle":{"c":18,"l":1,"w":20},"customer":{"c":-1,"l":-1,'
              '"w":0}}',
          updatedAt: DateTime.utc(2026, 10, 2),
        ),
      );

      final settings = await dataSource.getSettings();
      final grid = decodePrePrintedGrid(settings.printFieldGrid);
      // The stored entry carries position only, so the vehicle keeps its
      // default size (12) and weight (bold).
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
      // Fields the operator disabled stay disabled across persistence.
      expect(grid[PrePrintedField.customer]!.isPrintable, isFalse);
      // Everything else keeps its default position.
      expect(
        grid[PrePrintedField.serial],
        kDefaultPrePrintedGrid[PrePrintedField.serial],
      );
    });
  });
}
