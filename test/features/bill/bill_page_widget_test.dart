import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/auto_tare_entry.dart';
import 'package:weighbridge/features/bill/domain/entities/vehicle_tare_record.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/repositories/auto_tare_repository.dart';
import 'package:weighbridge/features/bill/domain/repositories/vehicle_tare_repository.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/bill/presentation/pages/bill_page.dart';
import 'package:weighbridge/features/bill/presentation/widgets/auto_tare_dialog.dart';
import 'package:weighbridge/features/bill/presentation/widgets/bill_form.dart';
import 'package:weighbridge/features/bill/presentation/widgets/weight_display.dart';

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
    DateTime? savedAt,
  }) async {
    if (failWrites) throw Exception('disk full');
    _byDay[_day(date)] = tareKg;
    final now = savedAt ?? DateTime.now();
    return AutoTareEntry(
      tareDate: _day(date),
      tareKg: tareKg,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> deleteAutoTare(DateTime date) async {
    if (failWrites) throw Exception('disk full');
    _byDay.remove(_day(date));
  }
}

/// Minimal in-memory vehicle tare registry mirroring the upsert rule of the
/// database: re-adding a vehicle updates its tare instead of duplicating it.
class _FakeVehicleTareRepository implements VehicleTareRepository {
  final Map<String, double> _byVehicle = {};

  /// Makes every write throw, standing in for a SQLite failure.
  bool failWrites = false;

  @override
  Future<List<VehicleTareRecord>> loadVehicleTares() async {
    final vehicles = _byVehicle.keys.toList()..sort();
    return [
      for (final vehicle in vehicles)
        VehicleTareRecord(vehicleNumber: vehicle, tareKg: _byVehicle[vehicle]!),
    ];
  }

  @override
  Future<VehicleTareRecord> saveVehicleTare({
    required String vehicleNumber,
    required double tareKg,
  }) async {
    if (failWrites) throw Exception('disk full');
    final normalized = vehicleNumber.trim().toUpperCase();
    if (normalized.isEmpty) throw ArgumentError('Vehicle number is required.');
    if (!tareKg.isFinite || tareKg <= 0) {
      throw ArgumentError('Tare weight must be greater than zero.');
    }
    _byVehicle[normalized] = tareKg;
    return VehicleTareRecord(vehicleNumber: normalized, tareKg: tareKg);
  }

  @override
  Future<void> deleteVehicleTare(String vehicleNumber) async {
    if (failWrites) throw Exception('disk full');
    _byVehicle.remove(vehicleNumber.trim().toUpperCase());
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026, 9, 12));
  });

  late BillBloc billBloc;
  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;
  late _FakeAutoTareRepository autoTareRepository;
  late _FakeVehicleTareRepository vehicleTareRepository;

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
    autoTareRepository = _FakeAutoTareRepository();
    vehicleTareRepository = _FakeVehicleTareRepository();

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
      autoTareRepository: autoTareRepository,
      vehicleTareRepository: vehicleTareRepository,
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
    expect(find.text('DESCRIPTION'), findsOneWidget);
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
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pumpAndSettle();
    expect(billBloc.state.tareWeightKg, 0);
  });

  testWidgets(
    'adding a vehicle tare persists it and refreshes the table',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpBillPage(tester);

      // Open the registry: empty table, entry form hidden, Add + Cancel only.
      await tester.tap(find.byKey(const Key('auto_tare_indicator')));
      await tester.pumpAndSettle();
      expect(find.byType(AutoTareDialog), findsOneWidget);
      expect(find.text('SL NO'), findsOneWidget);
      expect(find.text('VEHICLE NO'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AutoTareDialog),
          matching: find.text('WEIGHT'),
        ),
        findsOneWidget,
      );
      expect(find.text('No vehicle tare records yet.'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save Auto Tare'), findsNothing);
      expect(find.text('Clear'), findsNothing);
      expect(find.byKey(const Key('vehicle_tare_vehicle_field')), findsNothing);

      // First Add tap reveals the entry form.
      await tester.tap(find.byKey(const Key('vehicle_tare_add_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('vehicle_tare_vehicle_field')), findsOneWidget);
      expect(find.byKey(const Key('auto_tare_weight_field')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('vehicle_tare_vehicle_field')),
        'TN14L1112',
      );
      await tester.enterText(
        find.byKey(const Key('auto_tare_weight_field')),
        '8200',
      );
      await tester.pumpAndSettle();

      // Second Add tap validates and persists.
      await tester.tap(find.byKey(const Key('vehicle_tare_add_button')));
      await tester.runAsync(
        () => billBloc.stream.firstWhere(
          (state) => state.vehicleTareRecords.length == 1,
        ),
      );
      await tester.pumpAndSettle();

      // The table refreshes in place; the dialog stays open for more entries.
      expect(find.byType(AutoTareDialog), findsOneWidget);
      expect(find.text('TN14L1112'), findsOneWidget);
      expect(find.text('8,200 Kg'), findsOneWidget);
      expect(find.text('No vehicle tare records yet.'), findsNothing);
      expect(billBloc.state.vehicleTareRecords.single.tareKg, 8200);

      // Adding creates a registry record, never a weighment.
      expect(billBloc.state.tareWeightKg, 0);
      expect(billBloc.state.recentBills, hasLength(1));

      // Cancel closes without touching the saved record.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AutoTareDialog), findsNothing);
      expect(billBloc.state.vehicleTareRecords, hasLength(1));
    },
  );

  testWidgets(
    'a failing vehicle tare add surfaces an error and keeps the dialog open',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      vehicleTareRepository.failWrites = true;
      await pumpBillPage(tester);

      await tester.tap(find.byKey(const Key('auto_tare_indicator')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('vehicle_tare_add_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('vehicle_tare_vehicle_field')),
        'TN21AW4924',
      );
      await tester.enterText(
        find.byKey(const Key('auto_tare_weight_field')),
        '7850',
      );
      await tester.tap(find.byKey(const Key('vehicle_tare_add_button')));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();

      expect(find.text('disk full'), findsOneWidget);
      expect(find.byType(AutoTareDialog), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(billBloc.state.vehicleTareRecords, isEmpty);

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
    'opening the dialog shows the registry and Add reveals the entry form',
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

      expect(find.text('Auto Tare'), findsOneWidget);
      expect(find.text('Vehicle tare weight records'), findsOneWidget);
      expect(find.text('SL NO'), findsOneWidget);

      // The entry form (and its live-weight shortcut) appears only after Add.
      await tester.tap(find.byKey(const Key('vehicle_tare_add_button')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('vehicle_tare_vehicle_field')),
        findsOneWidget,
      );
      await tester.tap(find.textContaining('Use Live'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('auto_tare_weight_field')))
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

  testWidgets('the auto tare status opens the vehicle tare registry', (
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

    expect(find.text('Auto Tare'), findsOneWidget);
    expect(find.text('Vehicle tare weight records'), findsOneWidget);
    // Exactly two footer actions: Cancel on the left, Add on the right.
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Save Auto Tare'), findsNothing);
    expect(find.text('Update Auto Tare'), findsNothing);
    expect(find.text('Clear'), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets(
    'adding a vehicle tare leaves the daily status and bill untouched',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await pumpBillPage(tester);

      await tester.tap(find.byKey(const Key('auto_tare_indicator')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('vehicle_tare_add_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('vehicle_tare_vehicle_field')),
        'TN21AV2459',
      );
      await tester.enterText(
        find.byKey(const Key('auto_tare_weight_field')),
        '7510',
      );
      await tester.tap(find.byKey(const Key('vehicle_tare_add_button')));
      await tester.runAsync(
        () => billBloc.stream.firstWhere(
          (state) => state.vehicleTareRecords.length == 1,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AutoTareDialog), findsOneWidget);
      expect(find.text('TN21AV2459'), findsOneWidget);
      // The registry is reference data: the day's common tare and the
      // in-progress bill are untouched by managing it.
      expect(billBloc.state.hasAutoTare, isFalse);
      expect(billBloc.state.tareWeightKg, 0);
      expect(find.text('Not Set'), findsWidgets);
    },
  );

  /// Seeds one registry record straight through the bloc, then opens the
  /// popup and pumps until the dialog is visible.
  Future<void> openRegistryWithRecord(
    WidgetTester tester,
    String vehicle,
    double tareKg,
  ) async {
    final completer = Completer<VehicleTareRecord>();
    billBloc.add(SaveVehicleTare(vehicle, tareKg, completer: completer));
    await tester.runAsync(() => completer.future);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('auto_tare_indicator')));
    await tester.pumpAndSettle();
    expect(find.byType(AutoTareDialog), findsOneWidget);
    expect(find.text(vehicle.toUpperCase()), findsOneWidget);
  }

  bool hasSelectionHighlight(WidgetTester tester) {
    for (final container in tester.widgetList<Container>(
      find.byType(Container),
    )) {
      final decoration = container.decoration;
      if (decoration is! BoxDecoration) continue;
      final border = decoration.border;
      if (border is! Border) continue;
      if (border.top.color == const Color(0xFF0D53FC)) return true;
    }
    return false;
  }

  testWidgets('edit without a selection shows a hint and opens no form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);
    await openRegistryWithRecord(tester, 'TN14L1112', 8200);

    expect(find.byKey(const Key('vehicle_tare_edit_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('vehicle_tare_edit_button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Select a record from the table to edit it.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('vehicle_tare_vehicle_field')), findsNothing);
    expect(find.byType(AutoTareDialog), findsOneWidget);
  });

  testWidgets('selecting a row highlights it and edit prefills the form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);
    await openRegistryWithRecord(tester, 'TN14L1112', 8200);

    // No highlight before selection.
    expect(hasSelectionHighlight(tester), isFalse);

    await tester.tap(find.text('TN14L1112'));
    await tester.pumpAndSettle();
    expect(hasSelectionHighlight(tester), isTrue);

    await tester.tap(find.byKey(const Key('vehicle_tare_edit_button')));
    await tester.pumpAndSettle();

    expect(find.text('EDIT VEHICLE TARE'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const Key('vehicle_tare_vehicle_field')),
          )
          .controller
          ?.text,
      'TN14L1112',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('auto_tare_weight_field')))
          .controller
          ?.text,
      '8200',
    );
  });

  testWidgets('editing a weight updates the record and refreshes the table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);
    await openRegistryWithRecord(tester, 'TN14L1112', 8200);

    await tester.tap(find.text('TN14L1112'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vehicle_tare_edit_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('auto_tare_weight_field')),
      '8300',
    );
    await tester.tap(find.byKey(const Key('vehicle_tare_add_button')));
    await tester.runAsync(
      () => billBloc.stream.firstWhere(
        (state) =>
            state.vehicleTareRecords.length == 1 &&
            state.vehicleTareRecords.single.tareKg == 8300,
      ),
    );
    await tester.pumpAndSettle();

    // Table and bloc show the updated tare; the dialog stays open.
    expect(find.text('8,300 Kg'), findsOneWidget);
    expect(find.text('8,200 Kg'), findsNothing);
    expect(find.byType(AutoTareDialog), findsOneWidget);
    // No duplicate row was created.
    expect(billBloc.state.vehicleTareRecords, hasLength(1));
    // The daily tare and the bill are untouched by the edit.
    expect(billBloc.state.hasAutoTare, isFalse);
    expect(billBloc.state.tareWeightKg, 0);
  });

  testWidgets('renaming a vehicle moves the record without duplicating', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);
    await openRegistryWithRecord(tester, 'TN14L1112', 8200);

    await tester.tap(find.text('TN14L1112'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vehicle_tare_edit_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('vehicle_tare_vehicle_field')),
      'TN99ZZ9999',
    );
    await tester.tap(find.byKey(const Key('vehicle_tare_add_button')));
    await tester.runAsync(
      () => billBloc.stream.firstWhere(
        (state) =>
            state.vehicleTareRecords.length == 1 &&
            state.vehicleTareRecords.single.vehicleNumber == 'TN99ZZ9999',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TN99ZZ9999'), findsOneWidget);
    expect(find.text('TN14L1112'), findsNothing);
    expect(billBloc.state.vehicleTareRecords, hasLength(1));
    expect(billBloc.state.vehicleTareRecords.single.tareKg, 8200);
  });

  testWidgets('edit validation rejects an empty weight without saving', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);
    await openRegistryWithRecord(tester, 'TN14L1112', 8200);

    await tester.tap(find.text('TN14L1112'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vehicle_tare_edit_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('auto_tare_weight_field')), '');
    await tester.tap(find.byKey(const Key('vehicle_tare_add_button')));
    await tester.pumpAndSettle();

    expect(find.text('Tare weight is required'), findsOneWidget);
    expect(billBloc.state.vehicleTareRecords.single.tareKg, 8200);
    expect(find.byType(AutoTareDialog), findsOneWidget);
  });

  testWidgets('cancel during edit closes without persisting the edit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await pumpBillPage(tester);
    await openRegistryWithRecord(tester, 'TN14L1112', 8200);

    await tester.tap(find.text('TN14L1112'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vehicle_tare_edit_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('auto_tare_weight_field')),
      '9999',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AutoTareDialog), findsNothing);
    expect(billBloc.state.vehicleTareRecords.single.tareKg, 8200);
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
