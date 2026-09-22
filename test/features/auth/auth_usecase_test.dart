import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/core/error/failures.dart';
import 'package:weighbridge/features/auth/domain/entities/user.dart';
import 'package:weighbridge/features/auth/domain/repositories/auth_repository.dart';
import 'package:weighbridge/features/auth/domain/usecases/get_current_user.dart';
import 'package:weighbridge/features/auth/domain/usecases/is_authenticated.dart';
import 'package:weighbridge/features/auth/domain/usecases/login.dart';
import 'package:weighbridge/features/auth/domain/usecases/logout.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  late LogoutUseCase logoutUseCase;
  late IsAuthenticatedUseCase isAuthenticatedUseCase;
  late GetCurrentUserUseCase getCurrentUserUseCase;

  final testUser = User(
    id: 1,
    username: 'admin',
    role: 'admin',
    isActive: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
    logoutUseCase = LogoutUseCase(mockRepository);
    isAuthenticatedUseCase = IsAuthenticatedUseCase(mockRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    test('delegates to repository login with username and password', () async {
      when(
        () => mockRepository.login('admin', 'password123'),
      ).thenAnswer((_) async => Right(testUser));

      final result = await loginUseCase('admin', 'password123');

      expect(result.fold((l) => l, (r) => r), isA<User>());
      verify(() => mockRepository.login('admin', 'password123')).called(1);
    });

    test(
      'returns AuthenticationFailure when repository returns failure',
      () async {
        when(
          () => mockRepository.login('admin', 'wrong'),
        ).thenAnswer((_) async => Left(AuthenticationFailure()));

        final result = await loginUseCase('admin', 'wrong');

        expect(result.fold((l) => l, (r) => r), isA<AuthenticationFailure>());
      },
    );

    test('returns DatabaseFailure when repository returns it', () async {
      when(
        () => mockRepository.login('admin', 'password'),
      ).thenAnswer((_) async => const Left(DatabaseFailure()));

      final result = await loginUseCase('admin', 'password');

      expect(result.fold((l) => l, (r) => r), isA<DatabaseFailure>());
    });

    test('passes username to repository', () async {
      when(
        () => mockRepository.login('admin', 'password'),
      ).thenAnswer((_) async => Right(testUser));

      await loginUseCase('admin', 'password');

      verify(() => mockRepository.login('admin', 'password')).called(1);
    });
  });

  group('LogoutUseCase', () {
    test('delegates to repository logout', () async {
      when(
        () => mockRepository.logout(),
      ).thenAnswer((_) async => const Right(null));

      final result = await logoutUseCase();

      verify(() => mockRepository.logout()).called(1);
      expect(result.fold<Failure?>((l) => l, (_) => null), isNull);
    });

    test('returns SessionFailure when repository returns it', () async {
      when(
        () => mockRepository.logout(),
      ).thenAnswer((_) async => const Left(SessionFailure()));

      final result = await logoutUseCase();

      expect(
        result.fold<Failure>((l) => l, (_) => UnknownFailure()),
        isA<SessionFailure>(),
      );
    });
  });

  group('IsAuthenticatedUseCase', () {
    test('returns true when repository returns true', () async {
      when(
        () => mockRepository.isAuthenticated(),
      ).thenAnswer((_) async => const Right(true));

      final result = await isAuthenticatedUseCase();

      expect(result.fold((l) => l, (r) => r), isTrue);
    });

    test('returns false when repository returns false', () async {
      when(
        () => mockRepository.isAuthenticated(),
      ).thenAnswer((_) async => const Right(false));

      final result = await isAuthenticatedUseCase();

      expect(result.fold((l) => l, (r) => r), isFalse);
    });

    test('returns SessionFailure when repository returns it', () async {
      when(
        () => mockRepository.isAuthenticated(),
      ).thenAnswer((_) async => const Left(SessionFailure()));

      final result = await isAuthenticatedUseCase();

      expect(result.fold((l) => l, (r) => r), isA<SessionFailure>());
    });
  });

  group('GetCurrentUserUseCase', () {
    test('returns user when authenticated', () async {
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => Right(testUser));

      final result = await getCurrentUserUseCase();

      expect(result.fold((l) => l, (r) => r), testUser);
    });

    test('returns null when no user exists', () async {
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(null));

      final result = await getCurrentUserUseCase();

      expect(result.fold((l) => l, (r) => r), isNull);
    });

    test('returns SessionFailure when repository returns it', () async {
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(SessionFailure()));

      final result = await getCurrentUserUseCase();

      expect(result.fold((l) => l, (r) => r), isA<SessionFailure>());
    });
  });
}
