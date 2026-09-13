import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/generate_bill_number.dart';
import 'package:weighbridge/features/bill/domain/usecases/load_pending_bills.dart';
import 'package:weighbridge/features/bill/domain/usecases/load_recent_bills.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/pages/pending_page.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart' as domain;
import 'package:weighbridge/features/material/domain/repositories/material_repository.dart';
import 'package:weighbridge/features/party/domain/entities/party.dart';
import 'package:weighbridge/features/party/domain/repositories/party_repository.dart';
import 'package:weighbridge/features/vehicle/domain/entities/vehicle.dart';
import 'package:weighbridge/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:weighbridge/features/vehicle_type/domain/entities/vehicle_type.dart';
import 'package:weighbridge/features/vehicle_type/domain/repositories/vehicle_type_repository.dart';

class MockPartyRepository extends Mock implements PartyRepository {}
class MockVehicleRepository extends Mock implements VehicleRepository {}
class MockVehicleTypeRepository extends Mock implements VehicleTypeRepository {}
class MockMaterialRepository extends Mock implements MaterialRepository {}
class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}
class MockLoadRecentBillsUseCase extends Mock implements LoadRecentBillsUseCase {}
class MockGenerateBillNumberUseCase extends Mock implements GenerateBillNumberUseCase {}
class MockLoadPendingBillsUseCase extends Mock implements LoadPendingBillsUseCase {}

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
      address: 'Industrial Area',
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
      driverName: 'Ramesh Kumar',
      driverPhone: '9876543210',
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  final testVehicleTypes = [
    VehicleType(
      id: 1,
      name: '10 Wheeler Truck',
      emptyPrice: 200,
      loadPrice: 500,
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  final testMaterials = [
    domain.MaterialItem(
      id: 1,
      name: 'Sand',
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  final now = DateTime.now();

  final testPendingBills = [
    Weighment(
      id: 1,
      billNumber: 'WB-00001',
      partyId: 1,
      vehicleId: 1,
      materialId: 1,
      paymentMode: 'Cash',
      grossWeightKg: 28500,
      tareWeightKg: null,
      netWeightKg: null,
      vehicleCharge: 500,
      amount: 500,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    ),
    Weighment(
      id: 2,
      billNumber: 'WB-00002',
      partyId: 1,
      vehicleId: 1,
      materialId: 1,
      paymentMode: 'Cash',
      grossWeightKg: 34200,
      tareWeightKg: null,
      netWeightKg: null,
      vehicleCharge: 500,
      amount: 500,
      status: 'pending',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(days: 2)),
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

    when(() => mockPartyRepository.getAllActiveParties())
        .thenAnswer((_) => Future.value(testParties));
    when(() => mockVehicleRepository.getVehiclesByStatus(isActive: true))
        .thenAnswer((_) => Future.value(testVehicles));
    when(() => mockVehicleTypeRepository.getVehicleTypesByStatus(isActive: true))
        .thenAnswer((_) => Future.value(testVehicleTypes));
    when(() => mockVehicleTypeRepository.getAllVehicleTypes())
        .thenAnswer((_) => Future.value(testVehicleTypes));
    when(() => mockMaterialRepository.getMaterialsByStatus(isActive: true))
        .thenAnswer((_) => Future.value(testMaterials));
    when(() => mockLoadRecentBillsUseCase())
        .thenAnswer((_) => Future.value([]));
    when(() => mockLoadRecentBillsUseCase(date: any(named: 'date')))
        .thenAnswer((_) => Future.value([]));
    when(() => mockGenerateBillNumberUseCase())
        .thenAnswer((_) => Future.value('WB-00003'));
    when(() => mockLoadPendingBillsUseCase())
        .thenAnswer((_) => Future.value(testPendingBills));

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

  Widget createWidgetUnderTest({VoidCallback? onSwitchToBill}) {
    return MaterialApp(
      home: BlocProvider<BillBloc>.value(
        value: billBloc,
        child: Scaffold(
          body: PendingPage(onSwitchToBill: onSwitchToBill),
        ),
      ),
    );
  }

  testWidgets('renders header, stats cards, and pending table with correct data', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Initialize screen
    billBloc.add(const LoadBillScreen());
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify page header
    expect(find.text('Pending Weighments'), findsOneWidget);
    expect(find.text('Vehicles waiting for tare weighing to complete the bill'), findsOneWidget);

    // Verify stats cards
    expect(find.text('Pending Queue'), findsOneWidget);
    expect(find.text('Gross Weight Captured'), findsOneWidget);
    expect(find.text('Expected Charges'), findsOneWidget);

    // Verify card header and refresh button
    expect(find.text('Pending Bills'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);

    // Verify table headers
    expect(find.text('BILL NUMBER'), findsOneWidget);
    expect(find.text('VEHICLE'), findsOneWidget);
    expect(find.text('PARTY & MATERIAL'), findsOneWidget);
    expect(find.text('GROSS WEIGHT'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('ACTION'), findsOneWidget);

    // Verify data rows
    expect(find.text('WB-00001'), findsOneWidget);
    expect(find.text('MH 12 AB 1234'), findsWidgets);
    expect(find.text('UltraTech Cement'), findsWidgets);
    expect(find.text('Tare Weight Pending'), findsWidgets);
    expect(find.text('Tare Weight'), findsWidgets);

    // Verify footer
    expect(find.text('Total 2 pending weighments'), findsOneWidget);
  });

  testWidgets('renders safely across all desktop window dimensions without RenderFlex overflow', (tester) async {
    final sizesToTest = [
      const Size(1920, 1080), // Full HD Large Desktop
      const Size(1600, 900),  // Standard Desktop
      const Size(1440, 900),  // MacBook Pro Standard
      const Size(1366, 768),  // Standard Laptop
      const Size(1280, 720),  // Compact Laptop
      const Size(1152, 720),  // Small Desktop
      const Size(1024, 768),  // Legacy Desktop
      const Size(960, 720),   // Breakpoint Boundary
      const Size(900, 700),   // Narrow Desktop Stacked
      const Size(900, 600),   // Minimum Recommended Desktop Window
      const Size(800, 600),   // Compact Desktop Constraint
      const Size(700, 600),   // Small Stacked
      const Size(640, 480),   // Minimized Window Boundary
      const Size(1280, 500),  // Short Window Height
    ];

    addTearDown(() => tester.view.resetPhysicalSize());

    billBloc.add(const LoadBillScreen());

    for (final size in sizesToTest) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull, reason: 'Failed at size: ${size.width}x${size.height}');
      expect(find.text('Pending Weighments'), findsOneWidget, reason: 'Header missing at ${size.width}x${size.height}');
      expect(find.text('Pending Queue'), findsOneWidget, reason: 'Queue card missing at ${size.width}x${size.height}');
      expect(find.text('Gross Weight Captured'), findsOneWidget, reason: 'Weight card missing at ${size.width}x${size.height}');
      expect(find.text('Expected Charges'), findsOneWidget, reason: 'Charges card missing at ${size.width}x${size.height}');
    }
  });

  testWidgets('search and clear input filters pending bills correctly', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    billBloc.add(const LoadBillScreen());
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Search for nonexistent query
    await tester.enterText(searchField, 'NONEXISTENT_QUERY');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No pending weighments'), findsOneWidget);
    expect(find.text('WB-00001'), findsNothing);

    // Clear search using clear button
    final clearButton = find.byIcon(Icons.clear);
    expect(clearButton, findsOneWidget);
    await tester.tap(clearButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('WB-00001'), findsOneWidget);
  });

  testWidgets('tapping Tare Weight button loads pending bill and invokes callback', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool callbackInvoked = false;
    billBloc.add(const LoadBillScreen());

    await tester.pumpWidget(createWidgetUnderTest(
      onSwitchToBill: () {
        callbackInvoked = true;
      },
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final tareWeightButtons = find.widgetWithText(FilledButton, 'Tare Weight');
    expect(tareWeightButtons, findsWidgets);

    await tester.tap(tareWeightButtons.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(callbackInvoked, isTrue);
    expect(billBloc.state.editingBillId, equals(1));
  });
}
