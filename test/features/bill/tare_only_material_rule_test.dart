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

/// No customer or material is ever required: the Customer and Material modules
/// were removed, so tare-only AND gross weighments save with only
/// vehicle + weight (+ optional mobile).
void main() {
  late MockSaveBillUseCase mockSaveBill;
  late MockLoadRecentBillsUseCase mockLoadRecent;
  late MockGenerateBillNumberUseCase mockGenerateBillNumber;

  /// Captures whatever the bloc tried to persist, so the saved row can be
  /// inspected rather than just the emitted validation state.
  late List<Weighment> saved;

  BillBloc createBloc() => BillBloc(
    saveBillUseCase: mockSaveBill,
    loadRecentBillsUseCase: mockLoadRecent,
    generateBillNumberUseCase: mockGenerateBillNumber,
  );

  setUpAll(() {
    registerFallbackValue(
      Weighment(
        id: 0,
        billNumber: 'WB-00000',
        vehicleNumber: 'TN09AB1234',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    saved = <Weighment>[];
    mockSaveBill = MockSaveBillUseCase();
    mockLoadRecent = MockLoadRecentBillsUseCase();
    mockGenerateBillNumber = MockGenerateBillNumberUseCase();

    when(
      () => mockLoadRecent.call(date: any(named: 'date')),
    ).thenAnswer((_) async => <Weighment>[]);
    when(
      () => mockGenerateBillNumber.call(),
    ).thenAnswer((_) async => 'WB-00001');
    when(() => mockSaveBill.withNewBillNumber(any())).thenAnswer((inv) async {
      saved.add(inv.positionalArguments.first as Weighment);
      return (id: 99, billNumber: 'WB-00001');
    });
  });

  /// A tare-only form: truck filled, a tare captured, no gross,
  /// and no customer/material (none exist anymore).
  BillState tareOnlyForm() =>
      const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN09AB1234',
        tareWeightKg: 4200,
        tareWeightText: '4200',
        currentBillNumber: 'WB-00001',
        weightUnit: 'kg',
      ).copyWith(
        firstWeightType: 'TARE',
        tareCapturedAt: DateTime(2026, 10, 1, 10, 45),
      );

  /// A gross-only form with no customer/material.
  BillState grossOnlyForm() =>
      const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN09AB1234',
        grossWeightKg: 1223,
        grossWeightText: '1223',
        currentBillNumber: 'WB-00001',
        weightUnit: 'kg',
      ).copyWith(
        firstWeightType: 'GROSS',
        grossCapturedAt: DateTime(2026, 10, 1, 10, 45),
      );

  group('BillState.isTareOnly', () {
    test('is true only for a tare-only weighment', () {
      expect(tareOnlyForm().isTareOnly, isTrue);
    });

    test('is false for a gross-only weighment', () {
      expect(grossOnlyForm().isTareOnly, isFalse);
    });

    test('is false when both weights are present', () {
      final state = tareOnlyForm().copyWith(grossWeightKg: 8000);
      expect(state.isTareOnly, isFalse);
    });

    test('is false when no weight has been captured yet', () {
      final state = tareOnlyForm().copyWith(tareWeightKg: 0);
      expect(state.isTareOnly, isFalse);
    });

    test('treats NaN and negative weights as not captured', () {
      final nanState = tareOnlyForm().copyWith(tareWeightKg: double.nan);
      expect(nanState.hasTareWeight, isFalse);
      expect(nanState.isTareOnly, isFalse);

      final negative = tareOnlyForm().copyWith(tareWeightKg: -10);
      expect(negative.hasTareWeight, isFalse);
      expect(negative.isTareOnly, isFalse);
    });
  });

  group('Saving without any customer/material', () {
    blocTest<BillBloc, BillState>(
      'tare-only weighment is accepted and persists',
      build: createBloc,
      seed: tareOnlyForm,
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (_) {
        expect(saved, hasLength(1), reason: 'the save must not be rejected');
        expect(saved.single.firstWeightType, 'TARE');
        expect(saved.single.secondWeightKg, isNull);
        expect(saved.single.netWeightKg, isNull);
      },
    );

    blocTest<BillBloc, BillState>(
      'gross-only weighment is accepted without any customer/material',
      build: createBloc,
      seed: grossOnlyForm,
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (_) {
        expect(saved, hasLength(1), reason: 'the save must not be rejected');
        expect(saved.single.firstWeightType, 'GROSS');
      },
    );

    blocTest<BillBloc, BillState>(
      'a fully weighted weighment saves without customer/material errors',
      build: createBloc,
      seed: () => tareOnlyForm().copyWith(
        grossWeightKg: 8000,
        grossWeightText: '8000',
        grossCapturedAt: DateTime(2026, 10, 1, 9),
      ),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        expect(saved, hasLength(1));
        expect(bloc.state.hasFieldErrors, isFalse);
        expect(bloc.state.weightError, isNull);
        expect(bloc.state.vehicleNumberError, isNull);
        expect(bloc.state.mobileError, isNull);
      },
    );

    blocTest<BillBloc, BillState>(
      'validation has no material/customer errors for any shape',
      build: createBloc,
      seed: () => tareOnlyForm().copyWith(
        tareWeightKg: 0,
        tareWeightText: '',
        tareCapturedAt: null,
        firstWeightType: null,
      ),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        // Only the weight error may appear; there are no material/customer
        // error getters anymore.
        expect(bloc.state.weightError, isNotNull);
        expect(bloc.state.fieldErrors.keys, isNot(contains('material')));
        expect(bloc.state.fieldErrors.keys, isNot(contains('customer')));
      },
    );
  });
}
