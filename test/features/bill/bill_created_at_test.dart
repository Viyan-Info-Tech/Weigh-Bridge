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

class FakeWeighment extends Fake implements Weighment {}

/// A bill's `createdAt` is the moment it was saved, never the Auto Tare's
/// reference time.
///
/// Auto Tare is configured once per day and re-applied to many bills, so its
/// timestamp is a constant for the whole day. Deriving `createdAt` from the
/// weight capture fields leaked that constant into every bill, which made the
/// Recent Billings panel show one frozen time for all of them.
///
/// The Auto Tare itself keeps its own reference timestamp; only the bill's
/// billing time is decoupled from it.
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

  /// The moment the day's Auto Tare was configured. Fixed for the whole day.
  final autoTareConfiguredAt = DateTime(2026, 10, 1, 14, 43);

  final saved = <Weighment>[];

  setUpAll(() {
    registerFallbackValue(FakeWeighment());
  });

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
    saved.clear();
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

  /// A tare-first bill whose tare came from the day's Auto Tare.
  BillState tareFirstStateFromAutoTare() {
    return const BillState(
      status: BillScreenStatus.loaded,
      vehicleNumber: 'TN09AB1234',
      vehicleCharge: 90,
      amount: 90,
      weightUnit: 'kg',
      currentBillNumber: 'WB-00001',
    ).copyWith(
      selectedCustomer: testCustomer,
      selectedMaterial: testMaterial,
      firstWeightType: 'TARE',
      autoTareKg: 2000,
      autoTareDate: DateTime(2026, 10, 1),
      autoTareSavedAt: autoTareConfiguredAt,
    );
  }

  group('Recent Billings timestamp is the real save time', () {
    blocTest<BillBloc, BillState>(
      'a tare-first bill must not inherit the Auto Tare configured time',
      build: createBloc,
      seed: () => tareFirstStateFromAutoTare(),
      act: (bloc) async {
        bloc.add(const ApplyAutoTareToBill());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const SaveBillRequested());
      },
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        expect(saved, hasLength(1));
        final bill = saved.single;

        // Auto Tare's own reference time is unchanged and still available on
        // the state for the Auto Tare indicator to display.
        expect(
          bill.createdAt.isBefore(autoTareConfiguredAt),
          isFalse,
          reason:
              'createdAt fell back to the Auto Tare configured time '
              '($autoTareConfiguredAt), which is stale for every bill of '
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
      'Auto Tare keeps its own reference time, unrelated to bill createdAt',
      build: createBloc,
      seed: () => tareFirstStateFromAutoTare(),
      act: (bloc) async {
        bloc.add(const ApplyAutoTareToBill());
        await Future<void>.delayed(Duration.zero);
      },
      wait: const Duration(milliseconds: 20),
      verify: (bloc) {
        // The Auto Tare behaviour itself is deliberately unchanged: the tare
        // field is stamped with the Auto Tare's configured reference time.
        expect(bloc.state.autoTareSavedAt, autoTareConfiguredAt);
        expect(bloc.state.tareWeightKg, 2000);
        expect(bloc.state.tareCapturedAt, autoTareConfiguredAt);
      },
    );

    blocTest<BillBloc, BillState>(
      'a gross capture that auto-fills tare still bills at save time',
      build: createBloc,
      seed: () => tareFirstStateFromAutoTare().copyWith(
        clearFirstWeightType: true,
        liveScaleWeightKg: 100000,
        isScaleStable: true,
      ),
      act: (bloc) async {
        // Gross capture fills the tare from the day's Auto Tare.
        bloc.add(const CaptureLiveWeight(type: 'Gross'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const SaveBillRequested());
      },
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        expect(saved, hasLength(1));
        final bill = saved.single;

        expect(bill.grossWeightKg, 100000);
        expect(bill.tareWeightKg, 2000, reason: 'Auto Tare should fill tare.');

        // Neither timestamp may be the day-constant Auto Tare configured time.
        for (final entry in {
          'createdAt': bill.createdAt,
          'updatedAt': bill.updatedAt,
        }.entries) {
          expect(
            DateTime.now().difference(entry.value).abs(),
            lessThan(const Duration(minutes: 5)),
            reason:
                '${entry.key} was stamped with ${entry.value}, which is the '
                'Auto Tare configured time rather than the save time.',
          );
        }
      },
    );
  });
}
