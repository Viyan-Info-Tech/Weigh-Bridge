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
import '../../features/bill/data/datasources/bill_local_datasource.dart';
import '../../features/bill/data/repositories/bill_repository_impl.dart';
import '../../features/bill/domain/usecases/save_bill.dart';
import '../../features/bill/presentation/bloc/bill_bloc.dart';
import '../../features/party/data/datasources/party_local_datasource.dart';
import '../../features/party/data/repositories/party_repository_impl.dart';
import '../../features/party/domain/usecases/load_parties.dart';
import '../../features/party/domain/usecases/create_party.dart';
import '../../features/party/domain/usecases/update_party.dart';
import '../../features/party/domain/usecases/deactivate_party.dart';
import '../../features/party/domain/usecases/delete_party.dart';
import '../../features/party/domain/usecases/search_parties.dart';
import '../../features/party/presentation/bloc/party_bloc.dart';
import '../../features/vehicle/data/datasources/vehicle_local_datasource.dart';
import '../../features/vehicle/data/repositories/vehicle_repository_impl.dart';
import '../../features/vehicle/domain/usecases/load_vehicles.dart';
import '../../features/vehicle/domain/usecases/create_vehicle.dart';
import '../../features/vehicle/domain/usecases/delete_vehicle.dart';
import '../../features/vehicle/presentation/bloc/vehicle_bloc.dart';
import '../../features/vehicle_type/data/datasources/vehicle_type_local_datasource.dart';
import '../../features/vehicle_type/data/repositories/vehicle_type_repository_impl.dart';
import '../../features/vehicle_type/domain/usecases/load_vehicle_types.dart';
import '../../features/vehicle_type/domain/usecases/create_vehicle_type.dart';
import '../../features/vehicle_type/domain/usecases/delete_vehicle_type.dart';
import '../../features/vehicle_type/presentation/bloc/vehicle_type_bloc.dart';
import '../../features/material/data/datasources/material_item_local_datasource.dart';
import '../../features/material/data/repositories/material_item_repository_impl.dart';
import '../../features/material/domain/usecases/load_materials.dart';
import '../../features/material/domain/usecases/create_material.dart';
import '../../features/material/presentation/bloc/material_bloc.dart';

class Injection {
  final AppDatabase database;
  final AuthBloc authBloc;
  final BillBloc billBloc;
  final PartyBloc partyBloc;
  final VehicleBloc vehicleBloc;
  final VehicleTypeBloc vehicleTypeBloc;
  final MaterialBloc materialBloc;

  Injection._({
    required this.database,
    required this.authBloc,
    required this.billBloc,
    required this.partyBloc,
    required this.vehicleBloc,
    required this.vehicleTypeBloc,
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

    // Party
    final partyLocalDataSource = PartyLocalDataSource(database);
    final partyRepository = PartyRepositoryImpl(partyLocalDataSource);

    final loadPartiesUseCase = LoadPartiesUseCase(partyRepository);
    final createPartyUseCase = CreatePartyUseCase(partyRepository);
    final updatePartyUseCase = UpdatePartyUseCase(partyRepository);
    final deactivatePartyUseCase = DeactivatePartyUseCase(partyRepository);
    final deletePartyUseCase = DeletePartyUseCase(partyRepository);
    final searchPartiesUseCase = SearchPartiesUseCase(partyRepository);

    final partyBloc = PartyBloc(
      loadPartiesUseCase: loadPartiesUseCase,
      createPartyUseCase: createPartyUseCase,
      updatePartyUseCase: updatePartyUseCase,
      deactivatePartyUseCase: deactivatePartyUseCase,
      deletePartyUseCase: deletePartyUseCase,
      searchPartiesUseCase: searchPartiesUseCase,
      partyRepository: partyRepository,
    );

    // Vehicle Type
    final vehicleTypeLocalDataSource = VehicleTypeLocalDataSource(database);
    final vehicleTypeRepository = VehicleTypeRepositoryImpl(
      localDataSource: vehicleTypeLocalDataSource,
    );

    final loadVehicleTypesUseCase = LoadVehicleTypesUseCase(vehicleTypeRepository);
    final createVehicleTypeUseCase = CreateVehicleTypeUseCase(vehicleTypeRepository);
    final deleteVehicleTypeUseCase = DeleteVehicleTypeUseCase(vehicleTypeRepository);

    final vehicleTypeBloc = VehicleTypeBloc(
      loadVehicleTypesUseCase: loadVehicleTypesUseCase,
      createVehicleTypeUseCase: createVehicleTypeUseCase,
      deleteVehicleTypeUseCase: deleteVehicleTypeUseCase,
      vehicleTypeRepository: vehicleTypeRepository,
    );

    // Vehicle
    final vehicleLocalDataSource = VehicleLocalDataSource(database);
    final vehicleRepository = VehicleRepositoryImpl(
      localDataSource: vehicleLocalDataSource,
    );

    final loadVehiclesUseCase = LoadVehiclesUseCase(vehicleRepository);
    final createVehicleUseCase = CreateVehicleUseCase(vehicleRepository);
    final deleteVehicleUseCase = DeleteVehicleUseCase(vehicleRepository);

    final vehicleBloc = VehicleBloc(
      loadVehiclesUseCase: loadVehiclesUseCase,
      createVehicleUseCase: createVehicleUseCase,
      deleteVehicleUseCase: deleteVehicleUseCase,
      vehicleRepository: vehicleRepository,
    );

    // Material
    final materialItemLocalDataSource = MaterialItemLocalDataSource(database);
    final materialItemRepository = MaterialItemRepositoryImpl(
      localDataSource: materialItemLocalDataSource,
    );

    final loadMaterialsUseCase = LoadMaterialsUseCase(materialItemRepository);
    final createMaterialUseCase = CreateMaterialUseCase(materialItemRepository);

    final materialBloc = MaterialBloc(
      loadMaterialsUseCase: loadMaterialsUseCase,
      createMaterialUseCase: createMaterialUseCase,
      materialRepository: materialItemRepository,
    );

    // Bill
    final billLocalDataSource = BillLocalDataSource(database);
    final billRepository = BillRepositoryImpl(
      localDataSource: billLocalDataSource,
    );

    final saveBillUseCase = SaveBillUseCase(billRepository);
    final loadRecentBillsUseCase = LoadRecentBillsUseCase(billRepository);
    final loadPendingBillsUseCase = LoadPendingBillsUseCase(billRepository);
    final generateBillNumberUseCase = GenerateBillNumberUseCase(billRepository);

    final billBloc = BillBloc(
      partyRepository: partyRepository,
      vehicleRepository: vehicleRepository,
      vehicleTypeRepository: vehicleTypeRepository,
      materialRepository: materialItemRepository,
      saveBillUseCase: saveBillUseCase,
      loadRecentBillsUseCase: loadRecentBillsUseCase,
      loadPendingBillsUseCase: loadPendingBillsUseCase,
      generateBillNumberUseCase: generateBillNumberUseCase,
    );

    await _seedInitialData(authLocalDataSource, passwordHasher);

    return Injection._(
      database: database,
      authBloc: authBloc,
      billBloc: billBloc,
      partyBloc: partyBloc,
      vehicleBloc: vehicleBloc,
      vehicleTypeBloc: vehicleTypeBloc,
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
