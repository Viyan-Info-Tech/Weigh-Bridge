import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weighbridge/core/database/app_database.dart'
    hide Weighment, Vehicle, Party;
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/presentation/widgets/weighment_slip_dialog.dart';
import 'package:weighbridge/features/party/domain/entities/party.dart';
import 'package:weighbridge/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:weighbridge/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';
import 'package:weighbridge/features/settings/domain/usecases/get_settings.dart';
import 'package:weighbridge/features/settings/domain/usecases/update_settings.dart';
import 'package:weighbridge/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:weighbridge/features/settings/presentation/bloc/settings_event.dart';
import 'package:weighbridge/features/settings/presentation/bloc/settings_state.dart';
import 'package:weighbridge/features/settings/presentation/pages/settings_page.dart';
import 'package:weighbridge/features/vehicle/domain/entities/vehicle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SettingsLocalDataSource dataSource;
  late SettingsRepositoryImpl repository;
  late GetSettingsUseCase getSettingsUseCase;
  late UpdateSettingsUseCase updateSettingsUseCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = SettingsLocalDataSource(db);
    repository = SettingsRepositoryImpl(localDataSource: dataSource);
    getSettingsUseCase = GetSettingsUseCase(repository);
    updateSettingsUseCase = UpdateSettingsUseCase(repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('AppSettingsDao & Bill Number Generation Tests', () {
    test(
      'getSettings creates default settings row when database is empty',
      () async {
        final settings = await dataSource.getSettings();

        expect(settings.businessName, 'VIYAN WEIGHBRIDGE');
        expect(settings.billPrefix, 'WB');
        expect(settings.billStartingNumber, 1);
        expect(settings.billNumberDigits, 5);
        expect(settings.weightUnit, 'ton');
        expect(settings.receiptTitle, 'WEIGHMENT RECEIPT');
        expect(settings.showSerialNumber, isTrue);
        expect(settings.showGrossWeight, isTrue);
      },
    );

    test(
      'generateNextBillNumber uses prefix, digits, and starting number correctly',
      () async {
        // 1. Initial next bill when no weighments exist
        final next1 = await db.appSettingsDao.generateNextBillNumber(
          prefix: 'WB',
          digits: 5,
          startingNumber: 1,
        );
        expect(next1, 'WB-00001');

        // 2. Insert weighment with WB-00001
        await db.customStatement(
          "INSERT INTO weighments (bill_number, party_id, vehicle_id, material_id, payment_mode, first_weight_kg) "
          "VALUES ('WB-00001', 1, 1, 1, 'Cash', 15000)",
        );

        final next2 = await db.appSettingsDao.generateNextBillNumber(
          prefix: 'WB',
          digits: 5,
          startingNumber: 1,
        );
        expect(next2, 'WB-00002');

        // 3. Custom prefix INV with starting number 100
        final invNext = await db.appSettingsDao.generateNextBillNumber(
          prefix: 'INV',
          digits: 6,
          startingNumber: 100,
        );
        expect(invNext, 'INV-000100');

        // 4. Insert INV-000100 and verify increment to INV-000101
        await db.customStatement(
          "INSERT INTO weighments (bill_number, party_id, vehicle_id, material_id, payment_mode, first_weight_kg) "
          "VALUES ('INV-000100', 1, 1, 1, 'Cash', 15000)",
        );

        final invNext2 = await db.appSettingsDao.generateNextBillNumber(
          prefix: 'INV',
          digits: 6,
          startingNumber: 100,
        );
        expect(invNext2, 'INV-000101');
      },
    );

    test('updateSettings updates configuration row in SQLite', () async {
      final initial = await dataSource.getSettings();
      final updated = initial.copyWith(
        businessName: 'SUPER WEIGHBRIDGE',
        billPrefix: 'SW',
        billNumberDigits: 4,
        showRemarks: false,
      );

      await dataSource.updateSettings(updated);

      final retrieved = await dataSource.getSettings();
      expect(retrieved.businessName, 'SUPER WEIGHBRIDGE');
      expect(retrieved.billPrefix, 'SW');
      expect(retrieved.billNumberDigits, 4);
      expect(retrieved.showRemarks, isFalse);
    });
  });

  group('SettingsBloc Tests', () {
    test(
      'LoadSettings loads settings successfully and emits loaded state',
      () async {
        final bloc = SettingsBloc(
          getSettingsUseCase: getSettingsUseCase,
          updateSettingsUseCase: updateSettingsUseCase,
        );

        final expectation = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<SettingsState>().having(
              (s) => s.status,
              'status',
              SettingsStatus.loading,
            ),
            isA<SettingsState>()
                .having((s) => s.status, 'status', SettingsStatus.loaded)
                .having(
                  (s) => s.settings?.businessName,
                  'businessName',
                  'VIYAN WEIGHBRIDGE',
                ),
          ]),
        );

        bloc.add(const LoadSettings());
        await expectation;
        await bloc.close();
      },
    );

    test(
      'UpdateBillingSettings updates settings and emits saved state',
      () async {
        final bloc = SettingsBloc(
          getSettingsUseCase: getSettingsUseCase,
          updateSettingsUseCase: updateSettingsUseCase,
        );

        final newSettings = BillingSettings(
          businessName: 'APEX WEIGHBRIDGE',
          billPrefix: 'APX',
          billStartingNumber: 50,
          billNumberDigits: 5,
          updatedAt: DateTime.now(),
        );

        final expectation = expectLater(
          bloc.stream,
          emitsInOrder([
            isA<SettingsState>().having(
              (s) => s.status,
              'status',
              SettingsStatus.saving,
            ),
            isA<SettingsState>()
                .having((s) => s.status, 'status', SettingsStatus.saved)
                .having(
                  (s) => s.settings?.businessName,
                  'businessName',
                  'APEX WEIGHBRIDGE',
                ),
          ]),
        );

        bloc.add(UpdateBillingSettings(newSettings));
        await expectation;
        await bloc.close();
      },
    );
  });

  group('WeighmentSlipDialog Dynamic Settings Tests', () {
    final now = DateTime(2026, 9, 12, 14, 30);
    final testBill = Weighment(
      id: 1,
      billNumber: 'WB-00001',
      partyId: 1,
      vehicleId: 1,
      materialId: 1,
      paymentMode: 'Cash',
      grossWeightKg: 25000,
      tareWeightKg: 10000,
      netWeightKg: 15000,
      amount: 450,
      vehicleCharge: 50.0,
      status: 'completed',
      remarks: 'Customer special order',
      createdAt: now,
      updatedAt: now,
    );

    final testVehicle = Vehicle(
      id: 1,
      vehicleNumber: 'MH 12 AB 1234',
      vehicleTypeId: 1,
      createdAt: now,
      updatedAt: now,
    );

    final testParty = Party(
      id: 1,
      name: 'UltraTech Cement',
      mobile: '9876543210',
      createdAt: now,
      updatedAt: now,
    );

    testWidgets(
      'renders custom business name and respects hidden field flags',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final customSettings = BillingSettings(
          businessName: 'CUSTOM INDUSTRIAL WEIGHBRIDGE',
          receiptTitle: 'OFFICIAL WEIGH SLIP',
          showRemarks: false, // Hidden!
          showParty: false, // Hidden!
          footerNote: 'Mandatory verification before gate exit.',
          updatedAt: now,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WeighmentSlipDialog(
                bill: testBill,
                vehicle: testVehicle,
                party: testParty,
                materialName: 'River Sand',
                settings: customSettings,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Custom business name and title are displayed
        expect(find.text('CUSTOM INDUSTRIAL WEIGHBRIDGE'), findsOneWidget);
        expect(find.text('OFFICIAL WEIGH SLIP'), findsOneWidget);

        // Hidden fields are omitted
        expect(find.text('Customer special order'), findsNothing);
        expect(find.text('UltraTech Cement'), findsNothing);

        // Visible fields are present
        expect(find.text('MH 12 AB 1234'), findsOneWidget);
        expect(find.text('River Sand'), findsOneWidget);
        expect(
          find.text('Note: Mandatory verification before gate exit.'),
          findsOneWidget,
        );
      },
    );
  });

  group('SettingsPage Widget Tests', () {
    testWidgets('renders all settings sections and live preview', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final settingsBloc = SettingsBloc(
        getSettingsUseCase: getSettingsUseCase,
        updateSettingsUseCase: updateSettingsUseCase,
      );
      settingsBloc.add(const LoadSettings());

      await tester.pumpWidget(
        BlocProvider<SettingsBloc>.value(
          value: settingsBloc,
          child: const MaterialApp(home: SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Page Title & Actions (in View Mode)
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Edit Settings'), findsOneWidget);
      expect(find.text('Reset Defaults'), findsOneWidget);

      // Verify Sections
      expect(find.text('Weight Unit'), findsOneWidget);
      expect(find.text('Bill Number Settings'), findsOneWidget);
      expect(find.text('Business Information'), findsOneWidget);
      expect(find.text('Receipt & Ticket Content'), findsOneWidget);
      expect(find.text('Footer Settings'), findsOneWidget);

      // Verify Live Preview Panel
      expect(find.text('Live Receipt Preview'), findsOneWidget);
      expect(find.text('VIYAN WEIGHBRIDGE'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await settingsBloc.close();
    });

    testWidgets('settings controls remain visible at minimum desktop sizes', (
      tester,
    ) async {
      final sizes = <Size>[
        const Size(1400, 900),
        const Size(1100, 720),
        const Size(900, 600),
        const Size(700, 600),
        const Size(640, 480),
      ];

      for (final size in sizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        final settingsBloc = SettingsBloc(
          getSettingsUseCase: getSettingsUseCase,
          updateSettingsUseCase: updateSettingsUseCase,
        );
        settingsBloc.add(const LoadSettings());

        await tester.pumpWidget(
          BlocProvider<SettingsBloc>.value(
            value: settingsBloc,
            child: const MaterialApp(home: SettingsPage()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'exceptions at $size');
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Edit Settings'), findsOneWidget);
        expect(find.text('Reset Defaults'), findsOneWidget);
        expect(find.text('Weight Unit'), findsOneWidget);
        expect(find.text('Live Receipt Preview'), findsOneWidget);

        await tester.ensureVisible(find.text('Edit Settings'));
        await tester.ensureVisible(find.text('Reset Defaults'));

        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await settingsBloc.close();
      }

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
