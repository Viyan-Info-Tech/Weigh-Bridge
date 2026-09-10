import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/weighments_table.dart';

part 'bill_dao.g.dart';

@DriftAccessor(tables: [Weighments])
class BillDao extends DatabaseAccessor<AppDatabase> with _$BillDaoMixin {
  BillDao(super.db);

  Future<int> insertWeighment(WeighmentsCompanion entry) async {
    return into(weighments).insert(entry);
  }

  Future<List<Weighment>> getRecentBills({int limit = 20}) async {
    final query = select(weighments)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    return query.get();
  }

  Future<Weighment?> getWeighmentById(int id) async {
    final query = select(weighments)..where((w) => w.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<Weighment?> getWeighmentByBillNumber(String billNumber) async {
    final query = select(weighments)..where((w) => w.billNumber.equals(billNumber));
    return query.getSingleOrNull();
  }

  Future<int> getWeighmentCount() async {
    final count = weighments.id.count();
    final query = selectOnly(weighments)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<String> generateNextBillNumber() async {
    final count = await getWeighmentCount();
    final nextNumber = count + 1;
    return 'WB-${nextNumber.toString().padLeft(5, '0')}';
  }

  Future<List<Weighment>> searchBills({
    String? billNumber,
    String? vehicleNumber,
    String? partyName,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    final query = select(weighments);

    if (billNumber != null && billNumber.isNotEmpty) {
      query.where((w) => w.billNumber.like('%$billNumber%'));
    }

    if (startDate != null) {
      query.where((w) => w.createdAt.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      query.where((w) => w.createdAt.isSmallerOrEqualValue(endDate));
    }

    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    query.limit(limit);

    return query.get();
  }

  Future<int> deleteWeighment(int id) async {
    return (delete(weighments)..where((w) => w.id.equals(id))).go();
  }
}
