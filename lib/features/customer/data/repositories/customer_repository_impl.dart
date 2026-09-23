import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource _dataSource;

  CustomerRepositoryImpl(CustomerLocalDataSource customerLocalDataSource)
    : _dataSource = customerLocalDataSource;

  @override
  Future<List<Customer>> getAllCustomers() async {
    return await _dataSource.getAllCustomers();
  }

  @override
  Future<List<Customer>> getAllActiveCustomers() async {
    return await _dataSource.getAllActiveCustomers();
  }

  @override
  Future<List<Customer>> getCustomersByStatus({required bool isActive}) async {
    return await _dataSource.getCustomersByStatus(isActive: isActive);
  }

  @override
  Future<Customer?> getCustomerById(int id) async {
    return await _dataSource.getCustomerById(id);
  }

  @override
  Future<Customer?> getCustomerByCode(String code) =>
      _dataSource.getCustomerByCode(code);

  @override
  Future<int> createCustomer({
    required String name,
    String? customerCode,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  }) async {
    return await _dataSource.createCustomer(
      name: name,
      customerCode: customerCode,
      contactPerson: contactPerson,
      mobile: mobile,
      email: email,
      address: address,
      gstNumber: gstNumber,
      city: city,
      state: state,
    );
  }

  @override
  Future<bool> updateCustomer({
    required int id,
    required String name,
    String? customerCode,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  }) async {
    return await _dataSource.updateCustomer(
      id: id,
      name: name,
      customerCode: customerCode,
      contactPerson: contactPerson,
      mobile: mobile,
      email: email,
      address: address,
      gstNumber: gstNumber,
      city: city,
      state: state,
    );
  }

  @override
  Future<void> deactivateCustomer(int id) async {
    await _dataSource.deactivateCustomer(id);
  }

  @override
  Future<void> deleteCustomer(int id) async {
    await _dataSource.deleteCustomer(id);
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    return await _dataSource.searchCustomers(query);
  }

  @override
  Future<int> totalCustomerCount() async {
    return await _dataSource.totalCustomerCount();
  }

  @override
  Future<int> activeCustomerCount() async {
    return await _dataSource.activeCustomerCount();
  }

  @override
  Future<int> inactiveCustomerCount() async {
    return await _dataSource.inactiveCustomerCount();
  }
}
