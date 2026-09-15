import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/core/database/daos/user_dao.dart';
import 'package:weighbridge/core/security/password_hasher.dart';

void main() {
  late AppDatabase database;
  late UserDao userDao;
  late PasswordHasher passwordHasher;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    userDao = UserDao(database);
    passwordHasher = PasswordHasher();
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Seeding', () {
    test('admin user is created on first launch', () async {
      final exists = await userDao.userExists('admin');
      expect(exists, isFalse);

      final hash = passwordHasher.hashPassword('Admin@123');
      await userDao.insertUser(
        UsersCompanion.insert(
          username: 'admin',
          passwordHash: hash,
          role: const Value('admin'),
        ),
      );

      final adminExists = await userDao.userExists('admin');
      expect(adminExists, isTrue);
    });

    test('admin user is not duplicated on second launch', () async {
      final hash = passwordHasher.hashPassword('Admin@123');

      await userDao.insertUser(
        UsersCompanion.insert(
          username: 'admin',
          passwordHash: hash,
          role: const Value('admin'),
        ),
      );

      final count1 = await userDao.getUserCount();
      expect(count1, 1);

      final exists = await userDao.userExists('admin');
      if (!exists) {
        await userDao.insertUser(
          UsersCompanion.insert(
            username: 'admin',
            passwordHash: hash,
            role: const Value('admin'),
          ),
        );
      }

      final count2 = await userDao.getUserCount();
      expect(count2, 1);
    });

    test('admin user has correct username', () async {
      final hash = passwordHasher.hashPassword('Admin@123');
      await userDao.insertUser(
        UsersCompanion.insert(
          username: 'admin',
          passwordHash: hash,
          role: const Value('admin'),
        ),
      );

      final user = await userDao.getUserByUsername('admin');
      expect(user, isNotNull);
      expect(user!.username, 'admin');
      expect(user.role, 'admin');
      expect(user.isActive, isTrue);
    });

    test('admin password hash is not plaintext', () async {
      final hash = passwordHasher.hashPassword('Admin@123');
      await userDao.insertUser(
        UsersCompanion.insert(
          username: 'admin',
          passwordHash: hash,
          role: const Value('admin'),
        ),
      );

      final user = await userDao.getUserByUsername('admin');
      expect(user, isNotNull);
      expect(user!.passwordHash, isNot(equals('Admin@123')));
      expect(user.passwordHash, isNot(contains('Admin@123')));
    });

    test('admin password can be verified', () async {
      final hash = passwordHasher.hashPassword('Admin@123');
      await userDao.insertUser(
        UsersCompanion.insert(
          username: 'admin',
          passwordHash: hash,
          role: const Value('admin'),
        ),
      );

      final user = await userDao.getUserByUsername('admin');
      expect(user, isNotNull);

      final isValid = passwordHasher.verifyPassword(
        'Admin@123',
        user!.passwordHash,
      );
      expect(isValid, isTrue);

      final isInvalid = passwordHasher.verifyPassword(
        'wrongpassword',
        user.passwordHash,
      );
      expect(isInvalid, isFalse);
    });

    test('getUserCount returns correct count', () async {
      final count1 = await userDao.getUserCount();
      expect(count1, 0);

      final hash = passwordHasher.hashPassword('Admin@123');
      await userDao.insertUser(
        UsersCompanion.insert(
          username: 'admin',
          passwordHash: hash,
          role: const Value('admin'),
        ),
      );

      final count2 = await userDao.getUserCount();
      expect(count2, 1);
    });
  });
}
