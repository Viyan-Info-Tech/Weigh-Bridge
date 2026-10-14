import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
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
  setUpAll(() {
    registerFallbackValue(DateTime(2026, 9, 12));
    registerFallbackValue(const ReportFilter());
  });

  late AuthBloc authBloc;
  late BillBloc billBloc;
  late SettingsBloc settingsBloc;
  late ReportBloc reportBloc;
  late MockAdminPasswordService adminPasswordService;

  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockIsAuthenticatedUseCase mockIsAuthenticatedUseCase;

  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;
  late MockGetSettingsUseCase mockGetSettingsUseCase;
  late MockUpdateSettingsUseCase mockUpdateSettingsUseCase;
  late MockReportRepository mockReportRepository;
  late MockExportReportUseCase mockExportReportUseCase;

  final testUser = User(
    id: 1,
    username: 'Admin',
    role: 'admin',
    isActive: true,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockIsAuthenticatedUseCase = MockIsAuthenticatedUseCase();

    when(
      () => mockGetCurrentUserUseCase(),
    ).thenAnswer((_) => Future.value(Right(testUser)));
    when(
      () => mockIsAuthenticatedUseCase(),
    ).thenAnswer((_) => Future.value(const Right(true)));

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      isAuthenticatedUseCase: mockIsAuthenticatedUseCase,
    );

    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();
    mockGetSettingsUseCase = MockGetSettingsUseCase();
    mockUpdateSettingsUseCase = MockUpdateSettingsUseCase();
    mockReportRepository = MockReportRepository();
    mockExportReportUseCase = MockExportReportUseCase();
    adminPasswordService = MockAdminPasswordService();

    when(
      () => mockLoadRecentBillsUseCase(),
    ).thenAnswer((_) => Future.value(<Weighment>[]));
    when(
      () => mockLoadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) => Future.value(<Weighment>[]));
    when(
      () => mockGenerateBillNumberUseCase(),
    ).thenAnswer((_) => Future.value('WB-00001'));
    when(
      () => mockGetSettingsUseCase(),
    ).thenAnswer((_) async => BillingSettings(updatedAt: DateTime(2026)));
    when(
      () => mockReportRepository.getReportRecords(
        any(),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => <WeighmentReportItem>[]);
    when(
      () => mockReportRepository.countReportRecords(any()),
    ).thenAnswer((_) async => 0);
    when(
      () => mockReportRepository.summarizeReportRecords(any()),
    ).thenAnswer((_) async => const ReportSummary());
    when(() => mockExportReportUseCase(any())).thenAnswer(
      (_) async => ExportReportResult.success('report.csv', 'report.csv'),
    );
    when(
      () => adminPasswordService.verify(any()),
    ).thenAnswer((_) async => true);

    billBloc = BillBloc(
      saveBillUseCase: mockSaveBillUseCase,
      loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
      generateBillNumberUseCase: mockGenerateBillNumberUseCase,
    );
    settingsBloc = SettingsBloc(
      getSettingsUseCase: mockGetSettingsUseCase,
      updateSettingsUseCase: mockUpdateSettingsUseCase,
    );
    reportBloc = ReportBloc(
      reportRepository: mockReportRepository,
      exportReportUseCase: mockExportReportUseCase,
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

  group('HomePage Workstation Layout Tests', () {
    testWidgets('renders top title bar and content', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createHomePageUnderTest());
      await tester.runAsync(() async {
        if (billBloc.state.status != BillScreenStatus.loaded) {
          await billBloc.stream.firstWhere(
            (s) => s.status == BillScreenStatus.loaded,
          );
        }
      });
      await tester.pumpAndSettle();

      // Top title bar: menu toggle + branding on the left, date/time/admin
      // on the right.
      expect(find.text('Admin'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('VIYAN WEIGHBRIDGE'),
        ),
        findsOneWidget,
      );
      expect(find.text('Accurate Weighing  Reliable Business'), findsOneWidget);

      // Navigation lives in a sliding drawer, hidden by default. Only the
      // header toggle is visible until it is opened.
      expect(find.byKey(const Key('nav_menu_toggle')), findsOneWidget);
      expect(find.byKey(const Key('nav_drawer')), findsNothing);
    });
  });
}
