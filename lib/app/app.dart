import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/injection.dart';
import 'router/app_router.dart';

class WeighbridgeApp extends StatefulWidget {
  final Injection injection;

  const WeighbridgeApp({super.key, required this.injection});

  @override
  State<WeighbridgeApp> createState() => _WeighbridgeAppState();
}

class _WeighbridgeAppState extends State<WeighbridgeApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(widget.injection.authBloc);
  }

  @override
  void dispose() {
    _appRouter.router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.injection.authBloc),
        BlocProvider.value(value: widget.injection.billBloc),
      ],
      child: MaterialApp.router(
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
        routerConfig: _appRouter.router,
      ),
    );
  }
}
