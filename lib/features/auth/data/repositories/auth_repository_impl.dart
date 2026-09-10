import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/security/password_hasher.dart';
import '../../../../core/security/session_manager.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final PasswordHasher _passwordHasher;
  final SessionManager _sessionManager;

  AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required PasswordHasher passwordHasher,
    required SessionManager sessionManager,
  })  : _localDataSource = localDataSource,
        _passwordHasher = passwordHasher,
        _sessionManager = sessionManager;

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      final trimmedUsername = username.trim();
      final localUser = await _localDataSource.getUserByUsername(trimmedUsername);
      if (localUser == null) {
        return const Left(AuthenticationFailure());
      }

      if (!localUser.isActive) {
        return const Left(AuthenticationFailure(message: 'Account is deactivated'));
      }

      final isValid = _passwordHasher.verifyPassword(password, localUser.passwordHash);
      if (!isValid) {
        return const Left(AuthenticationFailure());
      }

      await _sessionManager.saveSession(
        userId: localUser.id,
        username: localUser.username,
        role: localUser.role,
      );

      return Right(_toEntity(localUser));
    } catch (e) {
      return const Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _sessionManager.clearSession();
      return const Right(null);
    } catch (_) {
      return const Left(SessionFailure());
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      if (!_sessionManager.hasActiveSession()) {
        return const Right(null);
      }

      final userId = _sessionManager.getUserId();
      if (userId == null) {
        return const Right(null);
      }

      final username = _sessionManager.getUsername();
      final role = _sessionManager.getRole();

      if (username == null || role == null) {
        return const Right(null);
      }

      return Right(User(
        id: userId,
        username: username,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (_) {
      return const Left(SessionFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      return Right(_sessionManager.hasActiveSession());
    } catch (_) {
      return const Left(SessionFailure());
    }
  }

  User _toEntity(dynamic localUser) {
    return User(
      id: localUser.id,
      username: localUser.username,
      role: localUser.role,
      isActive: localUser.isActive,
      createdAt: localUser.createdAt,
      updatedAt: localUser.updatedAt,
    );
  }
}
