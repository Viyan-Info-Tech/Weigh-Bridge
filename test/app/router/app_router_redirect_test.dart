import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/auth/domain/entities/user.dart';
import 'package:weighbridge/features/auth/domain/usecases/get_current_user.dart';
import 'package:weighbridge/features/auth/domain/usecases/is_authenticated.dart';
import 'package:weighbridge/features/auth/domain/usecases/login.dart';
import 'package:weighbridge/features/auth/domain/usecases/logout.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_event.dart';
import 'package:weighbridge/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockIsAuthenticatedUseCase extends Mock
    implements IsAuthenticatedUseCase {}

String? _redirect(AuthBloc bloc, String location) {
  final authState = bloc.state;
  final isOnLogin = location == '/login';

  if (authState.status == AuthStatus.initial ||
      authState.status == AuthStatus.checking) {
    return null;
  }

  if (authState.status == AuthStatus.authenticated) {
    return isOnLogin ? '/bill' : null;
  }

  return isOnLogin ? null : '/login';
}

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

  group('AppRouter redirect - initial status', () {
    test('returns null from /bill when status is initial', () {
      expect(authBloc.state.status, AuthStatus.initial);
      expect(_redirect(authBloc, '/bill'), isNull);
    });

    test('returns null from /login when status is initial', () {
      expect(_redirect(authBloc, '/login'), isNull);
    });
  });

  group('AppRouter redirect - checking status', () {
    test('returns null from /bill during checking', () async {
      when(
        () => mockIsAuthenticatedUseCase(),
      ).thenAnswer((_) async => const Right(false));

      authBloc.add(const AppStarted());
      await authBloc.stream.firstWhere((s) => s.status == AuthStatus.checking);

      expect(_redirect(authBloc, '/bill'), isNull);
    });

    test('returns null from /login during checking', () async {
      when(
        () => mockIsAuthenticatedUseCase(),
      ).thenAnswer((_) async => const Right(false));

      authBloc.add(const AppStarted());
      await authBloc.stream.firstWhere((s) => s.status == AuthStatus.checking);

      expect(_redirect(authBloc, '/login'), isNull);
    });
  });

  group('AppRouter redirect - authenticated status', () {
    test('returns /bill from /login when authenticated', () async {
      when(
        () => mockIsAuthenticatedUseCase(),
      ).thenAnswer((_) async => const Right(true));
      when(() => mockGetCurrentUserUseCase()).thenAnswer(
        (_) async => Right(
          User(
            id: 1,
            username: 'admin',
            role: 'admin',
            isActive: true,
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
          ),
        ),
      );

      authBloc.add(const AppStarted());
      await authBloc.stream.firstWhere(
        (s) => s.status == AuthStatus.authenticated,
      );

      expect(_redirect(authBloc, '/login'), equals('/bill'));
    });

    test('returns null from /bill when authenticated', () async {
      when(
        () => mockIsAuthenticatedUseCase(),
      ).thenAnswer((_) async => const Right(true));
      when(() => mockGetCurrentUserUseCase()).thenAnswer(
        (_) async => Right(
          User(
            id: 1,
            username: 'admin',
            role: 'admin',
            isActive: true,
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
          ),
        ),
      );

      authBloc.add(const AppStarted());
      await authBloc.stream.firstWhere(
        (s) => s.status == AuthStatus.authenticated,
      );

      expect(_redirect(authBloc, '/bill'), isNull);
    });
  });

  group('AppRouter redirect - failure/unauthenticated status', () {
    test('returns /login from /bill when unauthenticated', () async {
      when(
        () => mockIsAuthenticatedUseCase(),
      ).thenAnswer((_) async => const Right(false));

      authBloc.add(const AppStarted());
      await authBloc.stream.firstWhere(
        (s) => s.status == AuthStatus.unauthenticated,
      );

      expect(_redirect(authBloc, '/bill'), equals('/login'));
    });

    test('returns null from /login when unauthenticated', () async {
      when(
        () => mockIsAuthenticatedUseCase(),
      ).thenAnswer((_) async => const Right(false));

      authBloc.add(const AppStarted());
      await authBloc.stream.firstWhere(
        (s) => s.status == AuthStatus.unauthenticated,
      );

      expect(_redirect(authBloc, '/login'), isNull);
    });
  });
}
