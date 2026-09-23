import '../repositories/customer_repository.dart';

class CreateCustomerUseCase {
  final CustomerRepository _repository;

  CreateCustomerUseCase(this._repository);

  Future<int> call({
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
    final normalizedName = name.trim();
    final normalizedCode = customerCode?.trim() ?? '';
    final normalizedPhone = mobile?.trim() ?? '';
    if (normalizedCode.isEmpty) {
      throw Exception('Please enter customer code');
    }
    if (normalizedName.isEmpty) {
      throw Exception('Please enter customer name');
    }
    if (normalizedPhone.isNotEmpty &&
        !RegExp(r'^\d{10}$').hasMatch(normalizedPhone)) {
      throw Exception('Phone number must be exactly 10 digits');
    }
    if (customerCode != null &&
        customerCode.isNotEmpty &&
        await _repository.getCustomerByCode(normalizedCode) != null) {
      throw Exception(
        'Customer code "$customerCode" already exists. Please enter a different customer code.',
      );
    }
    final existingCustomers = await _repository.searchCustomers(normalizedName);
    final exactMatch = existingCustomers.where(
      (c) => c.name.toLowerCase() == normalizedName.toLowerCase(),
    );
    if (exactMatch.isNotEmpty) {
      throw Exception('Customer with this name already exists');
    }

    return await _repository.createCustomer(
      name: normalizedName,
      customerCode: normalizedCode.toUpperCase(),
      contactPerson: contactPerson,
      mobile: normalizedPhone.isEmpty ? null : normalizedPhone,
      email: email,
      address: address,
      gstNumber: gstNumber,
      city: city,
      state: state,
    );
  }
}
