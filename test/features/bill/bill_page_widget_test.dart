import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/customer/domain/entities/customer.dart';
import 'package:weighbridge/features/customer/domain/repositories/customer_repository.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/bill/domain/entities/auto_tare_entry.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/repositories/auto_tare_repository.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/bill/presentation/pages/bill_page.dart';
import 'package:weighbridge/features/bill/presentation/widgets/auto_tare_dialog.dart';
import 'package:weighbridge/features/bill/presentation/widgets/bill_form.dart';
import 'package:weighbridge/features/bill/presentation/widgets/weight_display.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

/// Minimal in-memory auto tare store with the same one-row-per-day rule as the
/// database.
class _FakeAutoTareRepository implements AutoTareRepository {
  final Map<DateTime, double> _byDay = {};

  /// Makes every write throw, standing in for a SQLite failure.
  bool failWrites = false;

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Future<AutoTareEntry?> getAutoTare(DateTime date) async {
    final tareKg = _byDay[_day(date)];
    return tareKg == null
        ? null
        : AutoTareEntry(tareDate: _day(date), tareKg: tareKg);
  }

  @override
  Future<AutoTareEntry> saveAutoTare({
    required DateTime date,
    required double tareKg,
  }) async {
    if (failWrites) throw Exception('disk full');
    _byDay[_day(date)] = tareKg;
    return AutoTareEntry(tareDate: _day(date), tareKg: tareKg);
  }

  @override
  Future<void> deleteAutoTare(DateTime date) async {
    if (failWrites) throw Exception('disk full');
    _byDay.remove(_day(date));
  }
}

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
  late _FakeAutoTareRepository autoTareRepository;

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
    autoTareRepository = _FakeAutoTareRepository();

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
      autoTareRepository: autoTareRepository,
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
    expect(find.text('NET WEIGHT'), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('SAVE'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
    expect(find.text('RE-PRINT'), findsOneWidget);
    expect(find.text('MANUAL TARE'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Wrap), matching: find.text('AUTO TARE')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('auto_tare_indicator')), findsOneWidget);
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

  testWidgets(
    'saving the same auto tare again closes the dialog instead of spinning',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpBillPage(tester);

      // First save creates the day record.
      await tester.tap(find.byKey(const Key('auto_tare_indicator')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('auto_tare_weight_field')),
        '100',
      );
      final saveButton = find.byKey(const Key('auto_tare_save_button'));
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.runAsync(
        () => billBloc.stream.firstWhere((state) => state.autoTareKg == 100),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AutoTareDialog), findsNothing);
      expect(billBloc.state.autoTareKg, 100);

      // Second save with the identical value produces no state change, which
      // previously left the dialog stuck in its loading state.
      await tester.tap(find.byKey(const Key('auto_tare_indicator')));
      await tester.pumpAndSettle();
      expect(find.byType(AutoTareDialog), findsOneWidget);

      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      // No new state is emitted here, so the dialog closing is the only
      // observable signal that the save completed. The bloc handler runs in
      // real async, which widget tests only advance inside runAsync.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AutoTareDialog), findsNothing);
      expect(billBloc.state.autoTareKg, 100);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'a failing auto tare save surfaces an error and unlocks the form',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      autoTareRepository.failWrites = true;
      await pumpBillPage(tester);

      await tester.tap(find.byKey(const Key('auto_tare_indicator')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('auto_tare_weight_field')),
        '100',
      );
      final saveButton = find.byKey(const Key('auto_tare_save_button'));
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();

      expect(find.text('disk full'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // The controls are usable again, so the operator is not locked out.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AutoTareDialog), findsNothing);
    },
  );

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

  testWidgets(
    'tapping the auto tare status opens the dialog prefilled with a stable '
    'live reading',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await pumpBillPage(tester);
      billBloc.add(
        const LiveScaleWeightUpdated(weightKg: 10200, isStable: true),
      );
      await tester.runAsync(() async {
        await billBloc.stream.firstWhere(
          (state) => state.liveScaleWeightKg == 10200,
        );
      });
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('auto_tare_indicator')));
      await tester.pumpAndSettle();

      expect(find.text('Enter Auto Tare'), findsOneWidget);
      expect(find.text('Save Auto Tare'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(
              find.descendant(
                of: find.byType(AutoTareDialog),
                matching: find.byType(TextFormField),
              ),
            )
            .controller
            ?.text,
        '10200',
      );
      // Opening the dialog must not touch the bill's own tare field.
      expect(billBloc.state.tareWeightKg, 0);
    },
  );

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

  testWidgets('the auto tare status opens the configuration screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);

    await tester.tap(find.byKey(const Key('auto_tare_indicator')));
    await tester.pumpAndSettle();

    expect(find.text('Enter Auto Tare'), findsOneWidget);
    expect(find.text('Not Set'), findsWidgets);
    expect(find.byKey(const Key('auto_tare_save_button')), findsOneWidget);
  });

  testWidgets('saving an auto tare updates the status control immediately', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);

    await tester.tap(find.byKey(const Key('auto_tare_indicator')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('auto_tare_weight_field')),
      '8000',
    );
    final saveButton = find.byKey(const Key('auto_tare_save_button'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.runAsync(
      () => billBloc.stream.firstWhere((state) => state.autoTareKg == 8000),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AutoTareDialog), findsNothing);
    // The configured value is reported on the status control.
    expect(
      find.descendant(
        of: find.byKey(const Key('auto_tare_indicator')),
        matching: find.text('8,000 Kg'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'F3 applies the saved auto tare to the bill and captures the current time',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await pumpBillPage(tester);

      billBloc.add(const SaveAutoTare(8000));
      billBloc.add(const GrossWeightCommitted('20000'));
      await tester.runAsync(() async {
        await billBloc.stream.firstWhere(
          (state) => state.autoTareKg == 8000 && state.grossWeightKg == 20000,
        );
      });
      await tester.pumpAndSettle();

      final before = DateTime.now();
      await tester.sendKeyEvent(LogicalKeyboardKey.f3);
      await tester.pumpAndSettle();

      expect(billBloc.state.tareWeightKg, 8000);
      expect(billBloc.state.netWeightKg, 12000);
      // The capture timestamp is when F3 was pressed, not when the auto tare
      // was configured.
      expect(billBloc.state.tareCapturedAt, isNotNull);
      expect(
        billBloc.state.tareCapturedAt!.isBefore(
          before.subtract(const Duration(seconds: 2)),
        ),
        isFalse,
      );
      expect(find.text('Enter Auto Tare'), findsNothing);
    },
  );

  testWidgets(
    'F3 opens the configuration screen when no auto tare is configured',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await pumpBillPage(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.f3);
      await tester.pumpAndSettle();

      // Nothing to apply, so the operator is taken straight to configuration
      // instead of F3 silently doing nothing.
      expect(find.byType(AutoTareDialog), findsOneWidget);
      expect(billBloc.state.tareWeightKg, 0);
    },
  );

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

  testWidgets('Escape prompts to cancel weighment when unsaved data exists', (
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
    expect(find.text('Cancel Weighment?'), findsWidgets);
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

      // Verify dialog opened with bill details. The business name appears in the
      // receipt header and again above the authorised signature, so match both.
      expect(find.text('VIYAN WEIGHBRIDGE'), findsWidgets);
      expect(find.text('WB-00001'), findsWidgets);
      expect(find.text('Print Ticket'), findsOneWidget);
    },
  );
}
