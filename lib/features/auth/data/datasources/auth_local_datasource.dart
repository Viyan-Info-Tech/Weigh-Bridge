import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/local_user_model.dart';

class AuthLocalDataSource {
  final AppDatabase _database;

  AuthLocalDataSource(this._database);

  Future<LocalUserModel?> getUserByUsername(String username) async {
    final user = await _database.userDao.getUserByUsername(username);
    if (user == null) return null;
    return LocalUserModel.fromDrift(user);
  }

  Future<void> seedAdminUser(String passwordHash) async {
    final exists = await _database.userDao.userExists('admin');
    if (!exists) {
      await _database.userDao.insertUser(
        UsersCompanion.insert(
          username: 'admin',
          passwordHash: passwordHash,
          role: const Value('admin'),
          isActive: const Value(true),
        ),
      );
    }
  }

  Future<int> getUserCount() async {
    return _database.userDao.getUserCount();
  }
}
