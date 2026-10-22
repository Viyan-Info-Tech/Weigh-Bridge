import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/core/security/admin_password_service.dart';
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
import 'status_bar_test_support.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockIsAuthenticatedUseCase extends Mock
    implements IsAuthenticatedUseCase {}

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

class MockGetSettingsUseCase extends Mock implements GetSettingsUseCase {}

class MockUpdateSettingsUseCase extends Mock implements UpdateSettingsUseCase {}

class MockReportRepository extends Mock implements ReportRepository {}

class MockExportReportUseCase extends Mock implements ExportReportUseCase {}

class MockAdminPasswordService extends Mock implements AdminPasswordService {}

void main() {
  late AuthBloc authBloc;
  late BillBloc billBloc;
  late SettingsBloc settingsBloc;
  late ReportBloc reportBloc;
  late MockLogoutUseCase logoutUseCase;
  late MockAdminPasswordService adminPasswordService;

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
    final saveBillUseCase = MockSaveBillUseCase();
    final loadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    final generateBillNumberUseCase = MockGenerateBillNumberUseCase();
    final getSettingsUseCase = MockGetSettingsUseCase();
    final updateSettingsUseCase = MockUpdateSettingsUseCase();
    final reportRepository = MockReportRepository();
    final exportReportUseCase = MockExportReportUseCase();
    adminPasswordService = MockAdminPasswordService();

    when(() => getCurrentUserUseCase()).thenAnswer((_) async => Right(user));
    when(
      () => isAuthenticatedUseCase(),
    ).thenAnswer((_) async => const Right(true));
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
    when(
      () => adminPasswordService.verify(any()),
    ).thenAnswer((_) async => true);

    authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      isAuthenticatedUseCase: isAuthenticatedUseCase,
    );
    billBloc = BillBloc(
      saveBillUseCase: saveBillUseCase,
      loadRecentBillsUseCase: loadRecentBillsUseCase,
      generateBillNumberUseCase: generateBillNumberUseCase,
    );
    settingsBloc = SettingsBloc(
      getSettingsUseCase: getSettingsUseCase,
      updateSettingsUseCase: updateSettingsUseCase,
    );
    reportBloc = ReportBloc(
      reportRepository: reportRepository,
      exportReportUseCase: exportReportUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
    billBloc.close();
    settingsBloc.close();
    reportBloc.close();
  });

  Widget createHomePageUnderTest() {
    return wrapWithStatusProviders(
      RepositoryProvider<AdminPasswordService>.value(
        value: adminPasswordService,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<BillBloc>.value(value: billBloc),
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
            BlocProvider<ReportBloc>.value(value: reportBloc),
          ],
          child: const MaterialApp(home: HomePage()),
        ),
      ),
    );
  }

  /// HomePage runs a 1-second live-clock timer that calls setState on every
  /// tick (home_page.dart), so pumpAndSettle can never settle. Pump bounded
  /// durations to advance navigation transitions and async bloc state
  /// deterministically instead. Three frames cover the 280 ms drawer
  /// slide/fade plus the rebuild that unmounts it on close.
  Future<void> pumpFrames(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 250));
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

  /// Opens the navigation drawer via the header toggle.
  Future<void> openNavMenu(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('nav_menu_toggle')));
    await pumpFrames(tester);
    expect(find.byKey(const Key('nav_drawer')), findsOneWidget);
  }

  /// Taps a nav item guarded by the administrator password gate and unlocks
  /// it with the stubbed [AdminPasswordService].
  Future<void> tapGuardedTab(WidgetTester tester, String label) async {
    await openNavMenu(tester);
    await tester.tap(find.text(label));
    await pumpFrames(tester);
    expect(find.text('Administrator Access'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '123');
    await tester.tap(find.text('Unlock'));
    await pumpFrames(tester);
  }

  testWidgets('drawer is hidden at startup and opens from the left edge', (
    tester,
  ) async {
    await pumpHomePage(tester);

    // Hidden by default; only the header toggle is visible.
    expect(find.byKey(const Key('nav_drawer')), findsNothing);
    expect(find.byKey(const Key('nav_menu_toggle')), findsOneWidget);

    await openNavMenu(tester);
    expect(find.text('Weighment'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Exit'), findsOneWidget);

    // Full-height panel docked to the left window edge.
    final drawerTopLeft = tester.getTopLeft(
      find.byKey(const Key('nav_drawer')),
    );
    expect(drawerTopLeft.dx, 0);
    expect(tester.getSize(find.byKey(const Key('nav_drawer'))).width, 300);
    // The rest of the application is dimmed behind it.
    expect(find.byKey(const Key('nav_drawer_scrim')), findsOneWidget);

    // Drawer header shows the logo and application name instead of the old
    // NAVIGATION heading.
    expect(find.text('NAVIGATION'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('VIYAN WEIGHBRIDGE'),
      ),
      findsWidgets,
    );

    // The header toggle is covered by the scrim while open, so dismiss by
    // tapping outside instead.
    await tester.tapAt(const Offset(700, 500));
    await pumpFrames(tester);
    expect(find.byKey(const Key('nav_drawer')), findsNothing);
  });

  testWidgets('tapping outside the menu closes it without navigating', (
    tester,
  ) async {
    await pumpHomePage(tester);
    await openNavMenu(tester);

    // Tap the content area below the header (outside the drawer).
    await tester.tapAt(const Offset(700, 500));
    await pumpFrames(tester);
    expect(find.byKey(const Key('nav_drawer')), findsNothing);
    // Still on the weighment screen.
    expect(find.text('WEIGHT'), findsOneWidget);
  });

  testWidgets('Escape closes the drawer without clearing the weighment form', (
    tester,
  ) async {
    await pumpHomePage(tester);

    // Type a vehicle number so a form clear would be observable.
    await tester.enterText(
      find.byKey(const Key('bill_vehicle_number_field')),
      'TN32AB1234',
    );
    await pumpFrames(tester);
    expect(billBloc.state.vehicleNumber, 'TN32AB1234');

    await openNavMenu(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await pumpFrames(tester);

    expect(find.byKey(const Key('nav_drawer')), findsNothing);
    // The weighment form must be untouched: Escape closed the drawer instead
    // of reaching the bill page's cancel shortcut.
    expect(billBloc.state.vehicleNumber, 'TN32AB1234');
  });

  testWidgets('switches from weighment to each dashboard module', (
    tester,
  ) async {
    await pumpHomePage(tester);

    // IndexedStack order: [BillPage, ReportPage, SettingsPage, AboutPage].
    await tapGuardedTab(tester, 'Reports');
    expect(find.text('REPORTS'), findsOneWidget);

    await openNavMenu(tester);
    await tester.tap(find.text('Weighment'));
    await pumpFrames(tester);
    expect(find.text('WEIGHT'), findsOneWidget);

    await tapGuardedTab(tester, 'Settings');
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('opens About from the version link', (tester) async {
    await pumpHomePage(tester);

    await tester.tap(find.text('v3.0.0'));
    await pumpFrames(tester);

    expect(find.text('About ViyanInfo'), findsOneWidget);
    expect(find.text('WEIGHT'), findsNothing);
  });

  testWidgets('logout confirmation cancels without clearing session', (
    tester,
  ) async {
    when(() => logoutUseCase()).thenAnswer((_) async => const Right(null));
    await pumpHomePage(tester);

    await openNavMenu(tester);
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

    await openNavMenu(tester);
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
