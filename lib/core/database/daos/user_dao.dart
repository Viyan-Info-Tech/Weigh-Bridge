import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<User?> getUserByUsername(String username) async {
    final query = select(users)..where((u) => u.username.equals(username));
    return query.getSingleOrNull();
  }

  Future<User?> getUserById(int id) async {
    final query = select(users)..where((u) => u.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<int> insertUser(UsersCompanion entry) async {
    return into(users).insert(entry);
  }

  Future<bool> userExists(String username) async {
    final query = select(users)..where((u) => u.username.equals(username));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  Future<int> getUserCount() async {
    final count = users.id.count();
    final query = selectOnly(users)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
