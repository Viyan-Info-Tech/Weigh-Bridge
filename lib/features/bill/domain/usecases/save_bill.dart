import '../entities/weighment.dart';
import '../repositories/bill_repository.dart';

class SaveBillUseCase {
  final BillRepository _repository;

  SaveBillUseCase(this._repository);

  Future<int> call(Weighment weighment) async {
    return _repository.saveWeighment(weighment);
  }
}

class LoadRecentBillsUseCase {
  final BillRepository _repository;

  LoadRecentBillsUseCase(this._repository);

  Future<List<Weighment>> call({int limit = 20}) async {
    return _repository.getRecentBills(limit: limit);
  }
}

class GenerateBillNumberUseCase {
  final BillRepository _repository;

  GenerateBillNumberUseCase(this._repository);

  Future<String> call() async {
    return _repository.generateNextBillNumber();
  }
}
