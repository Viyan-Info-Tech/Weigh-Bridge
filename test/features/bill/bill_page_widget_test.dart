import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/customer/domain/entities/customer.dart';
import 'package:weighbridge/features/customer/domain/repositories/customer_repository.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/bill/presentation/pages/bill_page.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026, 9, 12));
  });

  late BillBloc billBloc;
  late MockCustomerRepository mockCustomerRepository;
  late MockMaterialRepository mockMaterialRepository;
  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;

  final testCustomers = [
    Customer(
      id: 1,
      customerCode: 'C-001',
      name: 'UltraTech Cement',
      mobile: '9876543210',
      address: 'Mumbai',
      gstNumber: '27AAAAA0000A1Z5',
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  final testMaterials = [
    MaterialItem(
      id: 1,
      code: '1',
      name: 'Sand',
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  final testBills = [
    Weighment(
      id: 1,
      billNumber: 'WB-00001',
      customerId: 1,
      vehicleNumber: 'MH 12 AB 1234',
      materialId: 1,
      paymentMode: 'Cash',
      firstWeightKg: 25000,
      firstWeightType: 'GROSS',
      secondWeightKg: 10000,
      secondWeightType: 'TARE',
      grossWeightKg: 25000,
      tareWeightKg: 10000,
      netWeightKg: 15000,
      vehicleCharge: 500,
      amount: 500,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  final mixedDayBills = [
    ...testBills,
    Weighment(
      id: 2,
      billNumber: 'WB-00000',
      customerId: 1,
      vehicleNumber: 'MH 12 AB 1234',
      materialId: 1,
      paymentMode: 'Cash',
      firstWeightKg: 10000,
      firstWeightType: 'TARE',
      secondWeightKg: 20000,
      secondWeightType: 'GROSS',
      grossWeightKg: 20000,
      tareWeightKg: 10000,
      netWeightKg: 10000,
      vehicleCharge: 500,
      amount: 500,
      createdAt: yesterday,
      updatedAt: yesterday,
    ),
  ];

  setUp(() {
    mockCustomerRepository = MockCustomerRepository();
    mockMaterialRepository = MockMaterialRepository();
    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();

    when(
      () => mockCustomerRepository.getAllActiveCustomers(),
    ).thenAnswer((_) => Future.value(testCustomers));
    when(
      () => mockCustomerRepository.getCustomerByCode(any()),
    ).thenAnswer((_) => Future.value(testCustomers.first));
    when(
      () => mockMaterialRepository.getMaterialsByStatus(isActive: true),
    ).thenAnswer((_) => Future.value(testMaterials));
    when(
      () => mockMaterialRepository.getMaterialByCode(any()),
    ).thenAnswer((_) => Future.value(testMaterials.first));
    when(
      () => mockLoadRecentBillsUseCase(),
    ).thenAnswer((_) => Future.value(testBills));
    when(
      () => mockLoadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) => Future.value(testBills));
    when(
      () => mockGenerateBillNumberUseCase(),
    ).thenAnswer((_) => Future.value('WB-00002'));

    billBloc = BillBloc(
      customerRepository: mockCustomerRepository,
      materialRepository: mockMaterialRepository,
      saveBillUseCase: mockSaveBillUseCase,
      loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
      generateBillNumberUseCase: mockGenerateBillNumberUseCase,
    );
  });

  tearDown(() {
    billBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider.value(value: billBloc, child: const BillPage()),
    );
  }

  test('billBloc loads bill screen correctly', () async {
    billBloc.add(const LoadBillScreen());
    await expectLater(
      billBloc.stream,
      emitsInOrder([
        predicate<BillState>((s) => s.status == BillScreenStatus.loading),
        predicate<BillState>((s) => s.status == BillScreenStatus.loaded),
      ]),
    );
  });

  Future<void> pumpBillPage(WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.runAsync(() async {
      await billBloc.stream.firstWhere(
        (s) => s.status == BillScreenStatus.loaded,
      );
    });
    await tester.pumpAndSettle();
  }

  testWidgets('renders hero scale banner, 2-column form, and action buttons', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpBillPage(tester);

    // Verify Hero Scale Banner
    expect(find.text('WEIGHT'), findsOneWidget);
    expect(find.text('STABLE'), findsNothing);
    expect(find.text('CAM 01'), findsOneWidget);

    // Verify Form Labels
    expect(find.text('TRUCK NO'), findsOneWidget);
    expect(find.text('SERIAL NO'), findsOneWidget);
    expect(find.text('GROSS WEIGHT'), findsOneWidget);
    expect(find.text('TARE WEIGHT'), findsOneWidget);
    expect(find.text('NETT WEIGHT'), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('SAVE'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
    expect(find.text('RE-PRINT'), findsOneWidget);
    expect(find.text('MANUAL TARE'), findsOneWidget);
    expect(find.text('AUTO TARE'), findsOneWidget);
    expect(find.text('EXIT'), findsOneWidget);
    expect(find.text('RE-SEND SMS'), findsNothing);
  });

  testWidgets('F2 opens manual tare and Enter confirms a valid value', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    expect(find.text('Manual Tare'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, '10.2');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Manual Tare'), findsNothing);
    expect(billBloc.state.tareWeightKg, 10.2);
  });

  testWidgets('F1 refuses to capture when there is no real live scale value', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);

    await tester.enterText(
      find.byKey(const Key('bill_vehicle_number_field')),
      'TN32AB1234',
    );
    await tester.enterText(
      find.byKey(const Key('bill_material_code_field')),
      'M-001',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('bill_customer_code_field')),
      'C-001',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pumpAndSettle();
    expect(billBloc.state.tareWeightKg, 0);
  });

  testWidgets('F4 reports when there is no ticket to reprint', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    when(
      () => mockLoadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) => Future.value(<Weighment>[]));

    await pumpBillPage(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f4);
    await tester.pumpAndSettle();
    expect(find.text('No ticket available for reprint.'), findsOneWidget);
  });

  testWidgets('F3 captures a stable live reading as tare', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);
    billBloc.add(const LiveScaleWeightUpdated(weightKg: 10200, isStable: true));
    await tester.runAsync(() async {
      await billBloc.stream.firstWhere(
        (state) => state.liveScaleWeightKg == 10200,
      );
    });
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.f3);
    await tester.pumpAndSettle();
    expect(billBloc.state.tareWeightKg, 10200);
  });

  testWidgets('F4 opens the most recent valid ticket for reprint', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.f4);
    await tester.pumpAndSettle();
    expect(find.text('Print Ticket'), findsOneWidget);
    expect(find.text('WB-00001'), findsWidgets);
  });

  testWidgets('Enter resolves material and customer codes from repositories', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);

    await tester.enterText(
      find.byKey(const Key('bill_material_code_field')),
      'M-001',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    verify(() => mockMaterialRepository.getMaterialByCode('M-001')).called(1);

    await tester.enterText(
      find.byKey(const Key('bill_customer_code_field')),
      'C-001',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    verify(() => mockCustomerRepository.getCustomerByCode('C-001')).called(1);
    expect(billBloc.state.selectedCustomer?.name, 'UltraTech Cement');
    expect(billBloc.state.selectedMaterial?.name, 'Sand');
  });

  testWidgets('F1 captures the selected gross and tare live weights', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);

    await tester.enterText(
      find.byKey(const Key('bill_vehicle_number_field')),
      'TN32AB1234',
    );
    await tester.enterText(
      find.byKey(const Key('bill_material_code_field')),
      'M-001',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('bill_customer_code_field')),
      'C-001',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    billBloc.add(const LiveScaleWeightUpdated(weightKg: 25000, isStable: true));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pumpAndSettle();
    expect(billBloc.state.grossWeightKg, 25000);

    billBloc.add(const LiveScaleWeightUpdated(weightKg: 10000, isStable: true));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.tap(find.text('TARE'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pumpAndSettle();
    expect(billBloc.state.tareWeightKg, 10000);
    expect(billBloc.state.netWeightKg, 15000);
  });

  testWidgets('Tab and Shift+Tab traverse the truck and weight type fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);

    expect(FocusManager.instance.primaryFocus?.debugLabel, 'vehicleFocusNode');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'weightTypeFocusNode',
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'vehicleFocusNode');
  });

  testWidgets('F9 confirms before clearing an unfinished weighment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);
    await tester.enterText(
      find.byKey(const Key('bill_vehicle_number_field')),
      'TN32AB1234',
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.f9);
    await tester.pumpAndSettle();
    expect(find.text('Exit current weighment?'), findsOneWidget);
    await tester.tap(find.text('Exit Ticket'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await billBloc.stream.firstWhere((state) => state.vehicleNumber.isEmpty);
    });
    expect(find.text('Exit current weighment?'), findsNothing);
    expect(billBloc.state.vehicleNumber, isEmpty);
  });

  testWidgets('Escape clears an empty current operation without a dialog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Exit current weighment?'), findsNothing);
    expect(billBloc.state.vehicleNumber, isEmpty);
  });

  testWidgets('hides yesterday bills from today recent billings in drawer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(
      () => mockLoadRecentBillsUseCase(),
    ).thenAnswer((_) => Future.value(mixedDayBills));
    when(
      () => mockLoadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) => Future.value(mixedDayBills));

    await pumpBillPage(tester);

    // Open recent bills drawer
    tester.state<ScaffoldState>(find.byType(Scaffold)).openEndDrawer();
    await tester.pumpAndSettle();

    expect(find.text('WB-00001'), findsWidgets);
    expect(find.text('WB-00000'), findsNothing);
    expect(find.text('1 Today'), findsOneWidget);
  });

  testWidgets('filters recent bills when typing in search field in drawer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpBillPage(tester);

    // Open recent bills drawer
    tester.state<ScaffoldState>(find.byType(Scaffold)).openEndDrawer();
    await tester.pumpAndSettle();

    // Search for nonexistent vehicle
    await tester.enterText(
      find.byKey(const Key('recent_bills_search_field')),
      'NONEXISTENT',
    );
    await tester.pumpAndSettle();

    expect(find.text('No matching billings'), findsOneWidget);

    // Search for matching vehicle
    await tester.enterText(
      find.byKey(const Key('recent_bills_search_field')),
      'MH 12',
    );
    await tester.pumpAndSettle();

    expect(find.text('WB-00001'), findsWidgets);
  });

  testWidgets(
    'opens weighment slip dialog when clicking print icon in drawer',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpBillPage(tester);

      // Open recent bills drawer
      tester.state<ScaffoldState>(find.byType(Scaffold)).openEndDrawer();
      await tester.pumpAndSettle();

      // Tap print slip icon on recent bill card
      await tester.tap(find.byKey(const Key('print_slip_button_WB-00001')));
      await tester.pumpAndSettle();

      // Verify dialog opened with bill details
      expect(find.text('VIYAN WEIGHBRIDGE'), findsOneWidget);
      expect(find.text('WB-00001'), findsWidgets);
      expect(find.text('Print Ticket'), findsOneWidget);
    },
  );
}
