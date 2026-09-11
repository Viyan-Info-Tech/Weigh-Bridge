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
import 'package:weighbridge/features/party/domain/entities/party.dart';
import 'package:weighbridge/features/party/domain/repositories/party_repository.dart';
import 'package:weighbridge/features/vehicle/domain/entities/vehicle.dart';
import 'package:weighbridge/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:weighbridge/features/vehicle_type/domain/repositories/vehicle_type_repository.dart';
import 'package:weighbridge/features/material/domain/entities/material_item.dart';
import 'package:weighbridge/features/material/domain/repositories/material_item_repository.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/dashboard/presentation/pages/home_page.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockIsAuthenticatedUseCase extends Mock implements IsAuthenticatedUseCase {}

class MockPartyRepository extends Mock implements PartyRepository {}
class MockVehicleRepository extends Mock implements VehicleRepository {}
class MockVehicleTypeRepository extends Mock implements VehicleTypeRepository {}
class MockMaterialRepository extends Mock implements MaterialItemRepository {}
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

  late MockPartyRepository mockPartyRepository;
  late MockVehicleRepository mockVehicleRepository;
  late MockVehicleTypeRepository mockVehicleTypeRepository;
  late MockMaterialRepository mockMaterialRepository;
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

    mockPartyRepository = MockPartyRepository();
    mockVehicleRepository = MockVehicleRepository();
    mockVehicleTypeRepository = MockVehicleTypeRepository();
    mockMaterialRepository = MockMaterialRepository();
    mockSaveBillUseCase = MockSaveBillUseCase();
    mockLoadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    mockGenerateBillNumberUseCase = MockGenerateBillNumberUseCase();

    when(() => mockPartyRepository.getAllActiveParties())
        .thenAnswer((_) => Future.value(<Party>[]));
    when(() => mockVehicleRepository.getVehiclesByStatus(isActive: true))
        .thenAnswer((_) => Future.value(<Vehicle>[]));
    when(() => mockVehicleTypeRepository.getVehicleTypesByStatus(isActive: true))
        .thenAnswer((_) => Future.value([]));
    when(() => mockMaterialRepository.getMaterialsByStatus(isActive: true))
        .thenAnswer((_) => Future.value(<MaterialItem>[]));
    when(() => mockLoadRecentBillsUseCase())
        .thenAnswer((_) => Future.value(<Weighment>[]));
    when(() => mockLoadRecentBillsUseCase(limit: any(named: 'limit')))
        .thenAnswer((_) => Future.value(<Weighment>[]));
    when(() => mockGenerateBillNumberUseCase())
        .thenAnswer((_) => Future.value('WB-00001'));

    billBloc = BillBloc(
      partyRepository: mockPartyRepository,
      vehicleRepository: mockVehicleRepository,
      vehicleTypeRepository: mockVehicleTypeRepository,
      materialRepository: mockMaterialRepository,
      saveBillUseCase: mockSaveBillUseCase,
      loadRecentBillsUseCase: mockLoadRecentBillsUseCase,
      generateBillNumberUseCase: mockGenerateBillNumberUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
    billBloc.close();
  });

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

  group('HomePage Workstation Layout Tests', () {
    testWidgets('renders top title bar and content',
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
      expect(find.text('Admin'), findsWidgets);

      // Sidebar items
      expect(find.text('Bill'), findsWidgets);
    });
  });
}
