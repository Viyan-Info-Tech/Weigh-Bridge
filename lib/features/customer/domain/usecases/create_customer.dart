import '../repositories/customer_repository.dart';

class CreateCustomerUseCase {
  final CustomerRepository _repository;

  CreateCustomerUseCase(this._repository);

  Future<int> call({
    required String name,
    String? contactPerson,
    String? mobile,
    String? email,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
  }) async {
    final existingCustomers = await _repository.searchCustomers(name);
    final exactMatch = existingCustomers.where(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
    );
    if (exactMatch.isNotEmpty) {
      throw Exception('Customer with this name already exists');
    }

    return await _repository.createCustomer(
      name: name,
      contactPerson: contactPerson,
      mobile: mobile,
      email: email,
      address: address,
      gstNumber: gstNumber,
      city: city,
      state: state,
    );
  }
}
