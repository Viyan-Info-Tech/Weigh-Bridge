import '../datasources/bill_local_datasource.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/repositories/bill_repository.dart';

class BillRepositoryImpl implements BillRepository {
  final BillLocalDataSource _localDataSource;

  BillRepositoryImpl({required BillLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<int> saveWeighment(Weighment weighment) async {
    return _localDataSource.saveWeighment(weighment);
  }

  @override
  Future<void> updateWeighment(int id, Weighment weighment) async {
    return _localDataSource.updateWeighment(id, weighment);
  }

  @override
  Future<List<Weighment>> getRecentBills({int limit = 20}) async {
    return _localDataSource.getRecentBills(limit: limit);
  }

  @override
  Future<Weighment?> getWeighmentById(int id) async {
    return _localDataSource.getWeighmentById(id);
  }

  @override
  Future<Weighment?> getWeighmentByBillNumber(String billNumber) async {
    return _localDataSource.getRecentBills(limit: 1).then(
      (bills) => bills.where((b) => b.billNumber == billNumber).firstOrNull,
    );
  }

  @override
  Future<String> generateNextBillNumber() async {
    return _localDataSource.generateNextBillNumber();
  }

  @override
  Future<int> deleteWeighment(int id) async {
    return _localDataSource.deleteWeighment(id);
  }
}
