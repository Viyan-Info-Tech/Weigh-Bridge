import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/bill/presentation/pages/bill_page.dart';
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

/// Covers the wiring that fixes the reported bug.
///
/// `HomePage` keeps every tab alive in an `IndexedStack`, so `BillPage` is
/// built once per session and its `initState` never runs again. The customer
/// list was therefore only ever read by that single initial load, so a customer
/// edited on the master screen stayed stale in the weighment dropdown until the
/// app was restarted.
///
/// The fix is one line in `BillPage.didUpdateWidget`: when the tab becomes
/// active again, re-read the lookup lists. This test drives that exact
/// transition.
void main() {
  late BillBloc billBloc;
  late MockCustomerRepository mockCustomerRepository;
  late MockMaterialRepository mockMaterialRepository;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;

  /// Stands in for the `customers` table. Reassigning it is exactly what the
  /// master screen does when a customer is saved.
  late List<Customer> customersInDatabase;

  Customer customer(int id, String code, String name) {
    return Customer(
      id: id,
      customerCode: code,
      name: name,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 9, 21));
  });

  setUp(() {
    customersInDatabase = <Customer>[customer(1, 'C-001', 'Old Name')];

    mockCustomerRepository = MockCustomerRepository();
    mockMaterialRepository = MockMaterialRepository();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();

    when(() => mockCustomerRepository.getAllActiveCustomers()).thenAnswer(
      (_) => Future.value(customersInDatabase),
    );
    when(
      () => mockMaterialRepository.getMaterialsByStatus(isActive: true),
    ).thenAnswer(
      (_) => Future.value(<MaterialItem>[]),
    );
    when(
      () => mockLoadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) => Future.value(<Weighment>[]));
    when(
      () => mockGenerateBillNumberUseCase(),
    ).thenAnswer((_) => Future.value('WB-00001'));

    billBloc = BillBloc(
      customerRepository: mockCustomerRepository,
      materialRepository: mockMaterialRepository,
      saveBillUseCase: MockSaveBillUseCase(),
      loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
      generateBillNumberUseCase: mockGenerateBillNumberUseCase,
    );
  });

  tearDown(() {
    billBloc.close();
  });

  Widget pageUnderTest({required bool isActive}) {
    return MaterialApp(
      home: BlocProvider.value(
        value: billBloc,
        child: BillPage(isActive: isActive),
      ),
    );
  }

  /// BillBloc's events resolve on the real event loop, so the initial
  /// `LoadBillScreen` has to be awaited through `runAsync`.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() async {
      for (var i = 0; i < 40; i++) {
        if (billBloc.state.status == BillScreenStatus.loaded) return;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await tester.pump();
  }

  /// Polls the real event loop until the refreshed list shows [name].
  Future<void> waitForCustomer(
    WidgetTester tester,
    String name,
  ) async {
    await tester.runAsync(() async {
      for (var i = 0; i < 40; i++) {
        if (billBloc.state.customers.any((c) => c.name == name)) return;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
  }

  testWidgets('re-reads customers when the tab becomes active again', (
    tester,
  ) async {
    // The tab is first built while inactive, which is what an IndexedStack does
    // for every non-visible tab at startup.
    await tester.pumpWidget(pageUnderTest(isActive: false));
    await settle(tester);

    expect(
      billBloc.state.customers.single.name,
      'Old Name',
      reason: 'precondition: the startup snapshot was captured',
    );

    // The operator renames the customer in Customer Master and saves.
    customersInDatabase = <Customer>[customer(1, 'C-001', 'New Name')];

    // Coming back to the tab is the false -> true flip that HomePage performs.
    await tester.pumpWidget(pageUnderTest(isActive: true));
    await waitForCustomer(tester, 'New Name');

    expect(
      billBloc.state.customers.single.name,
      'New Name',
      reason: 'the dropdown must not keep the snapshot taken at startup',
    );
  });

  testWidgets('picks up a customer created on the master screen', (
    tester,
  ) async {
    await tester.pumpWidget(pageUnderTest(isActive: false));
    await settle(tester);
    expect(billBloc.state.customers, hasLength(1));

    customersInDatabase = <Customer>[
      customer(1, 'C-001', 'Old Name'),
      customer(2, 'C-002', 'Brand New'),
    ];

    await tester.pumpWidget(pageUnderTest(isActive: true));
    await waitForCustomer(tester, 'Brand New');

    expect(billBloc.state.customers, hasLength(2));
    expect(billBloc.state.customers.last.name, 'Brand New');
  });

  testWidgets('does not re-read while the tab stays active', (tester) async {
    await tester.pumpWidget(pageUnderTest(isActive: true));
    await settle(tester);

    customersInDatabase = <Customer>[customer(1, 'C-001', 'New Name')];

    // Rebuilding with the same active flag is not a tab switch.
    await tester.pumpWidget(pageUnderTest(isActive: true));
    await tester.pump();

    expect(
      billBloc.state.customers.single.name,
      'Old Name',
      reason: 'only an actual tab switch should trigger a reload',
    );
  });

  testWidgets('a tab switch keeps the work already entered on the form', (
    tester,
  ) async {
    await tester.pumpWidget(pageUnderTest(isActive: false));
    await settle(tester);

    billBloc.add(const VehicleNumberChanged('MH12AB1234'));
    await tester.runAsync(() async {
      for (var i = 0; i < 40 && billBloc.state.vehicleNumber.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    expect(billBloc.state.vehicleNumber, 'MH12AB1234');

    customersInDatabase = <Customer>[customer(1, 'C-001', 'New Name')];

    await tester.pumpWidget(pageUnderTest(isActive: true));
    await waitForCustomer(tester, 'New Name');

    expect(
      billBloc.state.vehicleNumber,
      'MH12AB1234',
      reason: 'a lookup refresh must not clear the form',
    );
    expect(billBloc.state.currentBillNumber, 'WB-00001');
    expect(
      billBloc.state.customers.single.name,
      'New Name',
      reason: 'the form must be preserved *and* the lookups refreshed',
    );
  });
}
