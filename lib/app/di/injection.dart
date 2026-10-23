import 'dart:async';

import '../../core/licensing/license_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/scale_settings_dao.dart';
import '../../core/hardware/scale/data/fake_scale_service.dart';
import '../../core/hardware/scale/data/flutter_libserialport_transport.dart';
import '../../core/hardware/scale/data/scale_config_adapter.dart';
import '../../core/hardware/scale/data/scale_service_impl.dart';
import '../../core/hardware/scale/domain/scale_service.dart';
import '../../core/security/password_hasher.dart';
import '../../core/security/session_manager.dart';
import '../../core/security/admin_password_service.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/is_authenticated.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/bill/data/datasources/bill_local_datasource.dart';
import '../../features/bill/data/repositories/bill_repository_impl.dart';
import '../../features/bill/domain/usecases/save_bill.dart';
import '../../features/bill/presentation/bloc/bill_bloc.dart';
import '../../features/bill/domain/repositories/bill_repository.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/update_settings.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/bloc/settings_event.dart';
import '../../features/report/data/datasources/report_local_datasource.dart';
import '../../features/report/data/repositories/report_repository_impl.dart';
import '../../features/report/data/services/file_picker_save_service.dart';
import '../../features/report/domain/services/csv_generator.dart';
import '../../features/report/domain/usecases/export_report_usecase.dart';
import '../../features/report/presentation/bloc/report_bloc.dart';
import '../../features/material/data/datasources/material_local_datasource.dart';
import '../../features/material/data/repositories/material_repository_impl.dart';
import '../../features/material/domain/repositories/material_repository.dart';
import '../../features/material/domain/usecases/create_material.dart';
import '../../features/material/domain/usecases/delete_material.dart';
import '../../features/material/domain/usecases/load_materials.dart';
import '../../features/material/domain/usecases/update_material.dart';
import '../../features/material/presentation/bloc/material_bloc.dart';
import '../../features/material/presentation/bloc/material_event.dart';

class Injection {
  final AppDatabase database;
  final AuthBloc authBloc;
  final BillBloc billBloc;
  final SettingsBloc settingsBloc;
  final ReportBloc reportBloc;
  final MaterialBloc materialBloc;
  final LicenseService licenseService;
  final BillRepository billRepository;
  final MaterialRepository materialRepository;
  final AdminPasswordService adminPasswordService;
  final ScaleService scaleService;

  Injection({
    required this.database,
    required this.authBloc,
    required this.billBloc,
    required this.settingsBloc,
    required this.reportBloc,
    required this.materialBloc,
    required this.licenseService,
    required this.billRepository,
    required this.materialRepository,
    required this.adminPasswordService,
    required this.scaleService,
  });

  static Future<Injection> init() async {
    final database = AppDatabase();
    final prefs = await SharedPreferences.getInstance();

    // Auth
    final passwordHasher = PasswordHasher();
    final adminPasswordService = AdminPasswordService(
      database: database,
      passwordHasher: passwordHasher,
    );
    await adminPasswordService.initialize();
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
    authBloc.add(const AppStarted());

    // Settings
    final settingsLocalDataSource = SettingsLocalDataSource(database);
    final settingsRepository = SettingsRepositoryImpl(
      localDataSource: settingsLocalDataSource,
    );
    final getSettingsUseCase = GetSettingsUseCase(settingsRepository);
    final updateSettingsUseCase = UpdateSettingsUseCase(settingsRepository);

    final settingsBloc = SettingsBloc(
      getSettingsUseCase: getSettingsUseCase,
      updateSettingsUseCase: updateSettingsUseCase,
    );
    settingsBloc.add(const LoadSettings());

    // Bill + Materials (the bill form's material dropdown reads the master)
    final billLocalDataSource = BillLocalDataSource(database);
    final billRepository = BillRepositoryImpl(
      localDataSource: billLocalDataSource,
    );

    final materialLocalDataSource = MaterialLocalDataSource(database);
    final materialRepository = MaterialRepositoryImpl(
      localDataSource: materialLocalDataSource,
    );
    final loadMaterialsUseCase = LoadMaterials(materialRepository);
    final createMaterialUseCase = CreateMaterial(materialRepository);
    final updateMaterialUseCase = UpdateMaterial(materialRepository);
    final deleteMaterialUseCase = DeleteMaterial(materialRepository);

    final materialBloc = MaterialBloc(
      loadMaterials: loadMaterialsUseCase,
      createMaterial: createMaterialUseCase,
      updateMaterial: updateMaterialUseCase,
      deleteMaterial: deleteMaterialUseCase,
    )..add(const LoadMaterialsEvent());

    final saveBillUseCase = SaveBillUseCase(billRepository);
    final loadRecentBillsUseCase = LoadRecentBillsUseCase(billRepository);
    final generateBillNumberUseCase = GenerateBillNumberUseCase(billRepository);
    final getPreviousWeighmentUseCase = GetPreviousWeighmentUseCase(
      billRepository,
    );

    final billBloc = BillBloc(
      saveBillUseCase: saveBillUseCase,
      loadRecentBillsUseCase: loadRecentBillsUseCase,
      generateBillNumberUseCase: generateBillNumberUseCase,
      previousWeighmentUseCase: getPreviousWeighmentUseCase,
      settingsRepository: settingsRepository,
      materialRepository: materialRepository,
    );

    // Report
    final reportLocalDataSource = ReportLocalDataSource(database);
    final reportRepository = ReportRepositoryImpl(reportLocalDataSource);
    final fileSaveService = FilePickerSaveService();
    const csvGenerator = CsvGenerator();
    final exportReportUseCase = ExportReportUseCase(
      reportRepository: reportRepository,
      fileSaveService: fileSaveService,
      csvGenerator: csvGenerator,
    );
    final reportBloc = ReportBloc(
      reportRepository: reportRepository,
      exportReportUseCase: exportReportUseCase,
      settingsRepository: settingsRepository,
    );

    // License
    final licenseService = LicenseServiceImpl();

    // Weigh scale
    final scaleSettingsDao = ScaleSettingsDao(database);
    final scaleSettings = await scaleSettingsDao.getSettings();
    final scaleConfig = ScaleConfigAdapter.fromRow(scaleSettings);

    // Build with: flutter run --dart-define=USE_FAKE_SCALE=true
    const useFakeScale = bool.fromEnvironment('USE_FAKE_SCALE');
    final ScaleService scaleService;
    if (useFakeScale) {
      scaleService = FakeScaleService(config: scaleConfig);
      unawaited(scaleService.start());
    } else {
      scaleService = ScaleServiceImpl(
        transportFactory: FlutterLibSerialPortTransport.new,
        config: scaleConfig,
      );
      if (scaleConfig.enabled) {
        unawaited(scaleService.start());
      }
    }

    await _seedInitialData(authLocalDataSource, passwordHasher);

    return Injection(
      database: database,
      authBloc: authBloc,
      billBloc: billBloc,
      settingsBloc: settingsBloc,
      reportBloc: reportBloc,
      materialBloc: materialBloc,
      licenseService: licenseService,
      billRepository: billRepository,
      materialRepository: materialRepository,
      adminPasswordService: adminPasswordService,
      scaleService: scaleService,
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
