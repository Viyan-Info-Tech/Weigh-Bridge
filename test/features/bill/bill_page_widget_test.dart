import 'package:flutter/material.dart' hide Material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/material.dart' as domain;
import 'package:weighbridge/features/bill/domain/entities/party.dart';
import 'package:weighbridge/features/bill/domain/entities/vehicle.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/load_materials.dart';
import 'package:weighbridge/features/bill/domain/usecases/load_parties.dart';
import 'package:weighbridge/features/bill/domain/usecases/load_vehicles.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/bill/presentation/pages/bill_page.dart';

class MockLoadPartiesUseCase extends Mock implements LoadPartiesUseCase {}

class MockLoadVehiclesUseCase extends Mock implements LoadVehiclesUseCase {}

class MockLoadMaterialsUseCase extends Mock implements LoadMaterialsUseCase {}

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

void main() {
  late BillBloc billBloc;
  late MockLoadPartiesUseCase mockLoadPartiesUseCase;
  late MockLoadVehiclesUseCase mockLoadVehiclesUseCase;
  late MockLoadMaterialsUseCase mockLoadMaterialsUseCase;
  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;

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
      partyId: 1,
      vehicleType: '10 Wheeler',
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  final testMaterials = [
    domain.Material(
      id: 1,
      name: 'Sand',
      unit: 'ton',
      defaultRate: 500,
      isActive: true,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  final testBills = [
    Weighment(
      id: 1,
      billNumber: 'WB-00001',
      partyId: 1,
      vehicleId: 1,
      materialId: 1,
      entryType: 'inbound',
      paymentMode: 'cash',
      firstWeightKg: 25000,
      secondWeightKg: 10000,
      netWeightKg: 15000,
      ratePerTon: 500,
      amount: 7500,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  setUp(() {
    mockLoadPartiesUseCase = MockLoadPartiesUseCase();
    mockLoadVehiclesUseCase = MockLoadVehiclesUseCase();
    mockLoadMaterialsUseCase = MockLoadMaterialsUseCase();
    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();

    when(() => mockLoadPartiesUseCase()).thenAnswer((_) async => testParties);
    when(() => mockLoadVehiclesUseCase()).thenAnswer((_) async => testVehicles);
    when(() => mockLoadMaterialsUseCase())
        .thenAnswer((_) async => testMaterials);
    when(() => mockLoadRecentBillsUseCase())
        .thenAnswer((_) async => testBills);
    when(() => mockLoadRecentBillsUseCase(limit: any(named: 'limit')))
        .thenAnswer((_) async => testBills);
    when(() => mockGenerateBillNumberUseCase())
        .thenAnswer((_) async => 'WB-00002');

    billBloc = BillBloc(
      loadPartiesUseCase: mockLoadPartiesUseCase,
      loadVehiclesUseCase: mockLoadVehiclesUseCase,
      loadMaterialsUseCase: mockLoadMaterialsUseCase,
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
      home: BlocProvider.value(
        value: billBloc,
        child: const BillPage(),
      ),
    );
  }

  Future<void> pumpBillPage(WidgetTester tester) async {
    final loadedFuture = billBloc.stream.firstWhere(
      (state) => state.status == BillScreenStatus.loaded,
    );
    await tester.pumpWidget(createWidgetUnderTest());
    await loadedFuture;
    await tester.pumpAndSettle();
  }

  testWidgets('renders left-side form controls and right-side recent billings',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpBillPage(tester);

    // Verify Header
    expect(find.text('Weighbridge Billing Terminal'), findsOneWidget);

    // Verify Left Side: Live Scale and Bill Form
    expect(find.text('LIVE SCALE 01'), findsOneWidget);
    expect(find.text('Clear Form'), findsOneWidget);
    expect(find.text('Save Ticket'), findsOneWidget);
    expect(find.text('Save & Print Slip'), findsOneWidget);

    // Verify Right Side: Fully Recent Billings panel
    expect(find.text('Recent Billings'), findsOneWidget);
    expect(find.text('WB-00001'), findsWidgets);
    expect(find.text('MH 12 AB 1234'), findsWidgets);
    expect(find.text('UltraTech Cement'), findsWidgets);
  });

  testWidgets('filters recent bills when typing in search field',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpBillPage(tester);

    // Search for nonexistent vehicle
    await tester.enterText(
        find.byKey(const Key('recent_bills_search_field')), 'NONEXISTENT');
    await tester.pumpAndSettle();

    expect(find.text('No matching billings'), findsOneWidget);

    // Search for matching vehicle
    await tester.enterText(
        find.byKey(const Key('recent_bills_search_field')), 'MH 12');
    await tester.pumpAndSettle();

    expect(find.text('WB-00001'), findsWidgets);
  });

  testWidgets('opens weighment slip dialog when clicking print icon',
      (tester) async {
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
    expect(find.text('Weighment Slip: WB-00001'), findsOneWidget);
    expect(find.text('Print Ticket'), findsOneWidget);
  });
}
