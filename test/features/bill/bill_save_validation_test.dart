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

void main() {
  late MockSaveBillUseCase mockSaveBill;
  late MockLoadRecentBillsUseCase mockLoadRecent;
  late MockGenerateBillNumberUseCase mockGenerateBillNumber;

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
    mockSaveBill = MockSaveBillUseCase();
    mockLoadRecent = MockLoadRecentBillsUseCase();
    mockGenerateBillNumber = MockGenerateBillNumberUseCase();

    // Stubs for LoadBillScreen
    when(
      () => mockLoadRecent.call(date: any(named: 'date')),
    ).thenAnswer((_) async => []);
    when(
      () => mockGenerateBillNumber.call(),
    ).thenAnswer((_) async => 'WB-00001');
    when(
      () => mockSaveBill.withNewBillNumber(any()),
    ).thenAnswer((_) async => (id: 1, billNumber: 'WB-00001'));
  });

  /// Seed function: puts the BLoC into the `loaded` state with all mandatory
  /// fields filled (Truck, Gross Weight with timestamp).
  BillState validFormState() {
    return const BillState(
      status: BillScreenStatus.loaded,
      vehicleNumber: 'TN09AB1234',
      grossWeightKg: 1223,
      grossWeightText: '1223',
      currentBillNumber: 'WB-00001',
      weightUnit: 'kg',
    ).copyWith(grossCapturedAt: DateTime(2026, 10, 1, 10, 45));
  }

  // ─── 0. MULTI-FIELD INLINE VALIDATION ON EMPTY FORM ─────────

  group('Validation: All Mandatory Fields When Empty', () {
    blocTest<BillBloc, BillState>(
      'SAVE with everything empty → shows all field-level errors simultaneously',
      build: createBloc,
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: '',
        grossWeightKg: 0,
        tareWeightKg: 0,
      ),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>()
            .having(
              (s) => s.vehicleNumberError,
              'vehicleNumberError',
              'Truck number is required.',
            )
            .having(
              (s) => s.weightError,
              'weightError',
              'Enter or capture Gross or Tare weight.',
            ),
      ],
    );
  });

  // ─── 1. TRUCK NUMBER ──────────────────────────────────────────

  group('Validation: Truck Number', () {
    blocTest<BillBloc, BillState>(
      'empty truck number → error',
      build: createBloc,
      seed: () => validFormState().copyWith(vehicleNumber: ''),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.vehicleNumberError,
          'vehicleNumberError',
          'Truck number is required.',
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'any non-empty truck number → passes truck validation (enters saving)',
      build: createBloc,
      seed: () => validFormState(),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        expect(bloc.state.status, isNot(BillScreenStatus.loaded));
        expect(bloc.state.vehicleNumberError, isNull);
      },
    );

    blocTest<BillBloc, BillState>(
      'short truck number still passes (only presence is validated)',
      build: createBloc,
      seed: () => validFormState().copyWith(vehicleNumber: 'AB'),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        expect(bloc.state.vehicleNumberError, isNull);
      },
    );
  });

  // ─── 5. WEIGHT PRESENCE ───────────────────────────────────────

  group('Validation: Weight Presence', () {
    blocTest<BillBloc, BillState>(
      'no weight at all → error',
      build: createBloc,
      seed: () => validFormState().copyWith(
        grossWeightKg: 0,
        grossWeightText: '',
        tareWeightKg: 0,
        tareWeightText: '',
        clearGrossCapturedAt: true,
      ),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.weightError,
          'weightError',
          contains('weight'),
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'gross only → passes weight-presence check (enters saving)',
      build: createBloc,
      seed: () => validFormState(),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        expect(bloc.state.weightError, isNull);
      },
    );

    blocTest<BillBloc, BillState>(
      'tare only → passes weight-presence check (enters saving)',
      build: createBloc,
      seed: () => validFormState().copyWith(
        grossWeightKg: 0,
        grossWeightText: '',
        clearGrossCapturedAt: true,
        tareWeightKg: 850,
        tareWeightText: '850',
        tareCapturedAt: DateTime(2026, 10, 1, 10, 47),
        firstWeightType: 'TARE',
      ),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        expect(bloc.state.weightError, isNull);
      },
    );
  });

  // ─── 6. WEIGHT RELATIONSHIP ───────────────────────────────────

  group('Validation: Weight Relationship', () {
    blocTest<BillBloc, BillState>(
      'tare >= gross → error',
      build: createBloc,
      seed: () => validFormState().copyWith(
        grossWeightKg: 500,
        grossWeightText: '500',
        tareWeightKg: 900,
        tareWeightText: '900',
        tareCapturedAt: DateTime(2026, 10, 1, 10, 50),
      ),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.weightError,
          'weightError',
          contains('greater'),
        ),
      ],
    );
  });

  // ─── 7. TIMESTAMP EXISTENCE ───────────────────────────────────

  group('Validation: Timestamp Existence', () {
    blocTest<BillBloc, BillState>(
      'gross captured but no timestamp → error',
      build: createBloc,
      seed: () => validFormState().copyWith(clearGrossCapturedAt: true),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.weightError,
          'weightError',
          contains('timestamp'),
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'tare captured but no timestamp → error',
      build: createBloc,
      seed: () => validFormState().copyWith(
        tareWeightKg: 850,
        tareWeightText: '850',
        clearTareCapturedAt: true,
      ),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.weightError,
          'weightError',
          contains('timestamp'),
        ),
      ],
    );
  });

  // ─── 8. MOBILE NUMBER ────────────────────────────────────────

  group('Validation: Mobile Number', () {
    blocTest<BillBloc, BillState>(
      'non-digit mobile → error',
      build: createBloc,
      seed: () => validFormState().copyWith(mobileNumber: 'ABC123'),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.mobileError,
          'mobileError',
          contains('digits only'),
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'valid mobile 9876543210 → passes validation (enters saving)',
      build: createBloc,
      seed: () => validFormState().copyWith(mobileNumber: '9876543210'),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        expect(bloc.state.mobileError, isNull);
      },
    );

    blocTest<BillBloc, BillState>(
      'empty mobile → passes validation (optional field, enters saving)',
      build: createBloc,
      seed: () => validFormState().copyWith(mobileNumber: ''),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        expect(bloc.state.mobileError, isNull);
      },
    );
  });

  // ─── 9. ERROR DISAPPEARANCE ON VALUE ENTRY ──────────────────

  group('Validation: Error Clears Immediately on Field Entry', () {
    blocTest<BillBloc, BillState>(
      'entering valid vehicle number clears vehicleNumberError',
      build: createBloc,
      seed: () => validFormState().copyWith(
        fieldErrors: {'vehicleNumber': 'Truck number is required.'},
      ),
      act: (bloc) => bloc.add(const VehicleNumberChanged('TN09AB1234')),
      expect: () => [
        isA<BillState>().having(
          (s) => s.vehicleNumberError,
          'vehicleNumberError',
          isNull,
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'entering any non-empty truck number clears vehicleNumberError',
      build: createBloc,
      seed: () => validFormState().copyWith(
        fieldErrors: {'vehicleNumber': 'Truck number is required.'},
      ),
      act: (bloc) => bloc.add(const VehicleNumberChanged('AB')),
      expect: () => [
        isA<BillState>().having(
          (s) => s.vehicleNumberError,
          'vehicleNumberError',
          isNull,
        ),
      ],
    );
  });
}
