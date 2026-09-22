import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';
import 'package:weighbridge/features/settings/domain/repositories/settings_repository.dart';
import 'package:weighbridge/features/settings/domain/usecases/get_settings.dart';
import 'package:weighbridge/features/settings/domain/usecases/update_settings.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late GetSettingsUseCase getSettingsUseCase;
  late UpdateSettingsUseCase updateSettingsUseCase;
  late MockSettingsRepository mockRepo;

  setUp(() {
    mockRepo = MockSettingsRepository();
    getSettingsUseCase = GetSettingsUseCase(mockRepo);
    updateSettingsUseCase = UpdateSettingsUseCase(mockRepo);
  });

  group('GetSettingsUseCase', () {
    test('calls repository.getSettings', () async {
      final settings = BillingSettings(updatedAt: DateTime.now());
      when(() => mockRepo.getSettings()).thenAnswer((_) async => settings);

      final result = await getSettingsUseCase();

      expect(result, settings);
      verify(() => mockRepo.getSettings()).called(1);
    });

    test('propagates repository errors', () async {
      when(() => mockRepo.getSettings()).thenThrow(Exception('db error'));
      expect(getSettingsUseCase(), throwsA(isA<Exception>()));
    });
  });

  group('UpdateSettingsUseCase', () {
    test('calls repository.updateSettings', () async {
      final settings = BillingSettings(
        businessName: 'New Name',
        updatedAt: DateTime.now(),
      );
      when(() => mockRepo.updateSettings(settings)).thenAnswer((_) async => {});

      await updateSettingsUseCase(settings);

      verify(() => mockRepo.updateSettings(settings)).called(1);
    });

    test('propagates repository errors', () async {
      final settings = BillingSettings(updatedAt: DateTime.now());
      when(
        () => mockRepo.updateSettings(settings),
      ).thenThrow(Exception('db error'));
      expect(updateSettingsUseCase(settings), throwsA(isA<Exception>()));
    });
  });
}
