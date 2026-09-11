import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
import '../../core/security/password_hasher.dart';
import '../../core/security/session_manager.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/is_authenticated.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/bill/data/datasources/party_local_datasource.dart';
import '../../features/bill/data/datasources/vehicle_local_datasource.dart';
import '../../features/bill/data/datasources/material_local_datasource.dart';
import '../../features/bill/data/datasources/bill_local_datasource.dart';
import '../../features/bill/data/repositories/party_repository_impl.dart';
import '../../features/bill/data/repositories/vehicle_repository_impl.dart';
import '../../features/bill/data/repositories/material_repository_impl.dart';
import '../../features/bill/data/repositories/bill_repository_impl.dart';
import '../../features/bill/domain/usecases/load_parties.dart';
import '../../features/bill/domain/usecases/load_vehicles.dart';
import '../../features/bill/domain/usecases/load_materials.dart';
import '../../features/bill/domain/usecases/save_bill.dart';
import '../../features/bill/presentation/bloc/bill_bloc.dart';
import '../../features/party/data/datasources/party_local_datasource.dart'
    as party_ds;
import '../../features/party/data/repositories/party_repository_impl.dart'
    as party_repo;
import '../../features/party/domain/usecases/load_parties.dart' as party_uc;
import '../../features/party/domain/usecases/create_party.dart';
import '../../features/party/domain/usecases/update_party.dart';
import '../../features/party/domain/usecases/deactivate_party.dart';
import '../../features/party/domain/usecases/search_parties.dart';
import '../../features/party/presentation/bloc/party_bloc.dart';
import '../../features/vehicle/data/datasources/vehicle_local_datasource.dart'
    as vehicle_ds;
import '../../features/vehicle/data/repositories/vehicle_repository_impl.dart'
    as vehicle_repo;
import '../../features/vehicle/domain/usecases/load_vehicles.dart'
    as vehicle_uc;
import '../../features/vehicle/domain/usecases/create_vehicle.dart';
import '../../features/vehicle/presentation/bloc/vehicle_bloc.dart';
import '../../features/material/data/datasources/material_item_local_datasource.dart';
import '../../features/material/data/repositories/material_item_repository_impl.dart';
import '../../features/material/domain/usecases/load_materials.dart'
    as material_uc;
import '../../features/material/domain/usecases/create_material.dart';
import '../../features/material/presentation/bloc/material_bloc.dart';

class Injection {
  final AppDatabase database;
  final AuthBloc authBloc;
  final BillBloc billBloc;
  final PartyBloc partyBloc;
  final VehicleBloc vehicleBloc;
  final MaterialBloc materialBloc;

  Injection._({
    required this.database,
    required this.authBloc,
    required this.billBloc,
    required this.partyBloc,
    required this.vehicleBloc,
    required this.materialBloc,
  });

  static Future<Injection> init() async {
    final database = AppDatabase();
    final prefs = await SharedPreferences.getInstance();

    // Auth
    final passwordHasher = PasswordHasher();
    final sessionManager = SessionManager(prefs);
    final authLocalDataSource = AuthLocalDataSource(database);

    final authRepository = AuthRepositoryImpl(
      localDataSource: authLocalDataSource,
      passwordHasher: passwordHasher,
      sessionManager: sessionManager,
    );

    final loginUseCase = LoginUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
    final isAuthenticatedUseCase = IsAuthenticatedUseCase(authRepository);

    final authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      isAuthenticatedUseCase: isAuthenticatedUseCase,
    );

    // Bill
    final partyLocalDataSource = PartyLocalDataSource(database);
    final vehicleLocalDataSource = VehicleLocalDataSource(database);
    final materialLocalDataSource = MaterialLocalDataSource(database);
    final billLocalDataSource = BillLocalDataSource(database);

    final partyRepository = PartyRepositoryImpl(
      localDataSource: partyLocalDataSource,
    );
    final vehicleRepository = VehicleRepositoryImpl(
      localDataSource: vehicleLocalDataSource,
    );
    final materialRepository = MaterialRepositoryImpl(
      localDataSource: materialLocalDataSource,
    );
    final billRepository = BillRepositoryImpl(
      localDataSource: billLocalDataSource,
    );

    final loadPartiesUseCase = LoadPartiesUseCase(partyRepository);
    final loadVehiclesUseCase = LoadVehiclesUseCase(vehicleRepository);
    final loadMaterialsUseCase = LoadMaterialsUseCase(materialRepository);
    final saveBillUseCase = SaveBillUseCase(billRepository);
    final loadRecentBillsUseCase = LoadRecentBillsUseCase(billRepository);
    final generateBillNumberUseCase = GenerateBillNumberUseCase(billRepository);

    final billBloc = BillBloc(
      loadPartiesUseCase: loadPartiesUseCase,
      loadVehiclesUseCase: loadVehiclesUseCase,
      loadMaterialsUseCase: loadMaterialsUseCase,
      saveBillUseCase: saveBillUseCase,
      loadRecentBillsUseCase: loadRecentBillsUseCase,
      generateBillNumberUseCase: generateBillNumberUseCase,
    );

    // Party
    final partyLocalDataSourceNew = party_ds.PartyLocalDataSource(database);
    final partyRepositoryNew = party_repo.PartyRepositoryImpl(
      partyLocalDataSourceNew,
    );

    final loadPartiesUseCaseNew = party_uc.LoadPartiesUseCase(
      partyRepositoryNew,
    );
    final createPartyUseCase = CreatePartyUseCase(partyRepositoryNew);
    final updatePartyUseCase = UpdatePartyUseCase(partyRepositoryNew);
    final deactivatePartyUseCase = DeactivatePartyUseCase(partyRepositoryNew);
    final searchPartiesUseCase = SearchPartiesUseCase(partyRepositoryNew);

    final partyBloc = PartyBloc(
      loadPartiesUseCase: loadPartiesUseCaseNew,
      createPartyUseCase: createPartyUseCase,
      updatePartyUseCase: updatePartyUseCase,
      deactivatePartyUseCase: deactivatePartyUseCase,
      searchPartiesUseCase: searchPartiesUseCase,
      partyRepository: partyRepositoryNew,
    );

    // Vehicle
    final vehicleLocalDataSourceNew = vehicle_ds.VehicleLocalDataSource(
      database,
    );
    final vehicleRepositoryNew = vehicle_repo.VehicleRepositoryImpl(
      localDataSource: vehicleLocalDataSourceNew,
    );

    final loadVehiclesUseCaseNew = vehicle_uc.LoadVehiclesUseCase(
      vehicleRepositoryNew,
    );
    final createVehicleUseCase = CreateVehicleUseCase(vehicleRepositoryNew);

    final vehicleBloc = VehicleBloc(
      loadVehiclesUseCase: loadVehiclesUseCaseNew,
      createVehicleUseCase: createVehicleUseCase,
      vehicleRepository: vehicleRepositoryNew,
    );

    // Material
    final materialItemLocalDataSource = MaterialItemLocalDataSource(database);
    final materialItemRepository = MaterialItemRepositoryImpl(
      localDataSource: materialItemLocalDataSource,
    );

    final loadMaterialsUseCaseNew = material_uc.LoadMaterialsUseCase(
      materialItemRepository,
    );
    final createMaterialUseCase = CreateMaterialUseCase(materialItemRepository);

    final materialBloc = MaterialBloc(
      loadMaterialsUseCase: loadMaterialsUseCaseNew,
      createMaterialUseCase: createMaterialUseCase,
      materialRepository: materialItemRepository,
    );

    await _seedInitialData(authLocalDataSource, passwordHasher);

    return Injection._(
      database: database,
      authBloc: authBloc,
      billBloc: billBloc,
      partyBloc: partyBloc,
      vehicleBloc: vehicleBloc,
      materialBloc: materialBloc,
    );
  }

  static Future<void> _seedInitialData(
    AuthLocalDataSource dataSource,
    PasswordHasher passwordHasher,
  ) async {
    final userCount = await dataSource.getUserCount();
    if (userCount == 0) {
      final hash = passwordHasher.hashPassword('Admin@123');
      await dataSource.seedAdminUser(hash);
    }
  }
}
