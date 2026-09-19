import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

import '../../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createInMemoryDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  UsersCompanion user(
    String username, {
    String role = 'operator',
    bool isActive = true,
  }) {
    return UsersCompanion.insert(
      username: username,
      passwordHash: 'hash:$username',
      role: Value(role),
      isActive: Value(isActive),
    );
  }

  group('UserDao', () {
    test('getUserCount starts empty and counts inserts', () async {
      expect(await db.userDao.getUserCount(), 0);
      await db.userDao.insertUser(user('operator1'));
      await db.userDao.insertUser(user('operator2'));
      expect(await db.userDao.getUserCount(), 2);
    });

    test('userExists returns expected result', () async {
      await db.userDao.insertUser(user('admin', role: 'admin'));
      expect(await db.userDao.userExists('admin'), isTrue);
      expect(await db.userDao.userExists('nobody'), isFalse);
    });

    test('getUserByUsername returns the stored user', () async {
      await db.userDao.insertUser(user('admin', role: 'admin'));
      final found = await db.userDao.getUserByUsername('admin');
      expect(found, isNotNull);
      expect(found!.role, 'admin');
      expect(found.isActive, isTrue);
      expect(found.passwordHash, isNot('admin'));
    });

    test('getUserById returns the stored user', () async {
      final id = await db.userDao.insertUser(user('operator1'));
      final found = await db.userDao.getUserById(id);
      expect(found, isNotNull);
      expect(found!.username, 'operator1');
    });

    test('lookups return null for missing users', () async {
      expect(await db.userDao.getUserByUsername('missing'), isNull);
      expect(await db.userDao.getUserById(999), isNull);
    });

    test('username is unique', () async {
      await db.userDao.insertUser(user('admin'));
      expect(
        () => db.userDao.insertUser(user('admin')),
        throwsA(isA<Exception>()),
      );
    });
  });
}