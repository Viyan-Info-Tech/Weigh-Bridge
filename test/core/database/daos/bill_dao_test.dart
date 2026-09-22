import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

import '../../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late SeededRefs refs;

  setUp(() async {
    db = createInMemoryDatabase();
    refs = await seedParents(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insert(
    String billNumber, {
    DateTime? createdAt,
    double firstWeightKg = 20000,
    double? secondWeightKg = 5000,
    double vehicleCharge = 100,
    double amount = 100,
    String paymentMode = 'cash',
  }) {
    return seedWeighment(
      db,
      customerId: refs.customerId,
      materialId: refs.materialId,
      billNumber: billNumber,
      paymentMode: paymentMode,
      firstWeightKg: firstWeightKg,
      secondWeightKg: secondWeightKg,
      vehicleCharge: vehicleCharge,
      amount: amount,
      createdAt: createdAt,
    );
  }

  group('BillDao', () {
    test('insertWeighment sets sensible defaults', () async {
      final id = await insert('WB-00001');
      final w = await db.billDao.getWeighmentById(id);
      expect(w, isNotNull);
      final bill = w!;
      expect(bill.amount, 100);
      expect(bill.vehicleCharge, 100);
      expect(bill.weightUnit, 'ton');
      expect(bill.firstWeightType, 'GROSS');
      expect(bill.createdAt, isNotNull);
      expect(bill.updatedAt, isNotNull);
    });

    test('getWeighmentByBillNumber returns the matching record', () async {
      await insert('WB-00001');
      final w = await db.billDao.getWeighmentByBillNumber('WB-00001');
      expect(w, isNotNull);
      expect(w!.customerId, refs.customerId);
      expect(w.vehicleNumber, 'TN31SEED01');
      expect(w.materialId, refs.materialId);
    });

    test(
      'getRecentBills returns only bills of the given day, newest first',
      () async {
        final today = DateTime.now();
        await insert(
          'WB-00001',
          createdAt: today.subtract(const Duration(hours: 5)),
        );
        await insert('WB-00002', createdAt: today);
        await insert(
          'WB-00003',
          createdAt: today.subtract(const Duration(days: 1)),
        );

        final bills = await db.billDao.getRecentBills(date: today);
        expect(bills.map((b) => b.billNumber), ['WB-00002', 'WB-00001']);
      },
    );

    test('getRecentBills applies the limit', () async {
      final now = DateTime.now();
      for (var i = 1; i <= 5; i++) {
        await insert(
          'WB-0000$i',
          createdAt: now.subtract(Duration(minutes: i)),
        );
      }
      final limited = await db.billDao.getRecentBills(limit: 3);
      expect(limited.length, 3);
    });

    test('getRecentBillsByDateRange includes the boundary days', () async {
      await insert('WB-00001', createdAt: DateTime(2026, 9, 1, 8, 0));
      await insert('WB-00002', createdAt: DateTime(2026, 9, 13, 22, 0));
      await insert('WB-00003', createdAt: DateTime(2026, 9, 15, 0, 0));

      final bills = await db.billDao.getRecentBillsByDateRange(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 13),
      );
      expect(bills.map((b) => b.billNumber).toSet(), {'WB-00001', 'WB-00002'});
    });

    test('generateNextBillNumber starts at WB-00001 and increments', () async {
      expect(await db.billDao.generateNextBillNumber(), 'WB-00001');
      await insert('WB-00001');
      expect(await db.billDao.generateNextBillNumber(), 'WB-00002');
      await insert('WB-00002');
      await insert('WB-00003');
      expect(await db.billDao.generateNextBillNumber(), 'WB-00004');
    });

    test('generateNextBillNumber skips missing numbers', () async {
      await insert('WB-00010');
      expect(await db.billDao.generateNextBillNumber(), 'WB-00011');
    });

    test(
      'searchBills filters by bill number fragment and date range',
      () async {
        await insert('WB-00001', createdAt: DateTime(2026, 9, 10, 9, 0));
        await insert('WB-00002', createdAt: DateTime(2026, 9, 11, 9, 0));

        final byFragment = await db.billDao.searchBills(billNumber: '00002');
        expect(byFragment.single.billNumber, 'WB-00002');

        final byRange = await db.billDao.searchBills(
          startDate: DateTime(2026, 9, 11),
          endDate: DateTime(2026, 9, 12),
        );
        expect(byRange.single.billNumber, 'WB-00002');
      },
    );

    test('updateWeighment modifies the stored record', () async {
      final id = await insert('WB-00001', secondWeightKg: null);
      final updated = await db.billDao.updateWeighment(
        id,
        WeighmentsCompanion(
          secondWeightKg: const Value(5000),
          netWeightKg: const Value(15000),
          amount: const Value(250),
          updatedAt: Value(DateTime.now()),
        ),
      );
      expect(updated, 1);
      final w = await db.billDao.getWeighmentById(id);
      expect(w!.amount, 250);
      expect(w.netWeightKg, 15000);
    });

    test('deleteWeighment removes the record', () async {
      final id = await insert('WB-00001');
      final deleted = await db.billDao.deleteWeighment(id);
      expect(deleted, 1);
      expect(await db.billDao.getWeighmentById(id), isNull);
    });
  });
}
