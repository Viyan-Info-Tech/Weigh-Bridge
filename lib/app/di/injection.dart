import '../../core/licensing/license_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
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
import '../../features/customer/data/datasources/customer_local_datasource.dart';
import '../../features/customer/data/repositories/customer_repository_impl.dart';
import '../../features/customer/domain/usecases/load_customers.dart';
import '../../features/customer/domain/usecases/create_customer.dart';
import '../../features/customer/domain/usecases/update_customer.dart';
import '../../features/customer/domain/usecases/deactivate_customer.dart';
import '../../features/customer/domain/usecases/delete_customer.dart';
import '../../features/customer/domain/usecases/search_customers.dart';
import '../../features/customer/presentation/bloc/customer_bloc.dart';
import '../../features/customer/domain/repositories/customer_repository.dart';
import '../../features/material/data/datasources/material_item_local_datasource.dart';
import '../../features/material/data/repositories/material_item_repository_impl.dart';
import '../../features/material/domain/usecases/load_materials.dart';
import '../../features/material/domain/usecases/create_material.dart';
import '../../features/material/domain/usecases/delete_material.dart';
import '../../features/material/presentation/bloc/material_bloc.dart';
import '../../features/material/domain/repositories/material_item_repository.dart';
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

class Injection {
  final AppDatabase database;
  final AuthBloc authBloc;
  final BillBloc billBloc;
  final CustomerBloc customerBloc;
  final MaterialBloc materialBloc;
  final SettingsBloc settingsBloc;
  final ReportBloc reportBloc;
  final LicenseService licenseService;
  final BillRepository billRepository;
  final CustomerRepository customerRepository;
  final MaterialItemRepository materialRepository;
  final AdminPasswordService adminPasswordService;

  Injection({
    required this.database,
    required this.authBloc,
    required this.billBloc,
    required this.customerBloc,
    required this.materialBloc,
    required this.settingsBloc,
    required this.reportBloc,
    required this.licenseService,
    required this.billRepository,
    required this.customerRepository,
    required this.materialRepository,
    required this.adminPasswordService,
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

    // Customer
    final CustomerLocalDataSource customerLocalDataSource =
        CustomerLocalDataSource(database);
    final customerRepository = CustomerRepositoryImpl(customerLocalDataSource);

    final loadCustomersUseCase = LoadCustomersUseCase(customerRepository);
    final createCustomerUseCase = CreateCustomerUseCase(customerRepository);
    final updateCustomerUseCase = UpdateCustomerUseCase(customerRepository);
    final deactivateCustomerUseCase = DeactivateCustomerUseCase(
      customerRepository,
    );
    final deleteCustomerUseCase = DeleteCustomerUseCase(customerRepository);
    final searchCustomersUseCase = SearchCustomersUseCase(customerRepository);

    final customerBloc = CustomerBloc(
      loadCustomersUseCase: loadCustomersUseCase,
      createCustomerUseCase: createCustomerUseCase,
      updateCustomerUseCase: updateCustomerUseCase,
      deactivateCustomerUseCase: deactivateCustomerUseCase,
      deleteCustomerUseCase: deleteCustomerUseCase,
      searchCustomersUseCase: searchCustomersUseCase,
      customerRepository: customerRepository,
    );

    // Material
    final materialItemLocalDataSource = MaterialItemLocalDataSource(database);
    final materialItemRepository = MaterialItemRepositoryImpl(
      localDataSource: materialItemLocalDataSource,
    );

    final loadMaterialsUseCase = LoadMaterialsUseCase(materialItemRepository);
    final createMaterialUseCase = CreateMaterialUseCase(materialItemRepository);
    final deleteMaterialUseCase = DeleteMaterialUseCase(materialItemRepository);

    final materialBloc = MaterialBloc(
      loadMaterialsUseCase: loadMaterialsUseCase,
      createMaterialUseCase: createMaterialUseCase,
      deleteMaterialUseCase: deleteMaterialUseCase,
      materialRepository: materialItemRepository,
    );

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

    // Bill
    final billLocalDataSource = BillLocalDataSource(database);
    final billRepository = BillRepositoryImpl(
      localDataSource: billLocalDataSource,
    );

    final saveBillUseCase = SaveBillUseCase(billRepository);
    final loadRecentBillsUseCase = LoadRecentBillsUseCase(billRepository);
    final generateBillNumberUseCase = GenerateBillNumberUseCase(billRepository);

    final billBloc = BillBloc(
      customerRepository: customerRepository,
      materialRepository: materialItemRepository,
      saveBillUseCase: saveBillUseCase,
      loadRecentBillsUseCase: loadRecentBillsUseCase,
      generateBillNumberUseCase: generateBillNumberUseCase,
      settingsRepository: settingsRepository,
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
      customerRepository: customerRepository,
      materialRepository: materialItemRepository,
      exportReportUseCase: exportReportUseCase,
      settingsRepository: settingsRepository,
    );

    // License
    final licenseService = LicenseServiceImpl();

    await _seedInitialData(authLocalDataSource, passwordHasher);

    return Injection(
      database: database,
      authBloc: authBloc,
      billBloc: billBloc,
      customerBloc: customerBloc,
      materialBloc: materialBloc,
      settingsBloc: settingsBloc,
      reportBloc: reportBloc,
      licenseService: licenseService,
      billRepository: billRepository,
      customerRepository: customerRepository,
      materialRepository: materialItemRepository,
      adminPasswordService: adminPasswordService,
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
