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

  Future<int> updateWeighment(int id, WeighmentsCompanion entry) async {
    return (update(weighments)..where((w) => w.id.equals(id))).write(entry);
  }

  Future<List<Weighment>> getRecentBills({DateTime? date, int? limit}) async {
    final day = date ?? DateTime.now();
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final query = select(weighments)
      ..where(
        (w) =>
            w.createdAt.isBiggerOrEqualValue(start) &
            w.createdAt.isSmallerThanValue(end),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<List<Weighment>> getRecentBillsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    final query = select(weighments)
      ..where(
        (w) =>
            w.createdAt.isBiggerOrEqualValue(start) &
            w.createdAt.isSmallerOrEqualValue(end),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<Weighment?> getWeighmentById(int id) async {
    final query = select(weighments)..where((w) => w.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<Weighment?> getWeighmentByBillNumber(String billNumber) async {
    final query = select(weighments)
      ..where((w) => w.billNumber.equals(billNumber));
    return query.getSingleOrNull();
  }

  Future<String> generateNextBillNumber() async {
    final maxBill = await customSelect(
      "SELECT MAX(CAST(SUBSTR(bill_number, 4) AS INTEGER)) as max_num FROM weighments",
    ).getSingleOrNull();
    final maxNum = maxBill?.data['max_num'] as int? ?? 0;
    final nextNumber = maxNum + 1;
    return 'WB-${nextNumber.toString().padLeft(5, '0')}';
  }

  Future<List<Weighment>> searchBills({
    String? billNumber,
    String? vehicleNumber,
    String? customerName,
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
