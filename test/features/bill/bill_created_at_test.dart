import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

class FakeWeighment extends Fake implements Weighment {}

/// A bill's `createdAt` is the moment it was saved, never a weight-capture
/// reference time.
///
/// A tare may be captured long before the bill is completed (the truck's
/// empty weight can be entered hours ahead of the loaded weighing), so the
/// capture timestamps are constants from earlier in the day. Deriving
/// `createdAt` from the weight capture fields leaked those constants into
/// every bill, which made the Recent Billings panel show one frozen time.
void main() {
  late MockSaveBillUseCase mockSaveBill;
  late MockLoadRecentBillsUseCase mockLoadRecent;
  late MockGenerateBillNumberUseCase mockGenerateBillNumber;

  /// The moment the tare was captured. Fixed for the whole weighment.
  final staleTareCapturedAt = DateTime(2026, 10, 1, 14, 43);

  final saved = <Weighment>[];

  setUpAll(() {
    registerFallbackValue(FakeWeighment());
  });

  BillBloc createBloc() {
    return BillBloc(
      saveBillUseCase: mockSaveBill,
      loadRecentBillsUseCase: mockLoadRecent,
      generateBillNumberUseCase: mockGenerateBillNumber,
    );
  }

  setUp(() {
    saved.clear();
    mockSaveBill = MockSaveBillUseCase();
    mockLoadRecent = MockLoadRecentBillsUseCase();
    mockGenerateBillNumber = MockGenerateBillNumberUseCase();

    when(
      () => mockLoadRecent.call(date: any(named: 'date')),
    ).thenAnswer((_) async => []);
    when(
      () => mockGenerateBillNumber.call(),
    ).thenAnswer((_) async => 'WB-00001');

    when(() => mockSaveBill.withNewBillNumber(any())).thenAnswer((inv) async {
      final weighment = inv.positionalArguments.first as Weighment;
      saved.add(weighment);
      return (
        id: saved.length,
        billNumber: 'WB-${saved.length.toString().padLeft(5, '0')}',
      );
    });
  });

  /// A tare-first bill whose tare was captured earlier in the day.
  BillState tareFirstState() {
    return BillState(
      status: BillScreenStatus.loaded,
      vehicleNumber: 'TN09AB1234',
      weightUnit: 'kg',
      currentBillNumber: 'WB-00001',
      firstWeightType: 'TARE',
      tareWeightKg: 2000,
      tareWeightText: '2000',
      tareCapturedAt: staleTareCapturedAt,
    );
  }

  group('Recent Billings timestamp is the real save time', () {
    blocTest<BillBloc, BillState>(
      'a tare-first bill must not inherit the tare capture time',
      build: createBloc,
      seed: tareFirstState,
      act: (bloc) async {
        bloc.add(const SaveBillRequested());
      },
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        expect(saved, hasLength(1));
        final bill = saved.single;

        // The tare capture reference stays on the weighment itself.
        expect(
          bill.createdAt.isBefore(staleTareCapturedAt),
          isFalse,
          reason:
              'createdAt fell back to the tare capture time '
              '($staleTareCapturedAt), which is stale for every bill of '
              'the day.',
        );
        expect(
          DateTime.now().difference(bill.createdAt).abs(),
          lessThan(const Duration(minutes: 5)),
          reason: 'createdAt should be the moment the bill was saved.',
        );
        expect(
          bill.updatedAt.isBefore(bill.createdAt),
          isFalse,
          reason: 'updatedAt must never precede createdAt.',
        );
      },
    );

    blocTest<BillBloc, BillState>(
      'a gross capture leaves an existing tare and its capture time untouched',
      build: createBloc,
      seed: () => tareFirstState().copyWith(
        liveScaleWeightKg: 100000,
        isScaleStable: true,
      ),
      act: (bloc) => bloc.add(const CaptureLiveWeight(type: 'Gross')),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.grossWeightKg, 100000);
        expect(bloc.state.tareWeightKg, 2000);
        // The tare keeps its own capture time; the gross capture stamps only
        // the gross field.
        expect(bloc.state.tareCapturedAt, staleTareCapturedAt);
        expect(bloc.state.grossCapturedAt, isNotNull);
        expect(bloc.state.netWeightKg, 98000);
      },
    );

    blocTest<BillBloc, BillState>(
      'a gross capture over an existing tare still bills at save time',
      build: createBloc,
      seed: () => tareFirstState().copyWith(
        clearFirstWeightType: true,
        liveScaleWeightKg: 100000,
        isScaleStable: true,
      ),
      act: (bloc) async {
        // Gross capture leaves the already-entered tare untouched.
        bloc.add(const CaptureLiveWeight(type: 'Gross'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const SaveBillRequested());
      },
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        expect(saved, hasLength(1));
        final bill = saved.single;

        expect(bill.grossWeightKg, 100000);
        expect(bill.tareWeightKg, 2000, reason: 'Entered tare must be kept.');

        // Neither timestamp may be the day-constant tare capture time.
        for (final entry in {
          'createdAt': bill.createdAt,
          'updatedAt': bill.updatedAt,
        }.entries) {
          expect(
            DateTime.now().difference(entry.value).abs(),
            lessThan(const Duration(minutes: 5)),
            reason:
                '${entry.key} was stamped with ${entry.value}, which is the '
                'tare capture time rather than the save time.',
          );
        }
      },
    );
  });
}
