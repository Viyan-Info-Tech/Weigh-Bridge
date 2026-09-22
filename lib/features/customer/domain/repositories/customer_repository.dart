import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAllCustomers();
  Future<List<Customer>> getAllActiveCustomers();
  Future<List<Customer>> getCustomersByStatus({required bool isActive});
  Future<Customer?> getCustomerById(int id);
  Future<int> createCustomer({
    required String name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  });
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
  });
  Future<void> deactivateCustomer(int id);
  Future<void> deleteCustomer(int id);
  Future<List<Customer>> searchCustomers(String query);
  Future<int> totalCustomerCount();
  Future<int> activeCustomerCount();
  Future<int> inactiveCustomerCount();
}
