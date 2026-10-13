import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/customer/domain/entities/customer.dart';
import 'package:weighbridge/features/customer/domain/repositories/customer_repository.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

/// A tare-only weighment has no net weight and therefore nothing to price
/// against a material, so the material must not be demanded. Every other shape
/// of bill must still name one.
void main() {
  late MockCustomerRepository mockCustomerRepo;
  late MockMaterialRepository mockMaterialRepo;
  late MockSaveBillUseCase mockSaveBill;
  late MockLoadRecentBillsUseCase mockLoadRecent;
  late MockGenerateBillNumberUseCase mockGenerateBillNumber;

  /// Captures whatever the bloc tried to persist, so the saved row can be
  /// inspected rather than just the emitted validation state.
  late List<Weighment> saved;

  final testCustomer = Customer(
    id: 1,
    customerCode: 'C001',
    name: 'Test Customer',
    isActive: true,
    createdAt: DateTime(2026, 10, 1),
    updatedAt: DateTime(2026, 10, 1),
  );

  final testMaterial = MaterialItem(
    id: 7,
    code: 'M001',
    name: 'Sand',
    isActive: true,
    createdAt: DateTime(2026, 10, 1),
    updatedAt: DateTime(2026, 10, 1),
  );

  BillBloc createBloc() => BillBloc(
    customerRepository: mockCustomerRepo,
    materialRepository: mockMaterialRepo,
    saveBillUseCase: mockSaveBill,
    loadRecentBillsUseCase: mockLoadRecent,
    generateBillNumberUseCase: mockGenerateBillNumber,
  );

  setUpAll(() {
    registerFallbackValue(
      Weighment(
        id: 0,
        billNumber: 'WB-00000',
        customerId: 0,
        vehicleNumber: 'TN09AB1234',
        materialId: 0,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    saved = <Weighment>[];
    mockCustomerRepo = MockCustomerRepository();
    mockMaterialRepo = MockMaterialRepository();
    mockSaveBill = MockSaveBillUseCase();
    mockLoadRecent = MockLoadRecentBillsUseCase();
    mockGenerateBillNumber = MockGenerateBillNumberUseCase();

    when(
      () => mockCustomerRepo.getAllActiveCustomers(),
    ).thenAnswer((_) async => [testCustomer]);
    when(
      () => mockMaterialRepo.getMaterialsByStatus(isActive: true),
    ).thenAnswer((_) async => [testMaterial]);
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

  /// A tare-only form: customer and truck filled, a tare captured,
  /// no gross, and deliberately no material.
  BillState tareOnlyForm() =>
      const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN09AB1234',
        tareWeightKg: 4200,
        tareWeightText: '4200',
        currentBillNumber: 'WB-00001',
        weightUnit: 'kg',
      ).copyWith(
        selectedCustomer: testCustomer,
        firstWeightType: 'TARE',
        tareCapturedAt: DateTime(2026, 10, 1, 10, 45),
      );

  /// A gross-only form with no material, for the cases that must still fail.
  BillState grossOnlyForm() =>
      const BillState(
        status: BillScreenStatus.loaded,
        vehicleNumber: 'TN09AB1234',
        grossWeightKg: 1223,
        grossWeightText: '1223',
        currentBillNumber: 'WB-00001',
        weightUnit: 'kg',
      ).copyWith(
        selectedCustomer: testCustomer,
        firstWeightType: 'GROSS',
        grossCapturedAt: DateTime(2026, 10, 1, 10, 45),
      );

  group('BillState.requiresMaterial', () {
    test('is false only for a tare-only weighment', () {
      expect(tareOnlyForm().isTareOnly, isTrue);
      expect(tareOnlyForm().requiresMaterial, isFalse);
    });

    test('is true for a gross-only weighment', () {
      expect(grossOnlyForm().isTareOnly, isFalse);
      expect(grossOnlyForm().requiresMaterial, isTrue);
    });

    test('is true when both weights are present', () {
      final state = tareOnlyForm().copyWith(grossWeightKg: 8000);
      expect(state.isTareOnly, isFalse);
      expect(state.requiresMaterial, isTrue);
    });

    test('is true when no weight has been captured yet', () {
      final state = tareOnlyForm().copyWith(tareWeightKg: 0);
      expect(state.isTareOnly, isFalse);
      expect(state.requiresMaterial, isTrue);
    });

    test('treats NaN and negative weights as not captured', () {
      // A NaN must never read as "present", or a broken tare entry would be
      // mistaken for a tare-only bill and skip the material requirement.
      final nanState = tareOnlyForm().copyWith(tareWeightKg: double.nan);
      expect(nanState.hasTareWeight, isFalse);
      expect(nanState.isTareOnly, isFalse);
      expect(nanState.requiresMaterial, isTrue);

      final negative = tareOnlyForm().copyWith(tareWeightKg: -10);
      expect(negative.hasTareWeight, isFalse);
      expect(negative.isTareOnly, isFalse);
      expect(negative.requiresMaterial, isTrue);
    });
  });

  group('Saving a tare-only weighment without a material', () {
    blocTest<BillBloc, BillState>(
      'is accepted and persists a null materialId',
      build: createBloc,
      seed: tareOnlyForm,
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (_) {
        expect(saved, hasLength(1), reason: 'the save must not be rejected');
        expect(saved.single.materialId, isNull);
        expect(saved.single.firstWeightType, 'TARE');
        expect(saved.single.secondWeightKg, isNull);
        expect(saved.single.netWeightKg, isNull);
      },
    );

    blocTest<BillBloc, BillState>(
      'still persists the material when one was chosen',
      build: createBloc,
      seed: () => tareOnlyForm().copyWith(selectedMaterial: testMaterial),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (_) {
        expect(saved, hasLength(1));
        expect(saved.single.materialId, testMaterial.id);
      },
    );
  });

  group('Material is still required whenever a net weight exists', () {
    blocTest<BillBloc, BillState>(
      'gross-only weighment still reports the material error',
      build: createBloc,
      seed: grossOnlyForm,
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.materialError,
          'materialError',
          'Material code is required.',
        ),
      ],
      verify: (_) => verifyNever(() => mockSaveBill.withNewBillNumber(any())),
    );

    blocTest<BillBloc, BillState>(
      'a fully weighted weighment still reports the material error',
      build: createBloc,
      seed: () => tareOnlyForm().copyWith(
        grossWeightKg: 8000,
        grossWeightText: '8000',
        grossCapturedAt: DateTime(2026, 10, 1, 9),
      ),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.materialError,
          'materialError',
          'Material code is required.',
        ),
      ],
      verify: (_) => verifyNever(() => mockSaveBill.withNewBillNumber(any())),
    );

    blocTest<BillBloc, BillState>(
      'a weighment with no captured weight still needs a material',
      build: createBloc,
      seed: () => tareOnlyForm().copyWith(
        tareWeightKg: 0,
        tareWeightText: '',
        tareCapturedAt: null,
        firstWeightType: null,
      ),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.materialError,
          'materialError',
          'Material code is required.',
        ),
      ],
      verify: (_) => verifyNever(() => mockSaveBill.withNewBillNumber(any())),
    );
  });
}
