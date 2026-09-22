import '../repositories/customer_repository.dart';

class DeactivateCustomerUseCase {
  final CustomerRepository _repository;

  DeactivateCustomerUseCase(this._repository);

  Future<void> call(int customerId) async {
    await _repository.deactivateCustomer(customerId);
  }
}
