import 'package:flutter/material.dart';

import 'app/di/injection.dart';
import 'core/licensing/license_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final injection = await Injection.init();

  runApp(
    MaterialApp(
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
  );
}
