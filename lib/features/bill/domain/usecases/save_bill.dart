import '../entities/weighment.dart';
import '../repositories/bill_repository.dart';

class SaveBillUseCase {
  final BillRepository _repository;

  SaveBillUseCase(this._repository);

  Future<int> call(Weighment weighment) async {
    return _repository.saveWeighment(weighment);
  }

  /// Saves a new weighment under a bill number allocated by the database.
  ///
  /// The returned number is authoritative: it is what was stored, and the
  /// caller must not substitute a previously previewed value.
  Future<({int id, String billNumber})> withNewBillNumber(
    Weighment weighment,
  ) async {
    return _repository.saveWeighmentWithNewBillNumber(weighment);
  }

  Future<void> updateWeighment(int id, Weighment weighment) async {
    return _repository.updateWeighment(id, weighment);
  }

  Future<Weighment?> getWeighmentById(int id) async {
    return _repository.getWeighmentById(id);
  }
}

class LoadRecentBillsUseCase {
  final BillRepository _repository;

  LoadRecentBillsUseCase(this._repository);

  Future<List<Weighment>> call({DateTime? date}) async {
    return _repository.getRecentBills(date: date);
  }

  Future<List<Weighment>> byDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _repository.getRecentBillsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class GenerateBillNumberUseCase {
  final BillRepository _repository;

  GenerateBillNumberUseCase(this._repository);

  Future<String> call() async {
    return _repository.generateNextBillNumber();
  }
}
