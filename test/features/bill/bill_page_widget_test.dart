import 'package:flutter/material.dart' hide Material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/party/domain/entities/party.dart';
import 'package:weighbridge/features/party/domain/repositories/party_repository.dart';
import 'package:weighbridge/features/vehicle/domain/entities/vehicle.dart';
import 'package:weighbridge/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:weighbridge/features/vehicle_type/domain/entities/vehicle_type.dart';
import 'package:weighbridge/features/vehicle_type/domain/repositories/vehicle_type_repository.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/bill/presentation/pages/bill_page.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockVehicleTypeRepository extends Mock implements VehicleTypeRepository {}

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

class MockLoadPendingBillsUseCase extends Mock
    implements LoadPendingBillsUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026, 9, 12));
  });

  late BillBloc billBloc;
  late MockPartyRepository mockPartyRepository;
  late MockVehicleRepository mockVehicleRepository;
  late MockVehicleTypeRepository mockVehicleTypeRepository;
  late MockMaterialRepository mockMaterialRepository;
  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;
  late MockLoadPendingBillsUseCase mockLoadPendingBillsUseCase;

  final testParties = [
    Party(
      id: 1,
      name: 'UltraTech Cement',
      mobile: '9876543210',
      address: 'Mumbai',
      gstNumber: '27AAAAA0000A1Z5',
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  final testVehicles = [
    Vehicle(
      id: 1,
      vehicleNumber: 'MH 12 AB 1234',
      vehicleTypeId: 1,
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  final testVehicleTypes = [
    VehicleType(
      id: 1,
      name: '10 Wheeler',
      loadPrice: 500,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  final testMaterials = [
    MaterialItem(
      id: 1,
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
      partyId: 1,
      vehicleId: 1,
      materialId: 1,
      paymentMode: 'Cash',
      grossWeightKg: 25000,
      tareWeightKg: 10000,
      netWeightKg: 15000,
      vehicleCharge: 500,
      amount: 500,
      status: 'completed',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  final mixedDayBills = [
    ...testBills,
    Weighment(
      id: 2,
      billNumber: 'WB-00000',
      partyId: 1,
      vehicleId: 1,
      materialId: 1,
      paymentMode: 'Cash',
      grossWeightKg: 10000,
      tareWeightKg: 20000,
      netWeightKg: 10000,
      vehicleCharge: 500,
      amount: 500,
      status: 'completed',
      createdAt: yesterday,
      updatedAt: yesterday,
    ),
  ];

  setUp(() {
    mockPartyRepository = MockPartyRepository();
    mockVehicleRepository = MockVehicleRepository();
    mockVehicleTypeRepository = MockVehicleTypeRepository();
    mockMaterialRepository = MockMaterialRepository();
    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();
    mockLoadPendingBillsUseCase = MockLoadPendingBillsUseCase();

    when(
      () => mockPartyRepository.getAllActiveParties(),
    ).thenAnswer((_) => Future.value(testParties));
    when(
      () => mockVehicleRepository.getVehiclesByStatus(isActive: true),
    ).thenAnswer((_) => Future.value(testVehicles));
    when(
      () => mockVehicleTypeRepository.getVehicleTypesByStatus(isActive: true),
    ).thenAnswer((_) => Future.value(testVehicleTypes));
    when(
      () => mockVehicleTypeRepository.getAllVehicleTypes(),
    ).thenAnswer((_) => Future.value(testVehicleTypes));
    when(
      () => mockMaterialRepository.getMaterialsByStatus(isActive: true),
    ).thenAnswer((_) => Future.value(testMaterials));
    when(
      () => mockLoadRecentBillsUseCase(),
    ).thenAnswer((_) => Future.value(testBills));
    when(
      () => mockLoadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) => Future.value(testBills));
    when(
      () => mockGenerateBillNumberUseCase(),
    ).thenAnswer((_) => Future.value('WB-00002'));
    when(
      () => mockLoadPendingBillsUseCase(),
    ).thenAnswer((_) => Future.value([]));

    billBloc = BillBloc(
      partyRepository: mockPartyRepository,
      vehicleRepository: mockVehicleRepository,
      vehicleTypeRepository: mockVehicleTypeRepository,
      materialRepository: mockMaterialRepository,
      saveBillUseCase: mockSaveBillUseCase,
      loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
      loadPendingBillsUseCase: mockLoadPendingBillsUseCase,
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

  testWidgets(
    'renders left-side form controls and right-side recent billings',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpBillPage(tester);

      // Verify Header
      expect(find.text('Viyan Weighbridge'), findsOneWidget);
      expect(find.text('Billing & Ticket Management'), findsOneWidget);

      // Verify Left Side: Truck Digital Scale & Quick Action Buttons
      expect(find.text('kg'), findsOneWidget);
      expect(find.text('Clear Form'), findsOneWidget);
      expect(find.text('Save Ticket'), findsOneWidget);
      expect(find.text('Save & Print Slip'), findsOneWidget);

      // Verify Right Side: Today's Recent Billings panel
      expect(find.text('Recent Billings'), findsOneWidget);
      expect(find.text('1 Today'), findsOneWidget);
      expect(find.text('WB-00001'), findsWidgets);
      expect(find.text('MH 12 AB 1234'), findsWidgets);
      expect(find.text('UltraTech Cement'), findsWidgets);
    },
  );

  testWidgets('hides yesterday bills from today recent billings', (
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

    expect(find.text('WB-00001'), findsWidgets);
    expect(find.text('WB-00000'), findsNothing);
    expect(find.text('1 Today'), findsOneWidget);
  });

  testWidgets('filters recent bills when typing in search field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpBillPage(tester);

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

  testWidgets('opens weighment slip dialog when clicking print icon', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpBillPage(tester);

    // Tap print slip icon on recent bill card
    await tester.tap(find.byKey(const Key('print_slip_button_WB-00001')));
    await tester.pumpAndSettle();

    // Verify dialog opened with bill details
    expect(find.text('VIYAN WEIGHBRIDGE'), findsOneWidget);
    expect(find.text('WB-00001'), findsWidgets);
    expect(find.text('Print Ticket'), findsOneWidget);
  });
}
