import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/core/database/daos/user_dao.dart';
import 'package:weighbridge/core/security/password_hasher.dart';

void main() {
  test('Full auth flow: hash → store → retrieve → verify', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final userDao = UserDao(database);
    final hasher = PasswordHasher();

    try {
      // 1. Simulate seeding
      final hash = hasher.hashPassword('Admin@123');

      await userDao.insertUser(
        UsersCompanion.insert(
          username: 'admin',
          passwordHash: hash,
          role: const Value('admin'),
        ),
      );

      // 2. Simulate login lookup
      final user = await userDao.getUserByUsername('admin');
      expect(user, isNotNull, reason: 'Admin user should exist in DB');

      // 3. Simulate password verification
      final isValid = hasher.verifyPassword('Admin@123', user!.passwordHash);
      expect(isValid, isTrue, reason: 'Password should verify correctly');

      // 4. Check that the stored hash is NOT plaintext
      expect(user.passwordHash, isNot(equals('Admin@123')));
      expect(user.passwordHash, isNot(contains('Admin@123')));

      // 5. Verify wrong password fails
      final isWrong = hasher.verifyPassword('wrongpassword', user.passwordHash);
      expect(isWrong, isFalse);
    } finally {
      await database.close();
    }
  });

  test('AuthLocalDataSource full flow', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final hasher = PasswordHasher();

    try {
      // Seed admin
      final hash = hasher.hashPassword('Admin@123');
      await database
          .into(database.users)
          .insert(
            UsersCompanion.insert(
              username: 'admin',
              passwordHash: hash,
              role: const Value('admin'),
            ),
          );

      // Query via DAO
      final user = await database.userDao.getUserByUsername('admin');
      expect(user, isNotNull);
      expect(user!.username, 'admin');
      expect(user.role, 'admin');

      // Verify password
      final isValid = hasher.verifyPassword('Admin@123', user.passwordHash);
      expect(isValid, isTrue);
    } finally {
      await database.close();
    }
  });
}
