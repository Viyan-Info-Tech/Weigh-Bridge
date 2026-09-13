import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/bill/presentation/pages/pending_page.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart'
    as domain;
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/party/domain/entities/party.dart';
import 'package:weighbridge/features/party/domain/repositories/party_repository.dart';
import 'package:weighbridge/features/vehicle/domain/entities/vehicle.dart';
import 'package:weighbridge/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:weighbridge/features/vehicle_type/domain/entities/vehicle_type.dart';
import 'package:weighbridge/features/vehicle_type/domain/repositories/vehicle_type_repository.dart';

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
    Weighment(
      id: 9,
      billNumber: 'WB-00009',
      partyId: 1,
      vehicleId: 1,
      materialId: 1,
      paymentMode: 'Cash',
      grossWeightKg: 0,
      tareWeightKg: 6000,
      netWeightKg: null,
      vehicleCharge: 500,
      amount: 500,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
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
    ).thenAnswer((_) => Future.value([]));
    when(
      () => mockLoadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) => Future.value([]));
    when(
      () => mockGenerateBillNumberUseCase(),
    ).thenAnswer((_) => Future.value('WB-00003'));
    when(
      () => mockLoadPendingBillsUseCase(),
    ).thenAnswer((_) => Future.value(testPendingBills));
    when(() => mockSaveBillUseCase.getWeighmentById(any())).thenAnswer(
      (inv) => Future.value(
        testPendingBills.firstWhere((b) => b.id == inv.positionalArguments[0]),
      ),
    );

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
        child: Scaffold(body: PendingPage(onSwitchToBill: onSwitchToBill)),
      ),
    );
  }

  Future<void> pumpPendingPage(
    WidgetTester tester, {
    VoidCallback? onSwitchToBill,
  }) async {
    await tester.pumpWidget(
      createWidgetUnderTest(onSwitchToBill: onSwitchToBill),
    );
    await tester.runAsync(() async {
      billBloc.add(const LoadBillScreen());
      billBloc.add(const LoadPendingBills());
      await billBloc.stream.firstWhere(
        (s) => s.status == BillScreenStatus.loaded && s.pendingBills.isNotEmpty,
      );
    });
    await tester.pumpAndSettle();
  }

  testWidgets(
    'renders header, stats cards, and pending table with correct data',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await pumpPendingPage(tester);

      // Verify page header
      expect(find.text('Pending Weighments'), findsOneWidget);
      expect(
        find.text('Vehicles waiting for tare weighing to complete the bill'),
        findsOneWidget,
      );

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
      expect(find.text('Total 3 pending weighments'), findsOneWidget);
    },
  );

  testWidgets(
    'renders safely across all desktop window dimensions without RenderFlex overflow',
    (tester) async {
      final sizesToTest = [
        const Size(1920, 1080), // Full HD Large Desktop
        const Size(1600, 900), // Standard Desktop
        const Size(1440, 900), // MacBook Pro Standard
        const Size(1366, 768), // Standard Laptop
        const Size(1280, 720), // Compact Laptop
        const Size(1152, 720), // Small Desktop
        const Size(1024, 768), // Legacy Desktop
        const Size(960, 720), // Breakpoint Boundary
        const Size(900, 700), // Narrow Desktop Stacked
        const Size(900, 600), // Minimum Recommended Desktop Window
        const Size(800, 600), // Compact Desktop Constraint
        const Size(700, 600), // Small Stacked
        const Size(640, 480), // Minimized Window Boundary
        const Size(1280, 500), // Short Window Height
      ];

      addTearDown(() => tester.view.resetPhysicalSize());

      for (final size in sizesToTest) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await pumpPendingPage(tester);

        expect(
          tester.takeException(),
          isNull,
          reason: 'Failed at size: ${size.width}x${size.height}',
        );
        expect(
          find.text('Pending Weighments'),
          findsOneWidget,
          reason: 'Header missing at ${size.width}x${size.height}',
        );
        expect(
          find.text('Pending Queue'),
          findsOneWidget,
          reason: 'Queue card missing at ${size.width}x${size.height}',
        );
        expect(
          find.text('Gross Weight Captured'),
          findsOneWidget,
          reason: 'Weight card missing at ${size.width}x${size.height}',
        );
        expect(
          find.text('Expected Charges'),
          findsOneWidget,
          reason: 'Charges card missing at ${size.width}x${size.height}',
        );
      }
    },
  );

  testWidgets('search and clear input filters pending bills correctly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await pumpPendingPage(tester);

    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Search for nonexistent query
    await tester.enterText(searchField, 'NONEXISTENT_QUERY');
    await tester.pumpAndSettle();

    expect(find.text('No pending weighments'), findsOneWidget);
    expect(find.text('WB-00001'), findsNothing);

    // Clear search using clear button
    final clearButton = find.byIcon(Icons.clear);
    expect(clearButton, findsOneWidget);
    await tester.tap(clearButton);
    await tester.pumpAndSettle();

    expect(find.text('WB-00001'), findsOneWidget);
  });

  testWidgets(
    'tapping Tare Weight button loads pending bill and invokes callback',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool callbackInvoked = false;

      await pumpPendingPage(
        tester,
        onSwitchToBill: () {
          callbackInvoked = true;
        },
      );

      final tareWeightButtons = find.widgetWithText(
        FilledButton,
        'Tare Weight',
      );
      expect(tareWeightButtons, findsWidgets);

      await tester.tap(tareWeightButtons.first);
      await tester.pump();
      await tester.runAsync(() async {
        await billBloc.stream.firstWhere((s) => s.editingBillId == 1);
      });
      await tester.pumpAndSettle();

      expect(callbackInvoked, isTrue);
      expect(billBloc.state.editingBillId, equals(1));
    },
  );

  testWidgets(
    'clicking pending bill row opens details popup and close button dismisses it',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await pumpPendingPage(tester);

      // Tap on the row text to open popup
      await tester.tap(find.text('WB-00001'));
      await tester.pumpAndSettle();

      // Verify popup letterhead & header
      expect(find.text('VIYAN WEIGHBRIDGE'), findsOneWidget);
      expect(find.text('Computer Weigh Bridge'), findsOneWidget);
      expect(find.text('24 HOURS SERVICE'), findsOneWidget);

      // Verify popup title for tare-pending
      expect(
        find.text('WEIGHMENT RECEIPT — TARE WEIGHT PENDING'),
        findsOneWidget,
      );

      // Verify popup bill info
      expect(find.text('Bill No.'), findsOneWidget);
      expect(find.text('WB-00001'), findsWidgets);
      expect(find.text('Vehicle No.'), findsOneWidget);
      expect(find.text('MH 12 AB 1234'), findsWidgets);
      expect(find.text('Material'), findsOneWidget);
      expect(find.text('Sand'), findsWidgets);
      expect(find.text('Party'), findsOneWidget);
      expect(find.text('UltraTech Cement'), findsWidgets);

      // Verify popup weights
      expect(find.text('Gross Weight'), findsWidgets);
      expect(find.text('Tare Weight'), findsWidgets);
      expect(find.text('Net Weight'), findsWidgets);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);

      // Verify status badge
      expect(find.text('TARE WEIGHT PENDING'), findsWidgets);

      // Verify footer note
      expect(find.textContaining('Tare weight is pending'), findsOneWidget);

      // Verify popup action buttons: Close, Print Ticket, Tare Weight
      expect(find.widgetWithText(OutlinedButton, 'Close'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'Print Ticket'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Tare Weight'), findsWidgets);

      // Click Close to dismiss
      await tester.tap(find.widgetWithText(OutlinedButton, 'Close'));
      await tester.pumpAndSettle();

      expect(find.text('VIYAN WEIGHBRIDGE'), findsNothing);
    },
  );

  testWidgets(
    'clicking Tare Weight inside popup loads bill and invokes callback',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool callbackInvoked = false;

      await pumpPendingPage(
        tester,
        onSwitchToBill: () {
          callbackInvoked = true;
        },
      );

      // Open popup
      await tester.tap(find.text('WB-00001'));
      await tester.pumpAndSettle();

      // Tap Tare Weight inside the popup
      final popupTareButton = find.descendant(
        of: find.byType(Dialog),
        matching: find.widgetWithText(FilledButton, 'Tare Weight'),
      );
      expect(popupTareButton, findsOneWidget);

      await tester.tap(popupTareButton);
      await tester.pump();
      await tester.runAsync(() async {
        await billBloc.stream.firstWhere((s) => s.editingBillId == 1);
      });
      await tester.pumpAndSettle();

      // Popup is dismissed, bill is loaded, and switch callback is invoked
      expect(find.byType(Dialog), findsNothing);
      expect(callbackInvoked, isTrue);
      expect(billBloc.state.editingBillId, equals(1));
    },
  );

  testWidgets(
    'supports tare-first pending weighment with Gross Weight Pending popup',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool callbackInvoked = false;

      await pumpPendingPage(
        tester,
        onSwitchToBill: () {
          callbackInvoked = true;
        },
      );

      // Verify row displays Gross Weight Pending
      expect(find.text('WB-00009'), findsOneWidget);
      expect(find.text('Gross Weight Pending'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Gross Weight'), findsOneWidget);

      // Open popup for WB-00009
      await tester.tap(find.text('WB-00009'));
      await tester.pumpAndSettle();

      // Verify popup reflects gross weight pending
      expect(
        find.text('WEIGHMENT RECEIPT — GROSS WEIGHT PENDING'),
        findsOneWidget,
      );
      expect(find.text('GROSS WEIGHT PENDING'), findsOneWidget);
      expect(find.textContaining('Gross weight is pending'), findsOneWidget);

      final popupGrossButton = find.descendant(
        of: find.byType(Dialog),
        matching: find.widgetWithText(FilledButton, 'Gross Weight'),
      );
      expect(popupGrossButton, findsOneWidget);

      await tester.tap(popupGrossButton);
      await tester.pump();
      await tester.runAsync(() async {
        await billBloc.stream.firstWhere((s) => s.editingBillId == 9);
      });
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(callbackInvoked, isTrue);
      expect(billBloc.state.editingBillId, equals(9));
    },
  );
}
