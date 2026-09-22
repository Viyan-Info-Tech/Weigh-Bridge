import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class LoadCustomersUseCase {
  final CustomerRepository _repository;

  LoadCustomersUseCase(this._repository);

  Future<List<Customer>> call({bool? isActive}) async {
    if (isActive != null) {
      return await _repository.getCustomersByStatus(isActive: isActive);
    }
    return await _repository.getAllCustomers();
  }
}
