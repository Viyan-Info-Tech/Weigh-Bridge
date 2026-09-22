import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:weighbridge/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';

class MockSettingsLocalDataSource extends Mock
    implements SettingsLocalDataSource {}

void main() {
  late SettingsRepositoryImpl repo;
  late MockSettingsLocalDataSource mockLocalDs;

  setUp(() {
    mockLocalDs = MockSettingsLocalDataSource();
    repo = SettingsRepositoryImpl(localDataSource: mockLocalDs);
  });

  group('SettingsRepositoryImpl - delegates to data source', () {
    test('getSettings delegates to local data source', () async {
      final settings = BillingSettings(
        businessName: 'Test',
        updatedAt: DateTime.now(),
      );
      when(() => mockLocalDs.getSettings()).thenAnswer((_) async => settings);

      final result = await repo.getSettings();
      expect(result, settings);
      verify(() => mockLocalDs.getSettings()).called(1);
    });

    test('updateSettings delegates to local data source', () async {
      final settings = BillingSettings(
        businessName: 'Updated',
        updatedAt: DateTime.now(),
      );
      when(
        () => mockLocalDs.updateSettings(settings),
      ).thenAnswer((_) async => {});

      await repo.updateSettings(settings);
      verify(() => mockLocalDs.updateSettings(settings)).called(1);
    });

    test('generateNextBillNumber delegates to local data source', () async {
      when(
        () => mockLocalDs.generateNextBillNumber(),
      ).thenAnswer((_) async => 'WB-00001');

      final result = await repo.generateNextBillNumber();
      expect(result, 'WB-00001');
      verify(() => mockLocalDs.generateNextBillNumber()).called(1);
    });

    test('getSettings propagates errors', () async {
      when(() => mockLocalDs.getSettings()).thenThrow(Exception('error'));
      expect(repo.getSettings(), throwsA(isA<Exception>()));
    });

    test('updateSettings propagates errors', () async {
      final settings = BillingSettings(updatedAt: DateTime.now());
      when(
        () => mockLocalDs.updateSettings(settings),
      ).thenThrow(Exception('error'));
      expect(repo.updateSettings(settings), throwsA(isA<Exception>()));
    });
  });
}
