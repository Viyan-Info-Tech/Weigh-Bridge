import 'package:flutter/material.dart';

import 'app/di/injection.dart';
import 'core/licensing/license_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final injection = await Injection.init();

  runApp(
    LicenseGate(
      injection: injection,
      licenseService: injection.licenseService,
    ),
  );
}
