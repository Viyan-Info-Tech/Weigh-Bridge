import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:weighbridge/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';

class MockSettingsLocalDataSource extends Mock
    implements SettingsLocalDataSource {}

class FakeBillingSettings extends Fake implements BillingSettings {}

void main() {
  late SettingsRepositoryImpl repo;
  late MockSettingsLocalDataSource mockLocalDs;

  setUpAll(() {
    registerFallbackValue(FakeBillingSettings());
  });

  setUp(() {
    mockLocalDs = MockSettingsLocalDataSource();
    repo = SettingsRepositoryImpl(localDataSource: mockLocalDs);
  });

  group('SettingsRepositoryImpl - edge values', () {
    test('billPrefix with single character', () async {
      when(
        () => mockLocalDs.getSettings(),
      ).thenAnswer((_) async => BillingSettings(updatedAt: DateTime.now()));
      when(() => mockLocalDs.updateSettings(any())).thenAnswer((_) async => {});
      await repo.updateSettings(
        BillingSettings(billPrefix: 'X', updatedAt: DateTime.now()),
      );
      verify(() => mockLocalDs.updateSettings(any())).called(1);
    });

    test('billPrefix with 6 characters', () async {
      when(
        () => mockLocalDs.getSettings(),
      ).thenAnswer((_) async => BillingSettings(updatedAt: DateTime.now()));
      when(() => mockLocalDs.updateSettings(any())).thenAnswer((_) async => {});
      await repo.updateSettings(
        BillingSettings(billPrefix: 'ABCDEF', updatedAt: DateTime.now()),
      );
      verify(() => mockLocalDs.updateSettings(any())).called(1);
    });

    test('billStartingNumber 1 minimum', () async {
      when(
        () => mockLocalDs.getSettings(),
      ).thenAnswer((_) async => BillingSettings(updatedAt: DateTime.now()));
      when(() => mockLocalDs.updateSettings(any())).thenAnswer((_) async => {});
      await repo.updateSettings(
        BillingSettings(billStartingNumber: 1, updatedAt: DateTime.now()),
      );
      verify(() => mockLocalDs.updateSettings(any())).called(1);
    });

    test('billStartingNumber large number', () async {
      when(
        () => mockLocalDs.getSettings(),
      ).thenAnswer((_) async => BillingSettings(updatedAt: DateTime.now()));
      when(() => mockLocalDs.updateSettings(any())).thenAnswer((_) async => {});
      await repo.updateSettings(
        BillingSettings(billStartingNumber: 999999, updatedAt: DateTime.now()),
      );
      verify(() => mockLocalDs.updateSettings(any())).called(1);
    });

    test('billNumberDigits 3 minimum', () async {
      when(
        () => mockLocalDs.getSettings(),
      ).thenAnswer((_) async => BillingSettings(updatedAt: DateTime.now()));
      when(() => mockLocalDs.updateSettings(any())).thenAnswer((_) async => {});
      await repo.updateSettings(
        BillingSettings(billNumberDigits: 3, updatedAt: DateTime.now()),
      );
      verify(() => mockLocalDs.updateSettings(any())).called(1);
    });

    test('billNumberDigits 10 maximum', () async {
      when(
        () => mockLocalDs.getSettings(),
      ).thenAnswer((_) async => BillingSettings(updatedAt: DateTime.now()));
      when(() => mockLocalDs.updateSettings(any())).thenAnswer((_) async => {});
      await repo.updateSettings(
        BillingSettings(billNumberDigits: 10, updatedAt: DateTime.now()),
      );
      verify(() => mockLocalDs.updateSettings(any())).called(1);
    });

    test('empty business name', () async {
      when(
        () => mockLocalDs.getSettings(),
      ).thenAnswer((_) async => BillingSettings(updatedAt: DateTime.now()));
      when(() => mockLocalDs.updateSettings(any())).thenAnswer((_) async => {});
      await repo.updateSettings(
        BillingSettings(businessName: '', updatedAt: DateTime.now()),
      );
      verify(() => mockLocalDs.updateSettings(any())).called(1);
    });

    test('all show flags false', () async {
      final customSettings = BillingSettings(
        showSerialNumber: false,
        showDate: false,
        showTime: false,
        showVehicleNumber: false,
        showMaterial: false,
        showCustomer: false,
        showGrossWeight: false,
        showTareWeight: false,
        showNetWeight: false,
        showAmount: false,
        showPaymentMode: false,
        showCashReceived: false,
        showRemarks: false,
        showFooterNote: false,
        updatedAt: DateTime.now(),
      );
      when(
        () => mockLocalDs.getSettings(),
      ).thenAnswer((_) async => customSettings);
      when(() => mockLocalDs.updateSettings(any())).thenAnswer((_) async => {});
      await repo.updateSettings(customSettings);
      final settings = await repo.getSettings();
      expect(settings.showSerialNumber, isFalse);
      expect(settings.showFooterNote, isFalse);
    });
  });
}
