import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';
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
}
