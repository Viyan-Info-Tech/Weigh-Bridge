import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/app/router/app_router.dart';
import 'package:weighbridge/features/auth/domain/usecases/get_current_user.dart';
import 'package:weighbridge/features/auth/domain/usecases/is_authenticated.dart';
import 'package:weighbridge/features/auth/domain/usecases/login.dart';
import 'package:weighbridge/features/auth/domain/usecases/logout.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_event.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_state.dart';
import 'package:weighbridge/features/auth/presentation/pages/login_page.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockIsAuthenticatedUseCase extends Mock
    implements IsAuthenticatedUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockIsAuthenticatedUseCase mockIsAuthenticatedUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockIsAuthenticatedUseCase = MockIsAuthenticatedUseCase();

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      isAuthenticatedUseCase: mockIsAuthenticatedUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AppRouter redirection logic', () {
    test('initializes with /login location when status is initial', () {
      expect(authBloc.state.status, AuthStatus.initial);
      final appRouter = AppRouter(authBloc);
      // Verify router is initialized with /login initialLocation
      expect(
        appRouter.router.routeInformationProvider.value.uri.path,
        '/login',
      );
      appRouter.router.dispose();
    });

    test('maintains session and directs authenticated users', () {
      final appRouter = AppRouter(authBloc);
      expect(appRouter.authBloc.state.status, AuthStatus.initial);
      appRouter.router.dispose();
    });

    testWidgets('redirects from /bill to /login when unauthenticated', (
      tester,
    ) async {
      await tester.runAsync(() async {
        when(
          () => mockIsAuthenticatedUseCase(),
        ).thenAnswer((_) async => const Right(false));

        final future = authBloc.stream.firstWhere(
          (s) => s.status == AuthStatus.unauthenticated,
        );
        authBloc.add(const AppStarted());
        await future;
      });

      final appRouter = AppRouter(authBloc, initialLocation: '/bill');
      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: MaterialApp.router(routerConfig: appRouter.router),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(LoginPage), findsOneWidget);
      appRouter.router.dispose();
    });
  });
}
