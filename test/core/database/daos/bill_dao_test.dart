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

  group('BillDao bill number allocation', () {
    WeighmentsCompanion buildRow(String billNumber) {
      return WeighmentsCompanion.insert(
        billNumber: billNumber,
        customerId: refs.customerId,
        vehicleNumber: 'TN31SEED01',
        materialId: refs.materialId,
        paymentMode: 'Cash',
        firstWeightKg: 20000,
      );
    }

    test('peekNextBillNumber honours prefix, digits and starting number', () async {
      expect(
        await db.billDao.peekNextBillNumber(
          prefix: 'WB',
          digits: 5,
          startingNumber: 1,
        ),
        'WB-00001',
      );
      await insert('WB-00001');
      expect(
        await db.billDao.peekNextBillNumber(
          prefix: 'WB',
          digits: 5,
          startingNumber: 1,
        ),
        'WB-00002',
      );
      // A different prefix has its own sequence.
      expect(
        await db.billDao.peekNextBillNumber(
          prefix: 'INV',
          digits: 4,
          startingNumber: 500,
        ),
        'INV-0500',
      );
    });

    test(
      'peekNextBillNumber rejects an exhausted or invalid sequence',
      () async {
        await insert('WB-00099');
        expect(
          () => db.billDao.peekNextBillNumber(
            prefix: 'WB',
            digits: 2,
            startingNumber: 1,
          ),
          throwsStateError,
        );
        expect(
          () => db.billDao.peekNextBillNumber(
            prefix: 'wb',
            digits: 5,
          ),
          throwsArgumentError,
        );
      },
    );

    test('insert allocates and stores the number it reports', () async {
      final first = await db.billDao.insertWeighmentWithNextBillNumber(
        buildRow,
        prefix: 'WB',
        digits: 5,
        startingNumber: 1,
      );
      expect(first.billNumber, 'WB-00001');

      final second = await db.billDao.insertWeighmentWithNextBillNumber(
        buildRow,
        prefix: 'WB',
        digits: 5,
        startingNumber: 1,
      );
      expect(second.billNumber, 'WB-00002');

      final stored = await db.billDao.getWeighmentById(second.id);
      expect(stored!.billNumber, 'WB-00002');
    });

    test(
      'concurrent saves each receive a distinct number and none are lost',
      () async {
        // The reported bug: two overlapping inserts both generated the same
        // number, so the second failed the UNIQUE constraint.
        final results = await Future.wait([
          for (var i = 0; i < 5; i++)
            db.billDao.insertWeighmentWithNextBillNumber(
              buildRow,
              prefix: 'WB',
              digits: 5,
              startingNumber: 1,
            ),
        ]);

        final numbers = results.map((r) => r.billNumber).toList();
        expect(numbers.toSet().length, 5, reason: 'numbers must be unique');
        expect(numbers, [
          'WB-00001',
          'WB-00002',
          'WB-00003',
          'WB-00004',
          'WB-00005',
        ]);

        final stored = await db.billDao.getRecentBills(limit: 10);
        expect(stored.length, 5);
        expect(
          stored.map((w) => w.billNumber).toSet(),
          numbers.toSet(),
          reason: 'every allocated number must be persisted',
        );
      },
    );

    test(
      'allocation continues from the highest existing number, not the count',
      () async {
        await insert('WB-00018');
        final result = await db.billDao.insertWeighmentWithNextBillNumber(
          buildRow,
          prefix: 'WB',
          digits: 5,
          startingNumber: 1,
        );
        expect(result.billNumber, 'WB-00019');
      },
    );
  });
}
