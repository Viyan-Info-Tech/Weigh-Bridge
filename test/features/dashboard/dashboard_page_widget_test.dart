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
import 'package:weighbridge/features/bill/domain/entities/party.dart';
import 'package:weighbridge/features/bill/domain/entities/vehicle.dart';
import 'package:weighbridge/features/bill/domain/entities/material.dart' as domain;
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/load_materials.dart';
import 'package:weighbridge/features/bill/domain/usecases/load_parties.dart';
import 'package:weighbridge/features/bill/domain/usecases/load_vehicles.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/dashboard/presentation/pages/home_page.dart';
import 'package:weighbridge/features/dashboard/presentation/widgets/app_sidebar.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockIsAuthenticatedUseCase extends Mock implements IsAuthenticatedUseCase {}

class MockLoadPartiesUseCase extends Mock implements LoadPartiesUseCase {}
class MockLoadVehiclesUseCase extends Mock implements LoadVehiclesUseCase {}
class MockLoadMaterialsUseCase extends Mock implements LoadMaterialsUseCase {}
class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}
class MockLoadRecentBillsUseCase extends Mock implements LoadRecentBillsUseCase {}
class MockGenerateBillNumberUseCase extends Mock implements GenerateBillNumberUseCase {}

void main() {
  late AuthBloc authBloc;
  late BillBloc billBloc;

  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockIsAuthenticatedUseCase mockIsAuthenticatedUseCase;

  late MockLoadPartiesUseCase mockLoadPartiesUseCase;
  late MockLoadVehiclesUseCase mockLoadVehiclesUseCase;
  late MockLoadMaterialsUseCase mockLoadMaterialsUseCase;
  late MockSaveBillUseCase mockSaveBillUseCase;
  late MockLoadRecentBillsUseCase mockLoadRecentBillsUseCase;
  late MockGenerateBillNumberUseCase mockGenerateBillNumberUseCase;

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

    when(() => mockGetCurrentUserUseCase()).thenAnswer((_) => Future.value(Right(testUser)));
    when(() => mockIsAuthenticatedUseCase()).thenAnswer((_) => Future.value(const Right(true)));

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      isAuthenticatedUseCase: mockIsAuthenticatedUseCase,
    );

    mockLoadPartiesUseCase = MockLoadPartiesUseCase();
    mockLoadVehiclesUseCase = MockLoadVehiclesUseCase();
    mockLoadMaterialsUseCase = MockLoadMaterialsUseCase();
    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();

    when(() => mockLoadPartiesUseCase()).thenAnswer((_) => Future.value(<Party>[]));
    when(() => mockLoadVehiclesUseCase()).thenAnswer((_) => Future.value(<Vehicle>[]));
    when(() => mockLoadMaterialsUseCase()).thenAnswer((_) => Future.value(<domain.Material>[]));
    when(() => mockLoadRecentBillsUseCase()).thenAnswer((_) => Future.value(<Weighment>[]));
    when(() => mockLoadRecentBillsUseCase(limit: any(named: 'limit'))).thenAnswer((_) => Future.value(<Weighment>[]));
    when(() => mockGenerateBillNumberUseCase()).thenAnswer((_) => Future.value('WB-00001'));

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
    authBloc.close();
    billBloc.close();
  });

  Widget createSidebarUnderTest({
    int selectedIndex = 0,
    ValueChanged<int>? onItemSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AppSidebar(
          selectedIndex: selectedIndex,
          onItemSelected: onItemSelected,
        ),
      ),
    );
  }

  Widget createHomePageUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<BillBloc>.value(value: billBloc),
      ],
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }

  group('AppSidebar Widget Tests', () {
    testWidgets('renders brand header with Viyan Weighbridge logo and motto',
        (tester) async {
      await tester.pumpWidget(createSidebarUnderTest());
      await tester.pumpAndSettle();

      // Brand Title
      expect(find.text('Viyan'), findsOneWidget);
      expect(find.text('Weighbridge'), findsOneWidget);

      // Handwritten motto & copyright
      expect(find.text('Weigh Today\nBuild Tomorrow'), findsOneWidget);
      expect(find.text('© 2025 Viyan Weighbridge\nAll rights reserved.'),
          findsOneWidget);
    });

    testWidgets('renders all 8 navigation items', (tester) async {
      await tester.pumpWidget(createSidebarUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Billing'), findsOneWidget);
      expect(find.text('Vehicles'), findsOneWidget);
      expect(find.text('Parties'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Masters'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);
    });

    testWidgets('notifies onItemSelected callback when navigation item is clicked',
        (tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(createSidebarUnderTest(
        selectedIndex: 0,
        onItemSelected: (index) => tappedIndex = index,
      ));
      await tester.pumpAndSettle();

      // Tap on 'Vehicles' (index 1)
      await tester.tap(find.text('Vehicles'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });
  });

  group('HomePage Workstation Layout Tests', () {
    testWidgets('renders top title bar, AppSidebar, and bottom status bar',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createHomePageUnderTest());
      await tester.runAsync(() async {
        await billBloc.stream.firstWhere((s) => s.status == BillScreenStatus.loaded);
      });
      await tester.pumpAndSettle();

      // Top title bar
      expect(find.text('Accurate Weighing. Smarter Operations.'), findsOneWidget);
      expect(find.text('Admin'), findsWidgets);

      // Sidebar items
      expect(find.text('Billing'), findsWidgets);
      expect(find.text('Vehicles'), findsOneWidget);

      // Bottom status bar
      expect(find.text('Weighbridge Connected'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Database: Local'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('switching sidebar tabs changes main view and allows return',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createHomePageUnderTest());
      await tester.runAsync(() async {
        await billBloc.stream.firstWhere((s) => s.status == BillScreenStatus.loaded);
      });
      await tester.pumpAndSettle();

      // Tap on Reports in sidebar
      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();

      expect(find.text('Reports Module'), findsOneWidget);
      expect(find.text('Return to Billing Terminal'), findsOneWidget);

      // Tap return
      await tester.tap(find.text('Return to Billing Terminal'));
      await tester.pumpAndSettle();

      expect(find.text('Save Ticket'), findsOneWidget);
    });

    testWidgets('opens logout confirmation dialog when clicking logout icon',
        (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createHomePageUnderTest());
      await tester.runAsync(() async {
        await billBloc.stream.firstWhere((s) => s.status == BillScreenStatus.loaded);
      });
      await tester.pumpAndSettle();

      // Tap logout icon
      await tester.tap(find.byTooltip('Logout session'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Logout'), findsOneWidget);
      expect(find.text('Are you sure you want to end your current weighbridge terminal session?'), findsOneWidget);
    });
  });
}
