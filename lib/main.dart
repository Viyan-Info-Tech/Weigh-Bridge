import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final injection = await Injection.init();

  injection.authBloc.add(const AppStarted());

  runApp(WeighbridgeApp(injection: injection));
}
