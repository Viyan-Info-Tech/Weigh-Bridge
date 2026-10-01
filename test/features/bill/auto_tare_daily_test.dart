import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/auto_tare_entry.dart';
import 'package:weighbridge/features/bill/domain/repositories/auto_tare_repository.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/customer/domain/repositories/customer_repository.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

class MockAutoTareRepository extends Mock implements AutoTareRepository {}

/// In-memory stand-in with the same day-isolation rules as the real database.
class FakeAutoTareRepository implements AutoTareRepository {
  final Map<DateTime, double> _byDay = {};

  static DateTime day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Future<AutoTareEntry?> getAutoTare(DateTime date) async {
    final tareKg = _byDay[day(date)];
    if (tareKg == null) return null;
    return AutoTareEntry(tareDate: day(date), tareKg: tareKg);
  }

  @override
  Future<AutoTareEntry> saveAutoTare({
    required DateTime date,
    required double tareKg,
    DateTime? savedAt,
  }) async {
    _byDay[day(date)] = tareKg;
    final now = savedAt ?? DateTime.now();
    return AutoTareEntry(
      tareDate: day(date),
      tareKg: tareKg,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteAutoTare(DateTime date) async {
    _byDay.remove(day(date));
  }
}

/// Fails every write, standing in for a SQLite error.
class _ThrowingAutoTareRepository implements AutoTareRepository {
  @override
  Future<AutoTareEntry?> getAutoTare(DateTime date) async => null;

  @override
  Future<AutoTareEntry> saveAutoTare({
    required DateTime date,
    required double tareKg,
    DateTime? savedAt,
  }) async {
    throw Exception('disk full');
  }

  @override
  Future<void> deleteAutoTare(DateTime date) async {
    throw Exception('disk full');
  }
}

void main() {
  late MockCustomerRepository mockCustomerRepo;
  late MockMaterialRepository mockMaterialRepo;
  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;
  late AutoTareRepository autoTareRepository;
  late BillBloc bloc;

  final today = DateTime.now();

  setUp(() {
    mockCustomerRepo = MockCustomerRepository();
    mockMaterialRepo = MockMaterialRepository();
    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();
    autoTareRepository = FakeAutoTareRepository();

    when(
      () => mockCustomerRepo.getAllActiveCustomers(),
    ).thenAnswer((_) async => []);
    when(
      () => mockMaterialRepo.getMaterialsByStatus(isActive: true),
    ).thenAnswer((_) async => []);
    when(
      () => mockLoadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) async => []);
    when(
      () => mockGenerateBillNumberUseCase(),
    ).thenAnswer((_) async => 'WB-00001');

    bloc = BillBloc(
      customerRepository: mockCustomerRepo,
      materialRepository: mockMaterialRepo,
      saveBillUseCase: mockSaveBillUseCase,
      loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
      generateBillNumberUseCase: mockGenerateBillNumberUseCase,
      autoTareRepository: autoTareRepository,
    );

    bloc.add(const LoadBillScreen());
    bloc.add(const LiveScaleWeightUpdated(weightKg: 20000, isStable: true));
  });

  tearDown(() => bloc.close());

  group('Daily auto tare', () {
    test('starts as Not Set when nothing is stored for today', () async {
      await pumpEventQueue();
      expect(bloc.state.hasAutoTare, isFalse);
      expect(bloc.state.autoTareKg, 0);
      expect(bloc.state.autoTareDate, isNull);
    });

    test('SaveAutoTare stores the day value and exposes it in state', () async {
      await pumpEventQueue();
      bloc.add(SaveAutoTare(8000));
      await pumpEventQueue();

      expect(bloc.state.autoTareKg, 8000);
      expect(bloc.state.hasAutoTare, isTrue);
      expect(
        bloc.state.autoTareDate,
        DateTime(today.year, today.month, today.day),
      );
    });

    test(
      'saving the stored value again completes instead of hanging',
      () async {
        await pumpEventQueue();

        final first = Completer<void>();
        bloc.add(SaveAutoTare(8000, completer: first));
        await first.future.timeout(const Duration(seconds: 2));

        // Same value: the bloc emits an identical state, so nothing appears on
        // the state stream. The completer must still complete.
        final second = Completer<void>();
        bloc.add(SaveAutoTare(8000, completer: second));
        await second.future.timeout(const Duration(seconds: 2));

        expect(bloc.state.autoTareKg, 8000);
      },
    );

    test('the completer reports a failing write to the caller', () async {
      final failing = _ThrowingAutoTareRepository();
      final failingBloc = BillBloc(
        customerRepository: mockCustomerRepo,
        materialRepository: mockMaterialRepo,
        saveBillUseCase: mockSaveBillUseCase,
        loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
        generateBillNumberUseCase: mockGenerateBillNumberUseCase,
        autoTareRepository: failing,
      );
      addTearDown(failingBloc.close);

      final completer = Completer<void>();
      failingBloc.add(SaveAutoTare(8000, completer: completer));

      await expectLater(completer.future, throwsA(isA<Exception>()));
    });

    test('DeleteAutoTare clears the day value', () async {
      await pumpEventQueue();
      bloc.add(SaveAutoTare(8000));
      await pumpEventQueue();
      bloc.add(const DeleteAutoTare());
      await pumpEventQueue();

      expect(bloc.state.hasAutoTare, isFalse);
      expect(bloc.state.autoTareDate, isNull);
    });

    test(
      'saving again replaces the value for future weighments only',
      () async {
        await pumpEventQueue();
        bloc.add(SaveAutoTare(8000));
        await pumpEventQueue();
        bloc.add(SaveAutoTare(8150));
        await pumpEventQueue();

        expect(bloc.state.autoTareKg, 8150);
      },
    );

    test(
      "yesterday's auto tare is never applied to today's weighments",
      () async {
        await pumpEventQueue();
        await autoTareRepository.saveAutoTare(
          date: today.subtract(const Duration(days: 1)),
          tareKg: 8000,
        );

        bloc.add(const LoadAutoTare());
        await pumpEventQueue();

        expect(bloc.state.hasAutoTare, isFalse);
      },
    );

    test(
      'registering gross fills the tare from auto tare and computes net',
      () async {
        await pumpEventQueue();
        bloc.add(SaveAutoTare(8000));
        await pumpEventQueue();

        bloc.add(const LiveScaleWeightUpdated(weightKg: 20000, isStable: true));
        await pumpEventQueue();
        bloc.add(const CaptureLiveWeight(type: 'Gross'));
        await pumpEventQueue();

        expect(bloc.state.grossWeightKg, 20000);
        expect(bloc.state.tareWeightKg, 8000);
        expect(bloc.state.netWeightKg, 12000);
        expect(bloc.state.tareCapturedAt, isNotNull);
      },
    );

    test(
      'a manual bill tare is not overwritten by auto tare on gross capture',
      () async {
        await pumpEventQueue();
        bloc.add(SaveAutoTare(8000));
        await pumpEventQueue();
        bloc.add(const TareWeightCommitted('8200'));
        await pumpEventQueue();

        bloc.add(const LiveScaleWeightUpdated(weightKg: 20000, isStable: true));
        await pumpEventQueue();
        bloc.add(const CaptureLiveWeight(type: 'Gross'));
        await pumpEventQueue();

        expect(bloc.state.tareWeightKg, 8200);
        expect(bloc.state.netWeightKg, 11800);
      },
    );

    test(
      'capturing tare directly is unaffected by the auto tare setting',
      () async {
        await pumpEventQueue();
        bloc.add(SaveAutoTare(8000));
        await pumpEventQueue();

        bloc.add(const LiveScaleWeightUpdated(weightKg: 8300, isStable: true));
        await pumpEventQueue();
        bloc.add(const CaptureLiveWeight(type: 'Tare'));
        await pumpEventQueue();

        expect(bloc.state.tareWeightKg, 8300);
      },
    );
  });
}
