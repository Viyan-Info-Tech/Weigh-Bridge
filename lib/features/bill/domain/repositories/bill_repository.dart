import '../entities/weighment.dart';

abstract class BillRepository {
  Future<int> saveWeighment(Weighment weighment);
  Future<List<Weighment>> getRecentBills({int limit = 20});
  Future<Weighment?> getWeighmentById(int id);
  Future<Weighment?> getWeighmentByBillNumber(String billNumber);
  Future<String> generateNextBillNumber();
  Future<int> deleteWeighment(int id);
}
