import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/home_page.dart';

import '../../features/weighing/presentation/pages/serial_weight_test_page.dart';

class AppRouter {
  final AuthBloc authBloc;
  final String initialLocation;

  AppRouter(this.authBloc, {this.initialLocation = '/bill'});

  late final GoRouter router = GoRouter(
    initialLocation: initialLocation,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      if (state.matchedLocation == '/test-scale') {
        return null;
      }

      final authState = authBloc.state;
      final isOnLogin = state.matchedLocation == '/login';

      if (authState.status == AuthStatus.authenticated) {
        return isOnLogin ? '/bill' : null;
      }

      // Weighment opens directly without an operator login. The master pages
      // apply their own administrator password gate from the navigation bar.
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/bill', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/test-scale',
        builder: (context, state) => const SerialWeightTestPage(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
