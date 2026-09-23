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

    final existing = normalizedCode.isEmpty
        ? null
        : await _repository.getCustomerByCode(normalizedCode);
    if (existing != null && existing.id != id) {
      throw Exception(
        'Customer code "$normalizedCode" already exists. Please enter a different customer code.',
      );
    }
    return await _repository.updateCustomer(
      id: id,
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
