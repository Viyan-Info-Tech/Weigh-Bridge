import '../database/app_database.dart';
import 'password_hasher.dart';

class AdminPasswordService {
  AdminPasswordService({
    required AppDatabase database,
    required PasswordHasher passwordHasher,
  }) : _database = database,
       _passwordHasher = passwordHasher;

  static const defaultPassword = '123';

  final AppDatabase _database;
  final PasswordHasher _passwordHasher;

  Future<void> initialize() async {
    if (await _database.getAdminPasswordHash() == null) {
      await _database.saveAdminPasswordHash(
        _passwordHasher.hashPassword(defaultPassword),
      );
    }
  }

  Future<bool> verify(String password) async {
    final hash = await _database.getAdminPasswordHash();
    return hash != null && _passwordHasher.verifyPassword(password, hash);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!await verify(currentPassword)) {
      throw const AdminPasswordException('Current password is incorrect.');
    }
    if (newPassword.trim().isEmpty) {
      throw const AdminPasswordException('New password cannot be empty.');
    }
    await _database.saveAdminPasswordHash(
      _passwordHasher.hashPassword(newPassword),
    );
  }
}

class AdminPasswordException implements Exception {
  const AdminPasswordException(this.message);

  final String message;

  @override
  String toString() => message;
}
