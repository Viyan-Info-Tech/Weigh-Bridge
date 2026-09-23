import '../repositories/customer_repository.dart';

class UpdateCustomerUseCase {
  final CustomerRepository _repository;

  UpdateCustomerUseCase(this._repository);

  Future<bool> call({
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
    final existing = customerCode == null || customerCode.isEmpty
        ? null
        : await _repository.getCustomerByCode(customerCode);
    if (existing != null && existing.id != id) {
      throw Exception(
        'Customer code "$customerCode" already exists. Please enter a different customer code.',
      );
    }
    return await _repository.updateCustomer(
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
}
