import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/customers_table.dart';

part 'customer_dao.g.dart';

@DriftAccessor(tables: [Customers])
class CustomerDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerDaoMixin {
  CustomerDao(super.db);

  Future<List<Customer>> getAllActiveCustomers() async {
    final query = select(customers)..where((c) => c.isActive.equals(true));
    return query.get();
  }

  Future<List<Customer>> getAllCustomers() async {
    return select(customers).get();
  }

  Future<List<Customer>> getCustomersByStatus({required bool isActive}) async {
    final query = select(customers)..where((c) => c.isActive.equals(isActive));
    return query.get();
  }

  Future<Customer?> getCustomerById(int id) async {
    final query = select(customers)..where((c) => c.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<Customer?> getCustomerByName(String name) async {
    final query = select(customers)..where((c) => c.name.equals(name));
    return query.getSingleOrNull();
  }

  Future<int> insertCustomer(CustomersCompanion entry) async {
    return into(customers).insert(entry);
  }

  Future<bool> updateCustomer(CustomersCompanion entry) async {
    return update(customers).replace(entry);
  }

  Future<int> customerCount() async {
    final count = customers.id.count();
    final query = selectOnly(customers)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> activeCustomerCount() async {
    final count = customers.id.count();
    final query = selectOnly(customers)
      ..addColumns([count])
      ..where(customers.isActive.equals(true));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> inactiveCustomerCount() async {
    final count = customers.id.count();
    final query = selectOnly(customers)
      ..addColumns([count])
      ..where(customers.isActive.equals(false));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final q = select(customers)
      ..where(
        (c) =>
            c.name.like('%$query%') |
            c.mobile.like('%$query%') |
            c.contactPerson.like('%$query%') |
            c.gstNumber.like('%$query%'),
      )
      ..limit(20);
    return q.get();
  }

  Future<void> deactivateCustomer(int id) async {
    final now = DateTime.now();
    await (update(customers)..where((c) => c.id.equals(id))).write(
      CustomersCompanion(isActive: const Value(false), updatedAt: Value(now)),
    );
  }

  Future<int> deleteCustomer(int id) async {
    return await (delete(customers)..where((c) => c.id.equals(id))).go();
  }
}
