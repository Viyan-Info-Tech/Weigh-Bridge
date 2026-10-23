import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/bill/presentation/pages/bill_page.dart';
import 'package:weighbridge/features/bill/presentation/widgets/bill_form.dart';
import 'package:weighbridge/features/bill/presentation/widgets/weight_display.dart';

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
  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;

  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));

  final testBills = [
    Weighment(
      id: 1,
      billNumber: 'WB-00001',
      vehicleNumber: 'MH 12 AB 1234',
      firstWeightKg: 25000,
      firstWeightType: 'GROSS',
      secondWeightKg: 10000,
      secondWeightType: 'TARE',
      grossWeightKg: 25000,
      tareWeightKg: 10000,
      netWeightKg: 15000,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  final mixedDayBills = [
    ...testBills,
    Weighment(
      id: 2,
      billNumber: 'WB-00000',
      vehicleNumber: 'MH 12 AB 1234',
      firstWeightKg: 10000,
      firstWeightType: 'TARE',
      secondWeightKg: 20000,
      secondWeightType: 'GROSS',
      grossWeightKg: 20000,
      tareWeightKg: 10000,
      netWeightKg: 10000,
      createdAt: yesterday,
      updatedAt: yesterday,
    ),
  ];

  setUp(() {
    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();

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

  testWidgets('renders camera panel, two-section form, and action buttons', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await pumpBillPage(tester);

    // Top camera + live digital weight panel
    expect(find.text('WEIGHT'), findsOneWidget);
    expect(find.text('STABLE'), findsNothing);
    expect(find.text('CAM 01'), findsOneWidget);

    // Left details section
    expect(find.text('SERIAL NO'), findsOneWidget);
    expect(find.text('VEHICLE NO'), findsOneWidget);
    expect(find.text('MATERIAL'), findsOneWidget);
    expect(find.text('DESCRIPTION'), findsNothing);
    expect(find.text('CONTAINER NO'), findsOneWidget);

    // Right weight displays
    expect(find.text('GROSS WEIGHT'), findsOneWidget);
    expect(find.text('TARE WEIGHT'), findsOneWidget);
    expect(find.text('NET WEIGHT'), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('SAVE'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
    expect(find.text('RE-PRINT'), findsOneWidget);
    expect(find.text('MANUAL TARE'), findsOneWidget);
    // The Auto Tare feature was removed: no button, no status indicator.
    expect(find.text('AUTO TARE'), findsNothing);
    expect(find.byKey(const Key('auto_tare_indicator')), findsNothing);
    expect(find.text('EXIT'), findsNothing);
    expect(find.text('RE-SEND SMS'), findsNothing);
  });

  testWidgets(
    'live scale readings update the weight banner without rebuilding the form',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpBillPage(tester);

      final formBefore = tester.widget<BillForm>(find.byType(BillForm));
      final bannerBefore = tester.widget<WeightDisplay>(
        find.byType(WeightDisplay),
      );

      for (final weightKg in [1000.0, 2000.0, 3000.0, 4000.0, 5000.0]) {
        billBloc.add(
          LiveScaleWeightUpdated(weightKg: weightKg, isStable: true),
        );
        await tester.runAsync(
          () => billBloc.stream.firstWhere(
            (state) => state.liveScaleWeightKg == weightKg,
          ),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // The banner follows the live reading...
      expect(
        tester.widget<WeightDisplay>(find.byType(WeightDisplay)),
        isNot(same(bannerBefore)),
      );
      expect(
        tester
            .widget<WeightDisplay>(find.byType(WeightDisplay))
            .liveScaleWeightKg,
        5000,
      );

      // ...while the form and the rest of the page are left alone.
      expect(tester.widget<BillForm>(find.byType(BillForm)), same(formBefore));
    },
  );

  testWidgets('F2 focuses tare weight field for manual entry', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'tareWeightFocusNode',
    );
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

  testWidgets('F9 does not trigger an exit dialog', (tester) async {
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
    expect(find.text('Exit current weighment?'), findsNothing);
  });

  testWidgets('F3 is unassigned and performs no weighment action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);

    billBloc.add(const GrossWeightCommitted('20000'));
    await tester.runAsync(() async {
      await billBloc.stream.firstWhere((state) => state.grossWeightKg == 20000);
    });
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.f3);
    await tester.pumpAndSettle();

    // The Auto Tare feature is gone: F3 must not touch the tare or net
    // weight, and must not open any dialog.
    expect(billBloc.state.tareWeightKg, 0);
    expect(billBloc.state.netWeightKg, 0);
    expect(billBloc.state.tareCapturedAt, isNull);
    expect(find.text('Auto Tare'), findsNothing);
  });

  testWidgets('F4 triggers re-print action', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.f4);
    await tester.pumpAndSettle();
    expect(find.text('Print Ticket'), findsWidgets);
  });

  testWidgets('Escape clears unsaved weighment from the focused field', (
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

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Cancel Weighment?'), findsNothing);
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

  testWidgets('opens weighment slip dialog when clicking print icon in drawer', (
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

    // Tap print slip icon on recent bill card
    await tester.tap(find.byKey(const Key('print_slip_button_WB-00001')));
    await tester.pumpAndSettle();

    // Verify dialog opened with bill details. The business name appears in the
    // receipt header and again above the authorised signature, so match both.
    expect(find.text('VIYAN WEIGHBRIDGE'), findsWidgets);
    expect(find.text('WB-00001'), findsWidgets);
    expect(find.text('Print Ticket'), findsOneWidget);
  });
}
