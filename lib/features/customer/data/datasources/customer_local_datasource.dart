import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/customer.dart' as domain;

class CustomerLocalDataSource {
  final AppDatabase _database;

  CustomerLocalDataSource(this._database);

  Future<List<domain.Customer>> getAllCustomers() async {
    final records = await _database.customerDao.getAllCustomers();
    return records
        .map(
          (r) => domain.Customer(
            id: r.id,
            name: r.name,
            contactPerson: r.contactPerson,
            mobile: r.mobile,
            email: r.email,
            address: r.address,
            gstNumber: r.gstNumber,
            city: r.city,
            state: r.state,
            isActive: r.isActive,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        )
        .toList();
  }

  Future<List<domain.Customer>> getAllActiveCustomers() async {
    final records = await _database.customerDao.getAllActiveCustomers();
    return records
        .map(
          (r) => domain.Customer(
            id: r.id,
            name: r.name,
            contactPerson: r.contactPerson,
            mobile: r.mobile,
            email: r.email,
            address: r.address,
            gstNumber: r.gstNumber,
            city: r.city,
            state: r.state,
            isActive: r.isActive,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        )
        .toList();
  }

  Future<List<domain.Customer>> getCustomersByStatus({
    required bool isActive,
  }) async {
    final records = await _database.customerDao.getCustomersByStatus(
      isActive: isActive,
    );
    return records
        .map(
          (r) => domain.Customer(
            id: r.id,
            name: r.name,
            contactPerson: r.contactPerson,
            mobile: r.mobile,
            email: r.email,
            address: r.address,
            gstNumber: r.gstNumber,
            city: r.city,
            state: r.state,
            isActive: r.isActive,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        )
        .toList();
  }

  Future<domain.Customer?> getCustomerById(int id) async {
    final record = await _database.customerDao.getCustomerById(id);
    if (record == null) return null;
    return domain.Customer(
      id: record.id,
      name: record.name,
      contactPerson: record.contactPerson,
      mobile: record.mobile,
      email: record.email,
      address: record.address,
      gstNumber: record.gstNumber,
      city: record.city,
      state: record.state,
      isActive: record.isActive,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  Future<int> createCustomer({
    required String name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  }) async {
    return await _database.customerDao.insertCustomer(
      CustomersCompanion.insert(
        name: name,
        contactPerson: Value(contactPerson),
        mobile: Value(mobile),
        email: Value(email),
        address: Value(address),
        gstNumber: Value(gstNumber),
        city: Value(city),
        state: Value(state),
      ),
    );
  }

  Future<bool> updateCustomer({
    required int id,
    required String name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  }) async {
    return await _database.customerDao.updateCustomer(
      CustomersCompanion(
        id: Value(id),
        name: Value(name),
        contactPerson: Value(contactPerson),
        mobile: Value(mobile),
        email: Value(email),
        address: Value(address),
        gstNumber: Value(gstNumber),
        city: Value(city),
        state: Value(state),
      ),
    );
  }

  Future<void> deactivateCustomer(int id) async {
    await _database.customerDao.deactivateCustomer(id);
  }

  Future<void> deleteCustomer(int id) async {
    await _database.customerDao.deleteCustomer(id);
  }

  Future<List<domain.Customer>> searchCustomers(String query) async {
    final records = await _database.customerDao.searchCustomers(query);
    return records
        .map(
          (r) => domain.Customer(
            id: r.id,
            name: r.name,
            contactPerson: r.contactPerson,
            mobile: r.mobile,
            email: r.email,
            address: r.address,
            gstNumber: r.gstNumber,
            city: r.city,
            state: r.state,
            isActive: r.isActive,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        )
        .toList();
  }

  Future<int> totalCustomerCount() async {
    return await _database.customerDao.customerCount();
  }

  Future<int> activeCustomerCount() async {
    return await _database.customerDao.activeCustomerCount();
  }

  Future<int> inactiveCustomerCount() async {
    return await _database.customerDao.inactiveCustomerCount();
  }
}
