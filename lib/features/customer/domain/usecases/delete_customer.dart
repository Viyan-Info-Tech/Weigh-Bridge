import '../repositories/customer_repository.dart';

class DeleteCustomerUseCase {
  final CustomerRepository _repository;

  DeleteCustomerUseCase(this._repository);

  Future<void> call(int customerId) async {
    await _repository.deleteCustomer(customerId);
  }
}
