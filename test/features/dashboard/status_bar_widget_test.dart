import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/auth/domain/entities/user.dart';
import 'package:weighbridge/features/auth/domain/usecases/get_current_user.dart';
import 'package:weighbridge/features/auth/domain/usecases/is_authenticated.dart';
import 'package:weighbridge/features/auth/domain/usecases/login.dart';
import 'package:weighbridge/features/auth/domain/usecases/logout.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/customer/domain/entities/customer.dart';
import 'package:weighbridge/features/customer/domain/repositories/customer_repository.dart';
import 'package:weighbridge/features/customer/domain/usecases/create_customer.dart';
import 'package:weighbridge/features/customer/domain/usecases/deactivate_customer.dart';
import 'package:weighbridge/features/customer/domain/usecases/delete_customer.dart';
import 'package:weighbridge/features/customer/domain/usecases/load_customers.dart';
import 'package:weighbridge/features/customer/domain/usecases/search_customers.dart';
import 'package:weighbridge/features/customer/domain/usecases/update_customer.dart';
import 'package:weighbridge/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:weighbridge/features/dashboard/presentation/pages/home_page.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/material/domain/usecases/create_material.dart';
import 'package:weighbridge/features/material/domain/usecases/delete_material.dart';
import 'package:weighbridge/features/material/domain/usecases/load_materials.dart';
import 'package:weighbridge/features/material/presentation/bloc/material_bloc.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';
import 'package:weighbridge/features/report/domain/entities/report_summary.dart';
import 'package:weighbridge/features/report/domain/entities/weighment_report_item.dart';
import 'package:weighbridge/features/report/domain/repositories/report_repository.dart';
import 'package:weighbridge/features/report/domain/usecases/export_report_usecase.dart';
import 'package:weighbridge/features/report/presentation/bloc/report_bloc.dart';
import 'package:weighbridge/features/settings/domain/entities/billing_settings.dart';
import 'package:weighbridge/features/settings/domain/usecases/get_settings.dart';
import 'package:weighbridge/features/settings/domain/usecases/update_settings.dart';
import 'package:weighbridge/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:weighbridge/core/hardware/scale/data/fake_scale_service.dart';
import 'package:weighbridge/core/licensing/domain/entities/license.dart';
import 'package:weighbridge/core/licensing/domain/enums/license_status.dart';

import 'status_bar_test_support.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockIsAuthenticatedUseCase extends Mock
    implements IsAuthenticatedUseCase {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockMaterialRepository extends Mock implements MaterialItemRepository {}

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

class MockCreateCustomerUseCase extends Mock implements CreateCustomerUseCase {}

class MockUpdateCustomerUseCase extends Mock implements UpdateCustomerUseCase {}

class MockDeactivateCustomerUseCase extends Mock
    implements DeactivateCustomerUseCase {}

class MockDeleteCustomerUseCase extends Mock implements DeleteCustomerUseCase {}

class MockSearchCustomersUseCase extends Mock
    implements SearchCustomersUseCase {}

class MockCreateMaterialUseCase extends Mock implements CreateMaterialUseCase {}

class MockDeleteMaterialUseCase extends Mock implements DeleteMaterialUseCase {}

class MockGetSettingsUseCase extends Mock implements GetSettingsUseCase {}

class MockUpdateSettingsUseCase extends Mock implements UpdateSettingsUseCase {}

class MockReportRepository extends Mock implements ReportRepository {}

class MockExportReportUseCase extends Mock implements ExportReportUseCase {}

void main() {
  late FakeScaleService scaleService;

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 9, 21));
    registerFallbackValue(const ReportFilter());
  });

  setUp(() {
    scaleService = FakeScaleService();
  });

  /// HomePage's IndexedStack eagerly builds every page, so the full set of
  /// blocs must be provided for the status bar to render.
  Widget buildHome({
    MockAppDatabase? database,
    MockPrintService? printService,
    MockLicenseService? licenseService,
  }) {
    final user = User(
      id: 1,
      username: 'operator',
      role: 'admin',
      isActive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final settings = BillingSettings(updatedAt: DateTime(2026));

    final loginUseCase = MockLoginUseCase();
    final getCurrentUserUseCase = MockGetCurrentUserUseCase();
    final isAuthenticatedUseCase = MockIsAuthenticatedUseCase();
    final logoutUseCase = MockLogoutUseCase();
    final customerRepository = MockCustomerRepository();
    final materialRepository = MockMaterialRepository();
    final saveBillUseCase = MockSaveBillUseCase();
    final loadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    final generateBillNumberUseCase = MockGenerateBillNumberUseCase();
    final createCustomerUseCase = MockCreateCustomerUseCase();
    final updateCustomerUseCase = MockUpdateCustomerUseCase();
    final deactivateCustomerUseCase = MockDeactivateCustomerUseCase();
    final deleteCustomerUseCase = MockDeleteCustomerUseCase();
    final searchCustomersUseCase = MockSearchCustomersUseCase();
    final createMaterialUseCase = MockCreateMaterialUseCase();
    final deleteMaterialUseCase = MockDeleteMaterialUseCase();
    final getSettingsUseCase = MockGetSettingsUseCase();
    final updateSettingsUseCase = MockUpdateSettingsUseCase();
    final reportRepository = MockReportRepository();
    final exportReportUseCase = MockExportReportUseCase();

    when(() => getCurrentUserUseCase()).thenAnswer((_) async => Right(user));
    when(
      () => isAuthenticatedUseCase(),
    ).thenAnswer((_) async => const Right(true));
    when(
      () => customerRepository.getAllActiveCustomers(),
    ).thenAnswer((_) async => <Customer>[]);
    when(
      () => customerRepository.getAllCustomers(),
    ).thenAnswer((_) async => <Customer>[]);
    when(
      () => customerRepository.totalCustomerCount(),
    ).thenAnswer((_) async => 0);
    when(
      () => customerRepository.activeCustomerCount(),
    ).thenAnswer((_) async => 0);
    when(
      () => customerRepository.inactiveCustomerCount(),
    ).thenAnswer((_) async => 0);
    when(
      () => materialRepository.getMaterialsByStatus(isActive: true),
    ).thenAnswer((_) async => <MaterialItem>[]);
    when(
      () => materialRepository.getAllMaterials(),
    ).thenAnswer((_) async => <MaterialItem>[]);
    when(() => loadRecentBillsUseCase()).thenAnswer((_) async => <Weighment>[]);
    when(
      () => loadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) async => <Weighment>[]);
    when(() => generateBillNumberUseCase()).thenAnswer((_) async => 'WB-00001');
    when(() => getSettingsUseCase()).thenAnswer((_) async => settings);
    when(
      () => reportRepository.getReportRecords(
        any(),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => <WeighmentReportItem>[]);
    when(
      () => reportRepository.countReportRecords(any()),
    ).thenAnswer((_) async => 0);
    when(
      () => reportRepository.summarizeReportRecords(any()),
    ).thenAnswer((_) async => const ReportSummary());
    when(() => exportReportUseCase(any())).thenAnswer(
      (_) async => ExportReportResult.success('report.csv', 'report.csv'),
    );

    final authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      isAuthenticatedUseCase: isAuthenticatedUseCase,
    );
    final billBloc = BillBloc(
      customerRepository: customerRepository,
      materialRepository: materialRepository,
      saveBillUseCase: saveBillUseCase,
      loadRecentBillsUseCase: loadRecentBillsUseCase,
      generateBillNumberUseCase: generateBillNumberUseCase,
    );
    final customerBloc = CustomerBloc(
      loadCustomersUseCase: LoadCustomersUseCase(customerRepository),
      createCustomerUseCase: createCustomerUseCase,
      updateCustomerUseCase: updateCustomerUseCase,
      deactivateCustomerUseCase: deactivateCustomerUseCase,
      deleteCustomerUseCase: deleteCustomerUseCase,
      searchCustomersUseCase: searchCustomersUseCase,
      customerRepository: customerRepository,
    );
    final materialBloc = MaterialBloc(
      loadMaterialsUseCase: LoadMaterialsUseCase(materialRepository),
      createMaterialUseCase: createMaterialUseCase,
      deleteMaterialUseCase: deleteMaterialUseCase,
      materialRepository: materialRepository,
    );
    final settingsBloc = SettingsBloc(
      getSettingsUseCase: getSettingsUseCase,
      updateSettingsUseCase: updateSettingsUseCase,
    );
    final reportBloc = ReportBloc(
      reportRepository: reportRepository,
      customerRepository: customerRepository,
      materialRepository: materialRepository,
      exportReportUseCase: exportReportUseCase,
    );

    return wrapWithStatusProviders(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<BillBloc>.value(value: billBloc),
          BlocProvider<CustomerBloc>.value(value: customerBloc),
          BlocProvider<MaterialBloc>.value(value: materialBloc),
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
          BlocProvider<ReportBloc>.value(value: reportBloc),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
      scaleService: scaleService,
      database: database,
      printService: printService,
      licenseService: licenseService,
    );
  }

  /// HomePage runs a live 1-second clock timer, so pumpAndSettle never
  /// settles. Bounded pumps are used instead (same approach as
  /// dashboard_navigation_test.dart).
  Future<void> pumpStatus(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));
  }

  Future<void> setLargeView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('HomePage status bar', () {
    testWidgets('shows live scale plus probed database/printer/license', (
      tester,
    ) async {
      await setLargeView(tester);

      await tester.pumpWidget(buildHome());
      await pumpStatus(tester);

      // Scale starts disconnected until the service connects.
      expect(find.text('Scale: Disconnected'), findsOneWidget);

      // Probes resolved optimistically by the test doubles.
      expect(find.text('Database: Open'), findsOneWidget);
      expect(find.text('Printer: Available'), findsOneWidget);
      expect(find.text('License: Valid'), findsOneWidget);

      // The old hardcoded values are gone.
      expect(find.text('Ready'), findsNothing);
      expect(find.text('Database: Connected'), findsNothing);
      expect(find.text('Printer: Ready'), findsNothing);
    });

    testWidgets('reflects scale connections and drops live', (tester) async {
      await setLargeView(tester);

      await tester.pumpWidget(buildHome());
      await pumpStatus(tester);
      expect(find.text('Scale: Disconnected'), findsOneWidget);

      scaleService.simulateReading(1200);
      await pumpStatus(tester);
      expect(find.text('Scale: Connected'), findsOneWidget);

      scaleService.simulateDisconnect();
      await pumpStatus(tester);
      expect(find.text('Scale: Disconnected'), findsOneWidget);
    });

    testWidgets('shows error states when probes fail', (tester) async {
      await setLargeView(tester);

      final database = MockAppDatabase();
      final printService = MockPrintService();
      final licenseService = MockLicenseService();
      when(() => database.healthCheck()).thenAnswer((_) async => false);
      when(
        () => printService.isPrinterAvailable(),
      ).thenAnswer((_) async => false);
      when(
        () => licenseService.validate(),
      ).thenAnswer((_) async => throw Exception('license file missing'));
      when(() => licenseService.loadLicense()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        buildHome(
          database: database,
          printService: printService,
          licenseService: licenseService,
        ),
      );
      await pumpStatus(tester);

      expect(find.text('Database: Error'), findsOneWidget);
      expect(find.text('Printer: Offline'), findsOneWidget);
      expect(find.text('License: Invalid'), findsOneWidget);
    });

    testWidgets('shows an expiring license with its days remaining', (
      tester,
    ) async {
      await setLargeView(tester);

      final licenseService = MockLicenseService();
      when(
        () => licenseService.validate(),
      ).thenAnswer((_) async => LicenseStatus.valid);
      when(() => licenseService.loadLicense()).thenAnswer(
        (_) async => License(
          licenseId: 'LIC-1',
          productId: 'weighbridge',
          customerId: 'C-1',
          customerName: 'ACME',
          machineHash: 'hash',
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 5, hours: 1)),
          licenseType: 'subscription',
          licenseVersion: 1,
          signature: 'sig',
        ),
      );

      await tester.pumpWidget(buildHome(licenseService: licenseService));
      await pumpStatus(tester);

      expect(find.text('License: Expiring (5d)'), findsOneWidget);
    });
  });
}
