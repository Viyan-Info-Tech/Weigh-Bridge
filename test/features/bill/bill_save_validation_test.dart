import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

void main() {
  late MockCustomerRepository mockCustomerRepo;
  late MockMaterialRepository mockMaterialRepo;
  late MockSaveBillUseCase mockSaveBill;
  late MockLoadRecentBillsUseCase mockLoadRecent;
  late MockGenerateBillNumberUseCase mockGenerateBillNumber;

  final testCustomer = Customer(
    id: 1,
    customerCode: 'C001',
    name: 'Test Customer',
    isActive: true,
    createdAt: DateTime(2026, 10, 1),
    updatedAt: DateTime(2026, 10, 1),
  );
  final testMaterial = MaterialItem(
    id: 1,
    code: 'M001',
    name: 'Sand',
    isActive: true,
    createdAt: DateTime(2026, 10, 1),
    updatedAt: DateTime(2026, 10, 1),
  );

  BillBloc createBloc() {
    return BillBloc(
      customerRepository: mockCustomerRepo,
      materialRepository: mockMaterialRepo,
      saveBillUseCase: mockSaveBill,
      loadRecentBillsUseCase: mockLoadRecent,
      generateBillNumberUseCase: mockGenerateBillNumber,
    );
  }

  setUp(() {
    mockCustomerRepo = MockCustomerRepository();
    mockMaterialRepo = MockMaterialRepository();
    mockSaveBill = MockSaveBillUseCase();
    mockLoadRecent = MockLoadRecentBillsUseCase();
    mockGenerateBillNumber = MockGenerateBillNumberUseCase();

    // Stubs for LoadBillScreen
    when(
      () => mockCustomerRepo.getAllActiveCustomers(),
    ).thenAnswer((_) async => [testCustomer]);
    when(
      () => mockMaterialRepo.getMaterialsByStatus(isActive: true),
    ).thenAnswer((_) async => [testMaterial]);
    when(
      () => mockLoadRecent.call(date: any(named: 'date')),
    ).thenAnswer((_) async => []);
    when(
      () => mockGenerateBillNumber.call(),
    ).thenAnswer((_) async => 'WB-00001');
  });

  /// Seed function: puts the BLoC into the `loaded` state with all mandatory
  /// fields filled (Truck, Customer, Material, Charges, Gross Weight with timestamp).
  BillState validFormState() {
    return const BillState(
      status: BillScreenStatus.loaded,
      vehicleNumber: 'TN09AB1234',
      grossWeightKg: 1223,
      grossWeightText: '1223',
      currentBillNumber: 'WB-00001',
      weightUnit: 'kg',
    ).copyWith(
      selectedCustomer: testCustomer,
      selectedMaterial: testMaterial,
      grossCapturedAt: DateTime(2026, 10, 1, 10, 45),
    );
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
              (s) => s.materialError,
              'materialError',
              'Material code is required.',
            )
            .having(
              (s) => s.customerError,
              'customerError',
              'Customer code is required.',
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
      'truck number with invalid characters → error',
      build: createBloc,
      seed: () => validFormState().copyWith(vehicleNumber: 'TN-09 AB12'),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.vehicleNumberError,
          'vehicleNumberError',
          contains('alphanumeric'),
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'truck number with exactly 10 characters but a dash → error',
      build: createBloc,
      seed: () => validFormState().copyWith(vehicleNumber: 'TN-09AB1234'),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.vehicleNumberError,
          'vehicleNumberError',
          contains('alphanumeric'),
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'truck number with a space instead of a character → error',
      build: createBloc,
      seed: () => validFormState().copyWith(vehicleNumber: 'TN 09AB1234'),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.vehicleNumberError,
          'vehicleNumberError',
          contains('alphanumeric'),
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'truck number too short (< 10 chars) → error',
      build: createBloc,
      seed: () => validFormState().copyWith(vehicleNumber: 'AB'),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.vehicleNumberError,
          'vehicleNumberError',
          contains('exactly 10'),
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'truck number with 9 characters → error',
      build: createBloc,
      seed: () => validFormState().copyWith(vehicleNumber: 'TN09AB123'),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.vehicleNumberError,
          'vehicleNumberError',
          contains('exactly 10'),
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'truck number with 11 characters supplied programmatically → error',
      build: createBloc,
      seed: () => validFormState().copyWith(vehicleNumber: 'TN20AK292123'),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.vehicleNumberError,
          'vehicleNumberError',
          contains('exactly 10'),
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'valid 10-char truck number → passes truck validation (enters saving)',
      build: createBloc,
      seed: () => validFormState(),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      verify: (bloc) {
        expect(bloc.state.status, isNot(BillScreenStatus.loaded));
        expect(bloc.state.vehicleNumberError, isNull);
      },
    );
  });

  // ─── 2. CUSTOMER ──────────────────────────────────────────────

  group('Validation: Customer', () {
    blocTest<BillBloc, BillState>(
      'no customer selected → error',
      build: createBloc,
      seed: () => validFormState().copyWith(clearCustomer: true),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.customerError,
          'customerError',
          'Customer code is required.',
        ),
      ],
    );
  });

  // ─── 3. MATERIAL ──────────────────────────────────────────────

  group('Validation: Material', () {
    blocTest<BillBloc, BillState>(
      'no material selected → error',
      build: createBloc,
      seed: () => validFormState().copyWith(clearMaterial: true),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.materialError,
          'materialError',
          'Material code is required.',
        ),
      ],
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
      'invalid mobile (5 digits) → error',
      build: createBloc,
      seed: () => validFormState().copyWith(mobileNumber: '12345'),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.mobileError,
          'mobileError',
          contains('10-digit'),
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'mobile starting with 1 → error',
      build: createBloc,
      seed: () => validFormState().copyWith(mobileNumber: '1234567890'),
      act: (bloc) => bloc.add(const SaveBillRequested()),
      expect: () => [
        isA<BillState>().having(
          (s) => s.mobileError,
          'mobileError',
          contains('starting with 6'),
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
      'truck number shorter than 10 characters keeps vehicleNumberError',
      build: createBloc,
      seed: () => validFormState().copyWith(
        fieldErrors: {
          'vehicleNumber':
              'Truck number must be exactly 10 alphanumeric characters.',
        },
      ),
      act: (bloc) => bloc.add(const VehicleNumberChanged('TN09AB123')),
      expect: () => [
        isA<BillState>().having(
          (s) => s.vehicleNumberError,
          'vehicleNumberError',
          isNotNull,
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      '10-character truck number with an invalid character keeps vehicleNumberError',
      build: createBloc,
      seed: () => validFormState().copyWith(
        fieldErrors: {
          'vehicleNumber':
              'Truck number must be exactly 10 alphanumeric characters.',
        },
      ),
      act: (bloc) => bloc.add(const VehicleNumberChanged('TN09AB-123')),
      expect: () => [
        isA<BillState>().having(
          (s) => s.vehicleNumberError,
          'vehicleNumberError',
          isNotNull,
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'selecting material clears materialError',
      build: createBloc,
      seed: () => validFormState().copyWith(
        fieldErrors: {'material': 'Material code is required.'},
      ),
      act: (bloc) => bloc.add(MaterialSelected(testMaterial)),
      expect: () => [
        isA<BillState>().having(
          (s) => s.materialError,
          'materialError',
          isNull,
        ),
      ],
    );

    blocTest<BillBloc, BillState>(
      'selecting customer clears customerError',
      build: createBloc,
      seed: () => validFormState().copyWith(
        fieldErrors: {'customer': 'Customer code is required.'},
      ),
      act: (bloc) => bloc.add(CustomerSelected(testCustomer)),
      expect: () => [
        isA<BillState>().having(
          (s) => s.customerError,
          'customerError',
          isNull,
        ),
      ],
    );
  });
}
