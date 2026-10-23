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

class MockGetPreviousWeighmentUseCase extends Mock
    implements GetPreviousWeighmentUseCase {}

class FakeWeighment extends Fake implements Weighment {}

/// A completed single-weight bill: the truck was weighed once (gross or
/// tare) and has now returned for its other weighing.
Weighment singleWeightBill({
  required int id,
  required String billNumber,
  required String vehicleNumber,
  required String type,
  required double weightKg,
}) {
  return Weighment(
    id: id,
    billNumber: billNumber,
    vehicleNumber: vehicleNumber,
    firstWeightType: type,
    firstWeightKg: weightKg,
    createdAt: DateTime(2026, 10, 1, 8, 30),
    updatedAt: DateTime(2026, 10, 1, 8, 30),
  );
}

void main() {
  late MockSaveBillUseCase mockSaveBill;
  late MockLoadRecentBillsUseCase mockLoadRecent;
  late MockGenerateBillNumberUseCase mockGenerateBillNumber;
  late MockGetPreviousWeighmentUseCase mockGetPrevious;

  setUpAll(() {
    registerFallbackValue(FakeWeighment());
  });

  BillBloc createBloc() {
    return BillBloc(
      saveBillUseCase: mockSaveBill,
      loadRecentBillsUseCase: mockLoadRecent,
      generateBillNumberUseCase: mockGenerateBillNumber,
      previousWeighmentUseCase: mockGetPrevious,
    );
  }

  setUp(() {
    mockSaveBill = MockSaveBillUseCase();
    mockLoadRecent = MockLoadRecentBillsUseCase();
    mockGenerateBillNumber = MockGenerateBillNumberUseCase();
    mockGetPrevious = MockGetPreviousWeighmentUseCase();

    when(
      () => mockLoadRecent.call(date: any(named: 'date')),
    ).thenAnswer((_) async => []);
    when(
      () => mockGenerateBillNumber.call(),
    ).thenAnswer((_) async => 'WB-00001');
    when(
      () => mockSaveBill.withNewBillNumber(any()),
    ).thenAnswer((_) async => (id: 2, billNumber: 'WB-00002'));
    when(
      () => mockGetPrevious.call(any()),
    ).thenAnswer((_) async => null);
  });

  // ─── MODE TOGGLE ───────────────────────────────────────────────

  group('Second weight mode toggle', () {
    blocTest<BillBloc, BillState>(
      'activating the mode hides GROSS/TARE and starts with a clean slate',
      build: createBloc,
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        grossWeightText: '15000',
        grossWeightKg: 15000,
      ).copyWith(grossCapturedAt: DateTime(2026, 10, 1, 9)),
      act: (bloc) => bloc.add(const SecondWeightModeChanged(true)),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.isSecondWeightMode, isTrue);
        // Stale normal-weighment weight is dropped, not carried into the
        // second-weight flow.
        expect(state.grossWeightKg, 0);
        expect(state.grossWeightText, '');
        expect(state.previousWeighment, isNull);
        // The lookup started as soon as the mode was activated with a
        // vehicle number already present.
        verify(() => mockGetPrevious.call('TN31CM2026')).called(1);
      },
    );

    blocTest<BillBloc, BillState>(
      'deactivating restores the normal form without stale second-weight state',
      build: createBloc,
      seed: () => BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        previousWeighment: singleWeightBill(
          id: 1,
          billNumber: 'WB-00001',
          vehicleNumber: 'TN31CM2026',
          type: 'GROSS',
          weightKg: 14710,
        ),
        grossWeightText: '14.710',
        grossWeightKg: 14710,
      ).copyWith(grossCapturedAt: DateTime(2026, 10, 1, 8, 30)),
      act: (bloc) => bloc.add(const SecondWeightModeChanged(false)),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.isSecondWeightMode, isFalse);
        expect(state.previousWeighment, isNull);
        expect(state.previousWeightMessage, isNull);
        expect(state.grossWeightKg, 0);
        expect(state.grossWeightText, '');
        expect(state.selectedWeightType, 'Gross');
        // The vehicle number is not second-weight state and is kept.
        expect(state.vehicleNumber, 'TN31CM2026');
        verifyNever(() => mockGetPrevious.call(any()));
      },
    );
  });

  // ─── PREVIOUS-WEIGHT RETRIEVAL ─────────────────────────────────

  group('Previous weighment retrieval', () {
    blocTest<BillBloc, BillState>(
      'GROSS-first sequence: previous gross is loaded, tare is captured now',
      build: () {
        when(() => mockGetPrevious.call('TN31CM2026')).thenAnswer(
          (_) async => singleWeightBill(
            id: 1,
            billNumber: 'WB-00001',
            vehicleNumber: 'TN31CM2026',
            type: 'GROSS',
            weightKg: 14710,
          ),
        );
        return createBloc();
      },
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'kg',
      ),
      act: (bloc) => bloc.add(const FetchPreviousWeightForVehicle()),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.previousWeighment, isNotNull);
        expect(state.previousWeighment!.billNumber, 'WB-00001');
        // The previous weight is populated into its own field...
        expect(state.grossWeightKg, 14710);
        expect(state.grossWeightText, '14710');
        expect(state.grossCapturedAt, isNotNull);
        // ...and the operator captures the opposite weight now.
        expect(state.tareWeightKg, 0);
        expect(state.firstWeightType, 'GROSS');
        expect(state.selectedWeightType, 'Tare');
        expect(state.previousWeightMessage, isNull);
      },
    );

    blocTest<BillBloc, BillState>(
      'TARE-first sequence: previous tare is loaded, gross is captured now',
      build: () {
        when(() => mockGetPrevious.call('TN31CM2026')).thenAnswer(
          (_) async => singleWeightBill(
            id: 1,
            billNumber: 'WB-00001',
            vehicleNumber: 'TN31CM2026',
            type: 'TARE',
            weightKg: 10000,
          ),
        );
        return createBloc();
      },
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'kg',
      ),
      act: (bloc) => bloc.add(const FetchPreviousWeightForVehicle()),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.previousWeighment, isNotNull);
        expect(state.tareWeightKg, 10000);
        expect(state.tareWeightText, '10000');
        expect(state.tareCapturedAt, isNotNull);
        expect(state.grossWeightKg, 0);
        expect(state.firstWeightType, 'TARE');
        expect(state.selectedWeightType, 'Gross');
      },
    );

    blocTest<BillBloc, BillState>(
      'previous weight is converted when the form displays tons',
      build: () {
        when(() => mockGetPrevious.call('TN31CM2026')).thenAnswer(
          (_) async => singleWeightBill(
            id: 1,
            billNumber: 'WB-00001',
            vehicleNumber: 'TN31CM2026',
            type: 'GROSS',
            weightKg: 14710,
          ),
        );
        return createBloc();
      },
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'ton',
      ),
      act: (bloc) => bloc.add(const FetchPreviousWeightForVehicle()),
      verify: (bloc) {
        expect(bloc.state.grossWeightText, '14.710');
        expect(bloc.state.grossWeightKg, 14710);
      },
    );

    blocTest<BillBloc, BillState>(
      'unknown vehicle: clear message and no arbitrary data',
      build: createBloc,
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'MH12AB9999',
        isSecondWeightMode: true,
        weightUnit: 'kg',
      ),
      act: (bloc) => bloc.add(const FetchPreviousWeightForVehicle()),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.previousWeighment, isNull);
        expect(state.previousWeightMessage, contains('No previous weighment'));
        expect(state.previousWeightMessage, contains('MH12AB9999'));
        expect(state.grossWeightKg, 0);
        expect(state.tareWeightKg, 0);
        expect(state.isFetchingPreviousWeight, isFalse);
      },
    );

    blocTest<BillBloc, BillState>(
      'previous weighment with invalid weight data: explain and populate nothing',
      build: () {
        when(() => mockGetPrevious.call('TN31CM2026')).thenAnswer(
          (_) async => singleWeightBill(
            id: 1,
            billNumber: 'WB-00001',
            vehicleNumber: 'TN31CM2026',
            type: 'GROSS',
            weightKg: 0,
          ),
        );
        return createBloc();
      },
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'kg',
      ),
      act: (bloc) => bloc.add(const FetchPreviousWeightForVehicle()),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.previousWeighment, isNull);
        expect(state.previousWeightMessage, contains('WB-00001'));
        expect(state.previousWeightMessage, contains('invalid weight data'));
        expect(state.grossWeightKg, 0);
        expect(state.tareWeightKg, 0);
      },
    );

    blocTest<BillBloc, BillState>(
      'database error: surfaced as a message, never leaves the form stuck',
      build: () {
        when(
          () => mockGetPrevious.call(any()),
        ).thenThrow(Exception('db locked'));
        return createBloc();
      },
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
      ),
      act: (bloc) => bloc.add(const FetchPreviousWeightForVehicle()),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.isFetchingPreviousWeight, isFalse);
        expect(state.previousWeighment, isNull);
        expect(state.previousWeightMessage, contains('Could not search'));
      },
    );

    blocTest<BillBloc, BillState>(
      'empty vehicle number: no query, no stale match',
      build: createBloc,
      seed: () => BillState(
        status: BillScreenStatus.loaded,
        isSecondWeightMode: true,
        previousWeighment: singleWeightBill(
          id: 1,
          billNumber: 'WB-00001',
          vehicleNumber: 'TN31CM2026',
          type: 'GROSS',
          weightKg: 14710,
        ),
      ),
      act: (bloc) => bloc.add(const FetchPreviousWeightForVehicle()),
      verify: (bloc) {
        expect(bloc.state.previousWeighment, isNull);
        verifyNever(() => mockGetPrevious.call(any()));
      },
    );
  });

  // ─── VEHICLE NUMBER CHANGES ────────────────────────────────────

  group('Vehicle number changes in second-weight mode', () {
    blocTest<BillBloc, BillState>(
      'typing over the number clears the stale match and re-fetches',
      build: () {
        when(() => mockGetPrevious.call('TN31CM2026')).thenAnswer(
          (_) async => singleWeightBill(
            id: 1,
            billNumber: 'WB-00001',
            vehicleNumber: 'TN31CM2026',
            type: 'GROSS',
            weightKg: 14710,
          ),
        );
        when(() => mockGetPrevious.call('TN31CM9999')).thenAnswer(
          (_) async => singleWeightBill(
            id: 7,
            billNumber: 'WB-00007',
            vehicleNumber: 'TN31CM9999',
            type: 'TARE',
            weightKg: 9500,
          ),
        );
        return createBloc();
      },
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'kg',
      ),
      act: (bloc) async {
        bloc.add(const FetchPreviousWeightForVehicle());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const VehicleNumberChanged('TN31CM9999'));
        await Future<void>.delayed(Duration.zero);
      },
      verify: (bloc) {
        final state = bloc.state;
        expect(state.vehicleNumber, 'TN31CM9999');
        expect(state.previousWeighment!.billNumber, 'WB-00007');
        // The new record decides the field layout again.
        expect(state.tareWeightKg, 9500);
        expect(state.grossWeightKg, 0);
        expect(state.firstWeightType, 'TARE');
      },
    );

    blocTest<BillBloc, BillState>(
      'a changed number drops the previously populated weight immediately',
      build: () {
        when(
          () => mockGetPrevious.call(any()),
        ).thenAnswer((_) async => null);
        return createBloc();
      },
      seed: () => BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'kg',
        previousWeighment: singleWeightBill(
          id: 1,
          billNumber: 'WB-00001',
          vehicleNumber: 'TN31CM2026',
          type: 'GROSS',
          weightKg: 14710,
        ),
        grossWeightText: '14710',
        grossWeightKg: 14710,
      ).copyWith(grossCapturedAt: DateTime(2026, 10, 1, 8, 30)),
      act: (bloc) => bloc.add(const VehicleNumberChanged('MH12AB9999')),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.vehicleNumber, 'MH12AB9999');
        expect(state.previousWeighment, isNull);
        // The stale weight from the old vehicle can never be saved against
        // the new number.
        expect(state.grossWeightKg, 0);
        expect(state.grossWeightText, '');
        expect(state.grossCapturedAt, isNull);
        expect(state.firstWeightType, isNull);
      },
    );
  });

  // ─── F1 CAPTURE GUARD ──────────────────────────────────────────

  group('Capture guard before the lookup answers', () {
    blocTest<BillBloc, BillState>(
      'F1 is refused while no previous bill is matched',
      build: createBloc,
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        liveScaleWeightKg: 10500,
        isScaleStable: true,
        selectedWeightType: 'Tare',
      ),
      act: (bloc) => bloc.add(const CaptureLiveWeight(type: 'Tare')),
      verify: (bloc) {
        expect(bloc.state.status, BillScreenStatus.error);
        expect(bloc.state.errorMessage, contains('previous weighment'));
        expect(bloc.state.tareWeightKg, 0);
      },
    );
  });

  // ─── NET WEIGHT CALCULATION ────────────────────────────────────

  group('Second-weight net calculation', () {
    blocTest<BillBloc, BillState>(
      'previous gross 14,710 + captured tare 10,000 → net 4,710',
      build: () {
        when(() => mockGetPrevious.call('TN31CM2026')).thenAnswer(
          (_) async => singleWeightBill(
            id: 1,
            billNumber: 'WB-00001',
            vehicleNumber: 'TN31CM2026',
            type: 'GROSS',
            weightKg: 14710,
          ),
        );
        return createBloc();
      },
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'kg',
      ),
      act: (bloc) async {
        bloc.add(const FetchPreviousWeightForVehicle());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TareWeightChanged('10000'));
      },
      verify: (bloc) {
        expect(bloc.state.grossWeightKg, 14710);
        expect(bloc.state.tareWeightKg, 10000);
        expect(bloc.state.netWeightKg, 4710);
        expect(bloc.state.weightValidationError, isNull);
      },
    );

    blocTest<BillBloc, BillState>(
      'captured tare heavier than previous gross blocks the save with a clear '
      'message instead of an incorrect net weight',
      build: () {
        when(() => mockGetPrevious.call('TN31CM2026')).thenAnswer(
          (_) async => singleWeightBill(
            id: 1,
            billNumber: 'WB-00001',
            vehicleNumber: 'TN31CM2026',
            type: 'GROSS',
            weightKg: 5000,
          ),
        );
        return createBloc();
      },
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'kg',
      ),
      act: (bloc) async {
        bloc.add(const FetchPreviousWeightForVehicle());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TareWeightChanged('8000'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const SaveBillRequested());
      },
      verify: (bloc) {
        final state = bloc.state;
        expect(state.status, BillScreenStatus.loaded);
        expect(state.weightError, isNotNull);
        expect(state.weightError, contains('greater than tare'));
        verifyNever(() => mockSaveBill.withNewBillNumber(any()));
      },
    );
  });

  // ─── SAVE ──────────────────────────────────────────────────────

  group('Saving the second weighment', () {
    /// Puts the bloc into a matched second-weight state with the tare
    /// captured, ready to save.
    BillState matchedState() {
      return BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'kg',
        grossWeightText: '14710',
        grossWeightKg: 14710,
        tareWeightText: '10000',
        tareWeightKg: 10000,
        netWeightKg: 4710,
        firstWeightType: 'GROSS',
        previousWeighment: singleWeightBill(
          id: 1,
          billNumber: 'WB-00001',
          vehicleNumber: 'TN31CM2026',
          type: 'GROSS',
          weightKg: 14710,
        ),
      ).copyWith(
        grossCapturedAt: DateTime(2026, 10, 1, 8, 30),
        tareCapturedAt: DateTime(2026, 10, 1, 17, 5),
      );
    }

    blocTest<BillBloc, BillState>(
      'saves a separate bill with a new number and the original linked',
      build: createBloc,
      seed: matchedState,
      act: (bloc) => bloc.add(const SaveAndPrintBillRequested()),
      verify: (bloc) {
        final captured = verify(
          () => mockSaveBill.withNewBillNumber(captureAny()),
        );
        final saved = captured.captured.single as Weighment;
        // A brand-new bill, not a merge into the original: the entity sent to
        // the database only previews a number, the DB allocates the real one.
        expect(saved.previousWeighmentId, 1);
        // Both weights stored with the correct gross/tare assignment.
        expect(saved.grossWeightKg, 14710);
        expect(saved.tareWeightKg, 10000);
        expect(saved.netWeightKg, 4710);
        // A second weighing is a completed bill, never pending.
        expect(saved.isCompleted, isTrue);
        // The number allocated by the database is what the bill carries.
        final receipt = bloc.state.printReceiptBill;
        expect(receipt, isNotNull);
        expect(receipt!.billNumber, 'WB-00002');
        expect(receipt.previousWeighmentId, 1);
        expect(receipt.isCompleted, isTrue);
      },
    );

    blocTest<BillBloc, BillState>(
      'the original bill number is untouched in state after the save',
      build: createBloc,
      seed: matchedState,
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        // The form resets to a fresh NORMAL weighment for the next truck.
        expect(bloc.state.isSecondWeightMode, isFalse);
        expect(bloc.state.previousWeighment, isNull);
        expect(bloc.state.vehicleNumber, '');
        expect(bloc.state.grossWeightKg, 0);
        expect(bloc.state.tareWeightKg, 0);
      },
    );

    blocTest<BillBloc, BillState>(
      'save without a matched previous weighment is blocked by validation',
      build: createBloc,
      seed: () => const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'kg',
        grossWeightText: '14710',
        grossWeightKg: 14710,
      ).copyWith(grossCapturedAt: DateTime(2026, 10, 1, 8, 30)),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        expect(bloc.state.status, BillScreenStatus.loaded);
        expect(bloc.state.vehicleNumberError, isNotNull);
        verifyNever(() => mockSaveBill.withNewBillNumber(any()));
      },
    );

    blocTest<BillBloc, BillState>(
      'save before the current weight is captured is blocked by validation',
      build: createBloc,
      seed: () => BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'kg',
        grossWeightText: '14710',
        grossWeightKg: 14710,
        firstWeightType: 'GROSS',
        previousWeighment: singleWeightBill(
          id: 1,
          billNumber: 'WB-00001',
          vehicleNumber: 'TN31CM2026',
          type: 'GROSS',
          weightKg: 14710,
        ),
      ).copyWith(grossCapturedAt: DateTime(2026, 10, 1, 8, 30)),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        expect(bloc.state.status, BillScreenStatus.loaded);
        expect(bloc.state.weightError, contains('Capture the current weight'));
        verifyNever(() => mockSaveBill.withNewBillNumber(any()));
      },
    );
  });

  // ─── SAVE-ERROR SAFETY ─────────────────────────────────────────

  group('Database errors on save', () {
    blocTest<BillBloc, BillState>(
      'a failed insert surfaces an error and keeps the form intact',
      build: () {
        when(
          () => mockSaveBill.withNewBillNumber(any()),
        ).thenThrow(Exception('disk full'));
        return createBloc();
      },
      seed: () => BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN31CM2026',
        isSecondWeightMode: true,
        weightUnit: 'kg',
        grossWeightText: '14710',
        grossWeightKg: 14710,
        tareWeightText: '10000',
        tareWeightKg: 10000,
        netWeightKg: 4710,
        firstWeightType: 'GROSS',
        previousWeighment: singleWeightBill(
          id: 1,
          billNumber: 'WB-00001',
          vehicleNumber: 'TN31CM2026',
          type: 'GROSS',
          weightKg: 14710,
        ),
      ).copyWith(
        grossCapturedAt: DateTime(2026, 10, 1, 8, 30),
        tareCapturedAt: DateTime(2026, 10, 1, 17, 5),
      ),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        expect(bloc.state.status, BillScreenStatus.error);
        // Nothing is lost: the operator can retry the save.
        expect(bloc.state.vehicleNumber, 'TN31CM2026');
        expect(bloc.state.grossWeightKg, 14710);
        expect(bloc.state.tareWeightKg, 10000);
        expect(bloc.state.previousWeighment, isNotNull);
      },
    );
  });
}
