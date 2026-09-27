import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/di/injection.dart';
import 'core/database/app_database.dart';
import 'core/hardware/scale/domain/scale_service.dart';
import 'core/licensing/license_gate.dart';
import 'core/security/admin_password_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final injection = await Injection.init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>.value(value: injection.database),
        RepositoryProvider<AdminPasswordService>.value(
          value: injection.adminPasswordService,
        ),
        RepositoryProvider.value(value: injection.billRepository),
        RepositoryProvider.value(value: injection.customerRepository),
        RepositoryProvider.value(value: injection.materialRepository),
        RepositoryProvider<ScaleService>.value(value: injection.scaleService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: injection.authBloc),
          BlocProvider.value(value: injection.billBloc),
          BlocProvider.value(value: injection.customerBloc),
          BlocProvider.value(value: injection.materialBloc),
          BlocProvider.value(value: injection.settingsBloc),
          BlocProvider.value(value: injection.reportBloc),
        ],
        child: MaterialApp(
          title: 'Viyan Weighbridge',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          home: LicenseGate(
            injection: injection,
            licenseService: injection.licenseService,
          ),
        ),
      ),
    ),
  );
}
