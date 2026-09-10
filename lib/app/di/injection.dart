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

class Injection {
  final AppDatabase database;
  final AuthBloc authBloc;
  final BillBloc billBloc;

  Injection._({
    required this.database,
    required this.authBloc,
    required this.billBloc,
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

    final partyRepository = PartyRepositoryImpl(localDataSource: partyLocalDataSource);
    final vehicleRepository = VehicleRepositoryImpl(localDataSource: vehicleLocalDataSource);
    final materialRepository = MaterialRepositoryImpl(localDataSource: materialLocalDataSource);
    final billRepository = BillRepositoryImpl(localDataSource: billLocalDataSource);

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

    await _seedInitialData(authLocalDataSource, passwordHasher);

    return Injection._(
      database: database,
      authBloc: authBloc,
      billBloc: billBloc,
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
