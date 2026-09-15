import '../entities/weighment.dart';

abstract class BillRepository {
  Future<int> saveWeighment(Weighment weighment);
  Future<void> updateWeighment(int id, Weighment weighment);
  Future<List<Weighment>> getRecentBills({DateTime? date, int? limit});
  Future<List<Weighment>> getRecentBillsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  });
  Future<Weighment?> getWeighmentById(int id);
  Future<Weighment?> getWeighmentByBillNumber(String billNumber);
  Future<String> generateNextBillNumber();
  Future<List<Weighment>> getPendingBills();
  Future<int> deleteWeighment(int id);
}
