import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

import '../../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createInMemoryDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('AppSettingsDao', () {
    test('getSettings creates and returns the default settings', () async {
      final settings = await db.appSettingsDao.getSettings();
      expect(settings.billPrefix, 'WB');
      expect(settings.billStartingNumber, 1);
      expect(settings.billNumberDigits, 5);
      expect(settings.businessName, 'VIYAN WEIGHBRIDGE');
      expect(settings.receiptTitle, 'WEIGHMENT RECEIPT');
      expect(settings.weightUnit, 'ton');
      expect(settings.showSerialNumber, isTrue);
      expect(settings.showFooterNote, isTrue);
    });

    test('getSettings returns the same single row repeatedly', () async {
      final first = await db.appSettingsDao.getSettings();
      final second = await db.appSettingsDao.getSettings();
      final all = await db
          .customSelect('SELECT COUNT(*) AS c FROM app_settings')
          .get();
      expect(first.id, second.id);
      expect(all.single.data['c'], 1);
    });

    test('updateSettings persists changes', () async {
      await db.appSettingsDao.getSettings();
      await db.appSettingsDao.updateSettings(
        const AppSettingsCompanion(
          billPrefix: Value('RW'),
          billNumberDigits: Value(4),
          businessName: Value('Railway Weighbridge'),
          showFooterNote: Value(false),
        ),
      );

      final settings = await db.appSettingsDao.getSettings();
      expect(settings.billPrefix, 'RW');
      expect(settings.billNumberDigits, 4);
      expect(settings.businessName, 'Railway Weighbridge');
      expect(settings.showFooterNote, isFalse);
      expect(settings.showSerialNumber, isTrue);
    });

    test('updateSettings inserts when no settings row exists', () async {
      await db.appSettingsDao.updateSettings(
        const AppSettingsCompanion(billPrefix: Value('XX')),
      );
      final existing = await db.appSettingsDao.getSettings();
      expect(existing.billPrefix, 'XX');
      expect(existing.businessName, 'VIYAN WEIGHBRIDGE');
    });

    group('generateNextBillNumber', () {
      test('starts at the configured starting number', () async {
        final billNumber = await db.appSettingsDao.generateNextBillNumber(
          prefix: 'WB',
          digits: 5,
          startingNumber: 7,
        );
        expect(billNumber, 'WB-00007');
      });

      test('defaults the start to 1 when not provided', () async {
        final billNumber = await db.appSettingsDao.generateNextBillNumber(
          prefix: 'WB',
          digits: 5,
        );
        expect(billNumber, 'WB-00001');
      });

      test('increments beyond the highest existing number', () async {
        await seedWeighment(db, billNumber: 'WB-00008');

        final billNumber = await db.appSettingsDao.generateNextBillNumber(
          prefix: 'WB',
          digits: 5,
          startingNumber: 1,
        );
        expect(billNumber, 'WB-00009');
      });

      test(
        'clamps to starting number when existing numbers are lower',
        () async {
          final billNumber = await db.appSettingsDao.generateNextBillNumber(
            prefix: 'WB',
            digits: 5,
            startingNumber: 100,
          );
          expect(billNumber, 'WB-00100');
        },
      );

      test('pads to the configured number of digits', () async {
        final billNumber = await db.appSettingsDao.generateNextBillNumber(
          prefix: 'RM',
          digits: 3,
          startingNumber: 3,
        );
        expect(billNumber, 'RM-003');
      });
    });
  });
}
