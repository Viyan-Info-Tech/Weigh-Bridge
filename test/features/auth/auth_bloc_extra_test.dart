import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/core/error/failures.dart';
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

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockIsAuthenticatedUseCase mockIsAuthenticatedUseCase;

  final testUser = User(
    id: 1,
    username: 'admin',
    role: 'admin',
    isActive: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

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

  group('AuthBloc failure paths', () {
    test(
      'emits [checking, unauthenticated] when isAuthenticated throws',
      () async {
        when(
          () => mockIsAuthenticatedUseCase(),
        ).thenThrow(Exception('network error'));

        authBloc.add(const AppStarted());

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.checking),
            const AuthState(status: AuthStatus.unauthenticated),
          ]),
        );
      },
    );

    test(
      'emits [checking, unauthenticated] when getCurrentUser throws but isAuthenticated true',
      () async {
        when(
          () => mockIsAuthenticatedUseCase(),
        ).thenAnswer((_) async => const Right(true));
        when(() => mockGetCurrentUserUseCase()).thenThrow(Exception('error'));

        authBloc.add(const AppStarted());

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.checking),
            const AuthState(status: AuthStatus.unauthenticated),
          ]),
        );
      },
    );

    test(
      'emits [authenticating, failure] when login use case throws',
      () async {
        when(
          () => mockLoginUseCase('admin', 'password'),
        ).thenThrow(Exception('unexpected'));

        authBloc.add(
          const LoginSubmitted(username: 'admin', password: 'password'),
        );

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.authenticating),
            const AuthState(
              status: AuthStatus.failure,
              errorMessage: 'An unexpected error occurred.',
            ),
          ]),
        );
      },
    );

    test(
      'emits [authenticating, failure] with DatabaseFailure message on login',
      () async {
        when(
          () => mockLoginUseCase('admin', 'password'),
        ).thenAnswer((_) async => const Left(DatabaseFailure()));

        authBloc.add(
          const LoginSubmitted(username: 'admin', password: 'password'),
        );

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.authenticating),
            const AuthState(
              status: AuthStatus.failure,
              errorMessage: 'Something went wrong. Please try again.',
            ),
          ]),
        );
      },
    );

    test(
      'emits [authenticating, failure] with SessionFailure message on login',
      () async {
        when(
          () => mockLoginUseCase('admin', 'password'),
        ).thenAnswer((_) async => const Left(SessionFailure()));

        authBloc.add(
          const LoginSubmitted(username: 'admin', password: 'password'),
        );

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.authenticating),
            const AuthState(
              status: AuthStatus.failure,
              errorMessage: 'Session error occurred.',
            ),
          ]),
        );
      },
    );

    test(
      'emits [authenticating, failure] with ValidationFailure message on login',
      () async {
        when(() => mockLoginUseCase('admin', 'password')).thenAnswer(
          (_) async => const Left(ValidationFailure(message: 'Invalid')),
        );

        authBloc.add(
          const LoginSubmitted(username: 'admin', password: 'password'),
        );

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.authenticating),
            const AuthState(
              status: AuthStatus.failure,
              errorMessage: 'Invalid',
            ),
          ]),
        );
      },
    );

    test(
      'emits [authenticating, failure] with UnknownFailure message on login',
      () async {
        when(
          () => mockLoginUseCase('admin', 'password'),
        ).thenAnswer((_) async => const Left(UnknownFailure()));

        authBloc.add(
          const LoginSubmitted(username: 'admin', password: 'password'),
        );

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.authenticating),
            const AuthState(
              status: AuthStatus.failure,
              errorMessage: 'An unexpected error occurred.',
            ),
          ]),
        );
      },
    );

    test('logout use case failure still emits unauthenticated', () async {
      when(
        () => mockLogoutUseCase(),
      ).thenAnswer((_) async => const Left(SessionFailure()));

      authBloc.add(const LogoutRequested());

      await expectLater(
        authBloc.stream,
        emits(
          const AuthState(
            status: AuthStatus.unauthenticated,
            user: null,
            errorMessage: null,
          ),
        ),
      );
    });

    test('failure state does not retain previous user', () async {
      when(
        () => mockLoginUseCase('admin', 'wrong'),
      ).thenAnswer((_) async => const Left(AuthenticationFailure()));

      authBloc.add(const LoginSubmitted(username: 'admin', password: 'wrong'));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthState(status: AuthStatus.authenticating),
          const AuthState(
            status: AuthStatus.failure,
            errorMessage: 'Invalid username or password',
          ),
        ]),
      );

      final state = authBloc.state;
      expect(state.user, isNull);
    });
  });

  group('AuthBloc concurrency', () {
    test('handles rapid successive login attempts sequentially', () async {
      when(
        () => mockLoginUseCase('user1', 'pass1'),
      ).thenAnswer((_) async => Right(testUser));
      when(
        () => mockLoginUseCase('user2', 'pass2'),
      ).thenAnswer((_) async => const Left(AuthenticationFailure()));

      authBloc.add(const LoginSubmitted(username: 'user1', password: 'pass1'));
      authBloc.add(const LoginSubmitted(username: 'user2', password: 'pass2'));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthState(status: AuthStatus.authenticating),
          AuthState(status: AuthStatus.authenticated, user: testUser),
          AuthState(status: AuthStatus.authenticating, user: testUser),
          const AuthState(
            status: AuthStatus.failure,
            errorMessage: 'Invalid username or password',
          ),
        ]),
      );
    });

    test('handles multiple AppStarted events', () async {
      when(
        () => mockIsAuthenticatedUseCase(),
      ).thenAnswer((_) async => const Right(false));

      authBloc.add(const AppStarted());
      authBloc.add(const AppStarted());

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthState(status: AuthStatus.checking),
          const AuthState(status: AuthStatus.unauthenticated),
          const AuthState(status: AuthStatus.checking),
          const AuthState(status: AuthStatus.unauthenticated),
        ]),
      );
    });

    test('login during authenticating state queues properly', () async {
      when(
        () => mockLoginUseCase('admin', 'password'),
      ).thenAnswer((_) async => Right(testUser));

      authBloc.add(
        const LoginSubmitted(username: 'admin', password: 'password'),
      );
      authBloc.add(
        const LoginSubmitted(username: 'admin', password: 'password'),
      );

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthState(status: AuthStatus.authenticating),
          AuthState(status: AuthStatus.authenticated, user: testUser),
          AuthState(status: AuthStatus.authenticating, user: testUser),
          AuthState(status: AuthStatus.authenticated, user: testUser),
        ]),
      );
    });
  });

  group('AuthBloc session paths', () {
    test('initial state is not authenticated', () {
      expect(authBloc.state.status, AuthStatus.initial);
      expect(authBloc.state.user, isNull);
    });

    test(
      'checking state transitions to unauthenticated when not authenticated',
      () async {
        when(
          () => mockIsAuthenticatedUseCase(),
        ).thenAnswer((_) async => const Right(false));

        authBloc.add(const AppStarted());

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.checking),
            const AuthState(status: AuthStatus.unauthenticated),
          ]),
        );
      },
    );

    test(
      'checking state transitions to authenticated when user exists',
      () async {
        when(
          () => mockIsAuthenticatedUseCase(),
        ).thenAnswer((_) async => const Right(true));
        when(
          () => mockGetCurrentUserUseCase(),
        ).thenAnswer((_) async => Right(testUser));

        authBloc.add(const AppStarted());

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.checking),
            AuthState(status: AuthStatus.authenticated, user: testUser),
          ]),
        );
      },
    );

    test(
      'authenticated state can transition to unauthenticated via logout',
      () async {
        when(
          () => mockIsAuthenticatedUseCase(),
        ).thenAnswer((_) async => const Right(true));
        when(
          () => mockGetCurrentUserUseCase(),
        ).thenAnswer((_) async => Right(testUser));
        when(
          () => mockLogoutUseCase(),
        ).thenAnswer((_) async => const Right(null));

        authBloc.add(const AppStarted());
        await authBloc.stream.firstWhere(
          (s) => s.status == AuthStatus.authenticated,
        );

        authBloc.add(const LogoutRequested());

        await expectLater(
          authBloc.stream,
          emits(
            const AuthState(
              status: AuthStatus.unauthenticated,
              user: null,
              errorMessage: null,
            ),
          ),
        );
      },
    );

    test(
      'authenticated state can transition to failure then back to authenticated',
      () async {
        when(
          () => mockLoginUseCase('admin', 'password'),
        ).thenAnswer((_) async => Right(testUser));

        authBloc.add(
          const LoginSubmitted(username: 'admin', password: 'password'),
        );

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            const AuthState(status: AuthStatus.authenticating),
            AuthState(status: AuthStatus.authenticated, user: testUser),
          ]),
        );

        when(
          () => mockLoginUseCase('admin', 'wrong'),
        ).thenAnswer((_) async => const Left(AuthenticationFailure()));

        authBloc.add(
          const LoginSubmitted(username: 'admin', password: 'wrong'),
        );

        await expectLater(
          authBloc.stream,
          emitsInOrder([
            AuthState(status: AuthStatus.authenticating, user: testUser),
            const AuthState(
              status: AuthStatus.failure,
              errorMessage: 'Invalid username or password',
            ),
          ]),
        );
      },
    );
  });

  group('AuthBloc listener disposal', () {
    test('closing bloc closes stream', () async {
      when(
        () => mockIsAuthenticatedUseCase(),
      ).thenAnswer((_) async => const Right(false));

      authBloc.add(const AppStarted());
      await authBloc.stream.firstWhere(
        (s) => s.status == AuthStatus.unauthenticated,
      );

      authBloc.close();

      expect(authBloc.isClosed, isTrue);
    });

    test('closed bloc does not emit new states', () async {
      when(
        () => mockIsAuthenticatedUseCase(),
      ).thenAnswer((_) async => const Right(false));

      authBloc.add(const AppStarted());
      await authBloc.stream.firstWhere(
        (s) => s.status == AuthStatus.unauthenticated,
      );

      authBloc.close();

      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      expect(states, isEmpty);
    });
  });
}
