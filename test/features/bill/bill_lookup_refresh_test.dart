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

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  late BillBloc billBloc;
  late MockCustomerRepository mockCustomerRepository;
  late MockMaterialRepository mockMaterialRepository;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;

  Customer buildCustomer(
    int id,
    String code,
    String name, {
    String? mobile,
  }) {
    final now = DateTime.now();
    return Customer(
      id: id,
      customerCode: code,
      name: name,
      mobile: mobile,
      createdAt: now,
      updatedAt: now,
    );
  }

  MaterialItem buildMaterial(int id, String code, String name) {
    final now = DateTime.now();
    return MaterialItem(
      id: id,
      code: code,
      name: name,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    mockCustomerRepository = MockCustomerRepository();
    mockMaterialRepository = MockMaterialRepository();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();

    when(
      () => mockCustomerRepository.getAllActiveCustomers(),
    ).thenAnswer((_) async => [buildCustomer(1, 'C-001', 'Old Name')]);
    when(
      () => mockMaterialRepository.getMaterialsByStatus(isActive: true),
    ).thenAnswer((_) async => [buildMaterial(1, 'M-1', 'Sand')]);
    when(
      () => mockLoadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) async => <Weighment>[]);
    when(
      () => mockGenerateBillNumberUseCase(),
    ).thenAnswer((_) async => 'WB-0001');

    billBloc = BillBloc(
      customerRepository: mockCustomerRepository,
      materialRepository: mockMaterialRepository,
      saveBillUseCase: MockSaveBillUseCase(),
      loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
      generateBillNumberUseCase: mockGenerateBillNumberUseCase,
    );
  });

  tearDown(() async {
    await billBloc.close();
  });

  /// The load handler performs several sequential awaits, so a single turn of
  /// the event loop is not enough to observe its effect.
  Future<void> settle() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  group('Bill lookup refresh', () {
    test('picks up a customer renamed on the master screen', () async {
      billBloc.add(const LoadBillScreen());
      await settle();
      expect(
        billBloc.state.customers.single.name,
        'Old Name',
        reason: 'precondition: startup snapshot is stale',
      );

      // The customer master writes straight to the database, so the next read
      // returns the edited row.
      when(
        () => mockCustomerRepository.getAllActiveCustomers(),
      ).thenAnswer(
        (_) async => [buildCustomer(1, 'C-001', 'New Name', mobile: '987650001')],
      );

      billBloc.add(const RefreshBillLookups());
      await settle();

      expect(billBloc.state.customers.single.name, 'New Name');
      expect(billBloc.state.customers.single.mobile, '987650001');
      expect(billBloc.state.errorMessage, isNull);
    });

    test('picks up a customer created on the master screen', () async {
      billBloc.add(const LoadBillScreen());
      await settle();

      when(
        () => mockCustomerRepository.getAllActiveCustomers(),
      ).thenAnswer(
        (_) async => [
          buildCustomer(1, 'C-001', 'Old Name'),
          buildCustomer(2, 'C-002', 'Brand New'),
        ],
      );

      billBloc.add(const RefreshBillLookups());
      await settle();

      expect(billBloc.state.customers, hasLength(2));
      expect(billBloc.state.customers.last.name, 'Brand New');
    });

    test('drops a customer that was deactivated on the master screen', () async {
      billBloc.add(const LoadBillScreen());
      await settle();

      when(
        () => mockCustomerRepository.getAllActiveCustomers(),
      ).thenAnswer((_) async => <Customer>[]);

      billBloc.add(const RefreshBillLookups());
      await settle();

      expect(billBloc.state.customers, isEmpty);
    });

    test(
      're-points an in-progress selection at the edited row, keeping typed mobile',
      () async {
        billBloc.add(const LoadBillScreen());
        await settle();

        billBloc.add(
          CustomerSelected(buildCustomer(1, 'C-001', 'Old Name', mobile: '999')),
        );
        await settle();

        when(
          () => mockCustomerRepository.getAllActiveCustomers(),
        ).thenAnswer(
          (_) async => [
            buildCustomer(1, 'C-001', 'New Name', mobile: '987650001'),
          ],
        );

        billBloc.add(const RefreshBillLookups());
        await settle();

        expect(
          billBloc.state.selectedCustomer?.name,
          'New Name',
          reason: 'the entity saved on the bill must not be the stale row',
        );
        expect(
          billBloc.state.mobileNumber,
          '999',
          reason: 'mobile is operator-editable and must not be clobbered',
        );
      },
    );

    test('keeps the selection when the customer is deactivated mid-entry', () async {
      billBloc.add(const LoadBillScreen());
      await settle();

      billBloc.add(CustomerSelected(buildCustomer(1, 'C-001', 'Old Name')));
      await settle();

      when(
        () => mockCustomerRepository.getAllActiveCustomers(),
      ).thenAnswer((_) async => <Customer>[]);

      billBloc.add(const RefreshBillLookups());
      await settle();

      expect(
        billBloc.state.selectedCustomer,
        isNotNull,
        reason: 'a refresh must never silently discard entered work',
      );
    });

    test('refreshes materials from the same event', () async {
      billBloc.add(const LoadBillScreen());
      await settle();

      when(
        () => mockMaterialRepository.getMaterialsByStatus(isActive: true),
      ).thenAnswer(
        (_) async => [
          buildMaterial(1, 'M-1', 'Sand'),
          buildMaterial(2, 'M-2', 'Gravel'),
        ],
      );

      billBloc.add(const RefreshBillLookups());
      await settle();

      expect(billBloc.state.materials, hasLength(2));
    });

    test('does not disturb the bill number or captured weights', () async {
      billBloc.add(const LoadBillScreen());
      await settle();

      billBloc.add(const GrossWeightChanged('1250'));
      await settle();
      final billNumberBefore = billBloc.state.currentBillNumber;

      when(
        () => mockCustomerRepository.getAllActiveCustomers(),
      ).thenAnswer((_) async => [buildCustomer(1, 'C-001', 'New Name')]);

      billBloc.add(const RefreshBillLookups());
      await settle();

      expect(billBloc.state.grossWeightText, '1250');
      expect(billBloc.state.currentBillNumber, billNumberBefore);
      expect(billBloc.state.errorMessage, isNull);
    });

    test('leaves the form usable when the reload fails', () async {
      billBloc.add(const LoadBillScreen());
      await settle();

      when(
        () => mockCustomerRepository.getAllActiveCustomers(),
      ).thenThrow(Exception('db locked'));

      billBloc.add(const RefreshBillLookups());
      await settle();

      expect(
        billBloc.state.customers,
        hasLength(1),
        reason: 'the previous list is kept',
      );
      expect(
        billBloc.state.status,
        isNot(BillScreenStatus.error),
        reason: 'a background refresh must not put the form into an error state',
      );
    });
  });
}
