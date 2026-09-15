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

  group('AuthBloc', () {
    test('initial state is AuthState.initial', () {
      expect(authBloc.state.status, AuthStatus.initial);
      expect(authBloc.state.user, isNull);
      expect(authBloc.state.errorMessage, isNull);
    });

    group('AppStarted', () {
      test(
        'emits [checking, unauthenticated] when not authenticated',
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
        'emits [checking, authenticated] when authenticated and user exists',
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
        'emits [checking, unauthenticated] when authenticated but user is null',
        () async {
          when(
            () => mockIsAuthenticatedUseCase(),
          ).thenAnswer((_) async => const Right(true));
          when(
            () => mockGetCurrentUserUseCase(),
          ).thenAnswer((_) async => const Right(null));

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
    });

    group('LoginSubmitted', () {
      test(
        'emits [authenticating, authenticated] on successful login',
        () async {
          when(
            () => mockLoginUseCase('admin', 'Admin@123'),
          ).thenAnswer((_) async => Right(testUser));

          authBloc.add(
            const LoginSubmitted(username: 'admin', password: 'Admin@123'),
          );

          await expectLater(
            authBloc.stream,
            emitsInOrder([
              const AuthState(status: AuthStatus.authenticating),
              AuthState(status: AuthStatus.authenticated, user: testUser),
            ]),
          );
        },
      );

      test('emits [failure] when login fails', () async {
        when(
          () => mockLoginUseCase('admin', 'wrongpassword'),
        ).thenAnswer((_) async => const Left(AuthenticationFailure()));

        authBloc.add(
          const LoginSubmitted(username: 'admin', password: 'wrongpassword'),
        );

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
      });

      test('emits [failure] when username is empty', () async {
        authBloc.add(const LoginSubmitted(username: '', password: 'Admin@123'));

        await expectLater(
          authBloc.stream,
          emits(
            const AuthState(
              status: AuthStatus.failure,
              errorMessage: 'Username is required',
            ),
          ),
        );
      });

      test('emits [failure] when password is empty', () async {
        authBloc.add(const LoginSubmitted(username: 'admin', password: ''));

        await expectLater(
          authBloc.stream,
          emits(
            const AuthState(
              status: AuthStatus.failure,
              errorMessage: 'Password is required',
            ),
          ),
        );
      });

      test('emits [failure] when username is whitespace only', () async {
        authBloc.add(
          const LoginSubmitted(username: '   ', password: 'Admin@123'),
        );

        await expectLater(
          authBloc.stream,
          emits(
            const AuthState(
              status: AuthStatus.failure,
              errorMessage: 'Username is required',
            ),
          ),
        );
      });

      test('wrong username returns authentication failure', () async {
        when(
          () => mockLoginUseCase('wronguser', 'Admin@123'),
        ).thenAnswer((_) async => const Left(AuthenticationFailure()));

        authBloc.add(
          const LoginSubmitted(username: 'wronguser', password: 'Admin@123'),
        );

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
      });
    });

    group('LogoutRequested', () {
      test('emits [unauthenticated] on logout', () async {
        when(
          () => mockLogoutUseCase(),
        ).thenAnswer((_) async => const Right(null));

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
    });
  });
}
