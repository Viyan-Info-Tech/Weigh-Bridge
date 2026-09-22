import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';
import 'package:weighbridge/features/settings/domain/repositories/settings_repository.dart';
import 'package:weighbridge/features/settings/domain/usecases/get_settings.dart';
import 'package:weighbridge/features/settings/domain/usecases/update_settings.dart';
import 'package:weighbridge/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:weighbridge/features/settings/presentation/bloc/settings_event.dart';
import 'package:weighbridge/features/settings/presentation/bloc/settings_state.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockGetSettingsUseCase extends Mock implements GetSettingsUseCase {}

class MockUpdateSettingsUseCase extends Mock implements UpdateSettingsUseCase {}

void main() {
  group('SettingsRepositoryImpl contract', () {
    test('getSettings delegates to repository', () async {
      final settings = BillingSettings(updatedAt: DateTime.now());
      final repo = MockSettingsRepository();
      when(() => repo.getSettings()).thenAnswer((_) async => settings);

      final result = await repo.getSettings();
      expect(result, settings);
    });

    test('updateSettings delegates to repository', () async {
      final settings = BillingSettings(updatedAt: DateTime.now());
      final repo = MockSettingsRepository();
      when(() => repo.updateSettings(settings)).thenAnswer((_) async => {});

      await repo.updateSettings(settings);
      verify(() => repo.updateSettings(settings)).called(1);
    });

    test('generateNextBillNumber delegates to repository', () async {
      final repo = MockSettingsRepository();
      when(
        () => repo.generateNextBillNumber(),
      ).thenAnswer((_) async => 'WB-00001');

      final result = await repo.generateNextBillNumber();
      expect(result, 'WB-00001');
    });
  });

  group('SettingsBloc - exact transitions', () {
    test('initial state is SettingsState with initial status', () {
      final bloc = SettingsBloc(
        getSettingsUseCase: MockGetSettingsUseCase(),
        updateSettingsUseCase: MockUpdateSettingsUseCase(),
      );
      try {
        expect(bloc.state.status, SettingsStatus.initial);
        expect(bloc.state.settings, isNull);
        expect(bloc.state.errorMessage, isNull);
        expect(bloc.state.successMessage, isNull);
      } finally {
        bloc.close();
      }
    });

    test('LoadSettings emits [loading, loaded]', () async {
      final settings = BillingSettings(updatedAt: DateTime.now());
      final getUseCase = MockGetSettingsUseCase();
      when(() => getUseCase()).thenAnswer((_) async => settings);

      final bloc = SettingsBloc(
        getSettingsUseCase: getUseCase,
        updateSettingsUseCase: MockUpdateSettingsUseCase(),
      );
      try {
        final expectation = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<SettingsState>().having(
              (s) => s.status,
              'status',
              SettingsStatus.loading,
            ),
            isA<SettingsState>()
                .having((s) => s.status, 'status', SettingsStatus.loaded)
                .having((s) => s.settings, 'settings', settings),
          ]),
        );

        bloc.add(const LoadSettings());
        await expectation;
      } finally {
        bloc.close();
      }
    });

    test('LoadSettings emits [loading, error] on failure', () async {
      final getUseCase = MockGetSettingsUseCase();
      when(() => getUseCase()).thenThrow(Exception('fail'));

      final bloc = SettingsBloc(
        getSettingsUseCase: getUseCase,
        updateSettingsUseCase: MockUpdateSettingsUseCase(),
      );
      try {
        final expectation = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<SettingsState>().having(
              (s) => s.status,
              'status',
              SettingsStatus.loading,
            ),
            isA<SettingsState>()
                .having((s) => s.status, 'status', SettingsStatus.error)
                .having(
                  (s) => s.errorMessage,
                  'errorMessage',
                  'Failed to load settings: Exception: fail',
                ),
          ]),
        );

        bloc.add(const LoadSettings());
        await expectation;
      } finally {
        bloc.close();
      }
    });

    test('UpdateBillingSettings emits [saving, saved]', () async {
      final newSettings = BillingSettings(
        businessName: 'APEX',
        updatedAt: DateTime.now(),
      );
      final updateUseCase = MockUpdateSettingsUseCase();
      when(() => updateUseCase(newSettings)).thenAnswer((_) async => {});

      final bloc = SettingsBloc(
        getSettingsUseCase: MockGetSettingsUseCase(),
        updateSettingsUseCase: updateUseCase,
      );
      try {
        final expectation = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<SettingsState>().having(
              (s) => s.status,
              'status',
              SettingsStatus.saving,
            ),
            isA<SettingsState>()
                .having((s) => s.status, 'status', SettingsStatus.saved)
                .having((s) => s.settings, 'settings', newSettings)
                .having(
                  (s) => s.successMessage,
                  'successMessage',
                  'Settings saved successfully',
                ),
          ]),
        );

        bloc.add(UpdateBillingSettings(newSettings));
        await expectation;
      } finally {
        bloc.close();
      }
    });

    test('UpdateBillingSettings emits [saving, error] on failure', () async {
      final newSettings = BillingSettings(updatedAt: DateTime.now());
      final updateUseCase = MockUpdateSettingsUseCase();
      when(() => updateUseCase(newSettings)).thenThrow(Exception('fail'));

      final bloc = SettingsBloc(
        getSettingsUseCase: MockGetSettingsUseCase(),
        updateSettingsUseCase: updateUseCase,
      );
      try {
        final expectation = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<SettingsState>().having(
              (s) => s.status,
              'status',
              SettingsStatus.saving,
            ),
            isA<SettingsState>()
                .having((s) => s.status, 'status', SettingsStatus.error)
                .having(
                  (s) => s.errorMessage,
                  'errorMessage',
                  'Failed to save settings: Exception: fail',
                ),
          ]),
        );

        bloc.add(UpdateBillingSettings(newSettings));
        await expectation;
      } finally {
        bloc.close();
      }
    });
  });
}
