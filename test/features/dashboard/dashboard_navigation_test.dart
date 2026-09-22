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
import 'package:weighbridge/features/auth/presentation/bloc/auth_event.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_state.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/dashboard/presentation/pages/home_page.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/material/domain/usecases/create_material.dart';
import 'package:weighbridge/features/material/domain/usecases/delete_material.dart';
import 'package:weighbridge/features/material/domain/usecases/load_materials.dart';
import 'package:weighbridge/features/material/presentation/bloc/material_bloc.dart';
import 'package:weighbridge/features/customer/domain/entities/customer.dart';
import 'package:weighbridge/features/customer/domain/repositories/customer_repository.dart';
import 'package:weighbridge/features/customer/domain/usecases/create_customer.dart';
import 'package:weighbridge/features/customer/domain/usecases/deactivate_customer.dart';
import 'package:weighbridge/features/customer/domain/usecases/delete_customer.dart';
import 'package:weighbridge/features/customer/domain/usecases/load_customers.dart';
import 'package:weighbridge/features/customer/domain/usecases/search_customers.dart';
import 'package:weighbridge/features/customer/domain/usecases/update_customer.dart';
import 'package:weighbridge/features/customer/presentation/bloc/customer_bloc.dart';
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
  late AuthBloc authBloc;
  late BillBloc billBloc;
  late CustomerBloc customerBloc;
  late MaterialBloc materialBloc;
  late SettingsBloc settingsBloc;
  late ReportBloc reportBloc;
  late MockLogoutUseCase logoutUseCase;

  final user = User(
    id: 1,
    username: 'operator',
    role: 'admin',
    isActive: true,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final settings = BillingSettings(updatedAt: DateTime(2026));

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 9, 21));
    registerFallbackValue(const ReportFilter());
  });

  setUp(() {
    final loginUseCase = MockLoginUseCase();
    final getCurrentUserUseCase = MockGetCurrentUserUseCase();
    final isAuthenticatedUseCase = MockIsAuthenticatedUseCase();
    logoutUseCase = MockLogoutUseCase();
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
      () => customerRepository.getAllCustomers(),
    ).thenAnswer((_) async => <Customer>[]);
    when(
      () => materialRepository.getAllMaterials(),
    ).thenAnswer((_) async => <MaterialItem>[]);
    when(
      () => reportRepository.getReportRecords(any()),
    ).thenAnswer((_) async => <WeighmentReportItem>[]);
    when(
      () => reportRepository.calculateSummary(any()),
    ).thenAnswer((_) => const ReportSummary());
    when(() => exportReportUseCase(any())).thenAnswer(
      (_) async => ExportReportResult.success('report.csv', 'report.csv'),
    );

    authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      isAuthenticatedUseCase: isAuthenticatedUseCase,
    );
    billBloc = BillBloc(
      customerRepository: customerRepository,
      materialRepository: materialRepository,
      saveBillUseCase: saveBillUseCase,
      loadRecentBillsUseCase: loadRecentBillsUseCase,
      generateBillNumberUseCase: generateBillNumberUseCase,
    );
    customerBloc = CustomerBloc(
      loadCustomersUseCase: LoadCustomersUseCase(customerRepository),
      createCustomerUseCase: createCustomerUseCase,
      updateCustomerUseCase: updateCustomerUseCase,
      deactivateCustomerUseCase: deactivateCustomerUseCase,
      deleteCustomerUseCase: deleteCustomerUseCase,
      searchCustomersUseCase: searchCustomersUseCase,
      customerRepository: customerRepository,
    );
    materialBloc = MaterialBloc(
      loadMaterialsUseCase: LoadMaterialsUseCase(materialRepository),
      createMaterialUseCase: createMaterialUseCase,
      deleteMaterialUseCase: deleteMaterialUseCase,
      materialRepository: materialRepository,
    );
    settingsBloc = SettingsBloc(
      getSettingsUseCase: getSettingsUseCase,
      updateSettingsUseCase: updateSettingsUseCase,
    );
    reportBloc = ReportBloc(
      reportRepository: reportRepository,
      customerRepository: customerRepository,
      materialRepository: materialRepository,
      exportReportUseCase: exportReportUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
    billBloc.close();
    customerBloc.close();
    materialBloc.close();
    settingsBloc.close();
    reportBloc.close();
  });

  Widget createHomePageUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<BillBloc>.value(value: billBloc),
        BlocProvider<CustomerBloc>.value(value: customerBloc),
        BlocProvider<MaterialBloc>.value(value: materialBloc),
        BlocProvider<SettingsBloc>.value(value: settingsBloc),
        BlocProvider<ReportBloc>.value(value: reportBloc),
      ],
      child: const MaterialApp(home: HomePage()),
    );
  }

  /// HomePage runs a 1-second live-clock timer that calls setState on every
  /// tick (home_page.dart), so pumpAndSettle can never settle. Pump bounded
  /// durations to advance navigation transitions and async bloc state
  /// deterministically instead.
  Future<void> pumpFrames(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));
  }

  Future<void> pumpHomePage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    if (authBloc.state.status == AuthStatus.initial ||
        authBloc.state.status == AuthStatus.checking) {
      authBloc.add(const AppStarted());
      // The bloc's events are delivered outside the fake-async zone, so the
      // stream wait must run inside tester.runAsync. Awaiting a bloc stream
      // directly in the test body deadlocks the next guarded pumpWidget call.
      await tester.runAsync(
        () => authBloc.stream.firstWhere(
          (state) => state.status == AuthStatus.authenticated,
        ),
      );
    }
    await tester.pumpWidget(createHomePageUnderTest());
    await pumpFrames(tester);
  }

  testWidgets('switches from weighment to each dashboard module', (
    tester,
  ) async {
    await pumpHomePage(tester);

    await tester.tap(find.text('Configuration'));
    await pumpFrames(tester);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Customer Master'));
    await pumpFrames(tester);
    expect(find.text('Customers'), findsWidgets);

    await tester.tap(find.text('Material Master'));
    await pumpFrames(tester);
    expect(find.text('Materials'), findsWidgets);

    await tester.tap(find.text('Reports'));
    await pumpFrames(tester);
    expect(find.text('REPORTS'), findsOneWidget);

    await tester.tap(find.text('Bill'));
    await pumpFrames(tester);
    expect(find.text('WEIGHT'), findsOneWidget);
  });

  testWidgets('opens About from the version link', (tester) async {
    await pumpHomePage(tester);

    await tester.tap(find.text('Viyan Weighbridge v1.0.0'));
    await pumpFrames(tester);

    expect(find.text('About ViyanInfo'), findsOneWidget);
    expect(find.text('WEIGHT'), findsNothing);
  });

  testWidgets('logout confirmation cancels without clearing session', (
    tester,
  ) async {
    when(() => logoutUseCase()).thenAnswer((_) async => const Right(null));
    await pumpHomePage(tester);

    await tester.tap(find.text('Exit'));
    await pumpFrames(tester);
    expect(find.text('Exit Application'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await pumpFrames(tester);

    expect(find.text('Exit Application'), findsNothing);
    verifyNever(() => logoutUseCase());
    expect(authBloc.state.status, AuthStatus.authenticated);
  });

  testWidgets('logout confirmation emits logout and clears authentication', (
    tester,
  ) async {
    when(() => logoutUseCase()).thenAnswer((_) async => const Right(null));
    await pumpHomePage(tester);

    await tester.tap(find.text('Exit'));
    await pumpFrames(tester);
    final emission = authBloc.stream.firstWhere(
      (state) => state.status == AuthStatus.unauthenticated,
    );

    await tester.tap(find.text('Exit').last);
    await tester.runAsync(() => emission);
    await pumpFrames(tester);

    verify(() => logoutUseCase()).called(1);
    expect(authBloc.state.status, AuthStatus.unauthenticated);
    expect(authBloc.state.user, isNull);
    expect(find.text('Exit Application'), findsNothing);
  });
}
