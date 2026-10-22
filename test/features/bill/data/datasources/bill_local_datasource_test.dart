import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart' hide Weighment;
import 'package:weighbridge/features/bill/data/datasources/bill_local_datasource.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';

import '../../../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late BillLocalDataSource source;

  setUp(() async {
    db = createInMemoryDatabase();
    source = BillLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  Weighment buildEntity({
    String billNumber = 'WB-00001',
    double firstWeightKg = 20000,
    double? secondWeightKg = 5000,
    double? netWeightKg,
    double? charges,
  }) {
    return Weighment(
      id: 0,
      billNumber: billNumber,
      vehicleNumber: 'TN31SEED01',
      firstWeightKg: firstWeightKg,
      secondWeightKg: secondWeightKg,
      netWeightKg: netWeightKg,
      charges: charges,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('BillLocalDataSource', () {
    test('saveWeighment persists every field', () async {
      final id = await source.saveWeighment(buildEntity());
      final stored = await db.billDao.getWeighmentById(id);
      expect(stored, isNotNull);
      expect(stored!.billNumber, 'WB-00001');
      expect(stored.vehicleNumber, 'TN31SEED01');
      expect(stored.firstWeightKg, 20000);
      expect(stored.secondWeightKg, 5000);
      expect(stored.weightUnit, 'ton');
    });

    test('getRecentBills and by-id lookups map entities', () async {
      final id = await source.saveWeighment(buildEntity());
      await source.saveWeighment(buildEntity(billNumber: 'WB-00002'));

      final today = await source.getRecentBills();
      expect(today, hasLength(2));

      final byId = await source.getWeighmentById(id);
      expect(byId!.firstWeightKg, 20000);

      final byBill = await source.getWeighmentByBillNumber('WB-00002');
      expect(byBill, isNotNull);
      expect(byBill!.billNumber, 'WB-00002');
    });

    test('getRecentBillsByDateRange filters inclusively', () async {
      await source.saveWeighment(buildEntity());
      final future = await source.getRecentBillsByDateRange(
        startDate: DateTime(2000),
        endDate: DateTime(2001),
      );
      expect(future, isEmpty);
    });

    test('updateWeighment replaces weights', () async {
      final id = await source.saveWeighment(
        buildEntity(billNumber: 'WB-00001'),
      );
      await source.updateWeighment(
        id,
        buildEntity(
          billNumber: 'WB-00001',
          firstWeightKg: 25000,
          secondWeightKg: 8000,
          netWeightKg: 17000,
        ),
      );

      final updated = await source.getWeighmentById(id);
      expect(updated!.firstWeightKg, 25000);
      expect(updated.secondWeightKg, 8000);
      expect(updated.netWeightKg, 17000);
    });

    test('self-heals legacy zero-first-weight rows into TARE', () async {
      final id = await seedWeighment(
        db,
        billNumber: 'WB-00001',
        firstWeightKg: 0,
        secondWeightKg: 5000,
        secondWeightType: 'TARE',
      );

      final entity = await source.getWeighmentById(id);
      expect(entity!.firstWeightType, 'TARE');
      expect(entity.firstWeightKg, 5000);
      expect(entity.secondWeightKg, isNull);
      expect(entity.secondWeightType, isNull);
    });

    test(
      'generateNextBillNumber honours the configured bill settings',
      () async {
        await db.appSettingsDao.updateSettings(
          const AppSettingsCompanion(
            billPrefix: Value('RM'),
            billNumberDigits: Value(3),
          ),
        );
        expect(await source.generateNextBillNumber(), 'RM-001');

        await source.saveWeighment(buildEntity(billNumber: 'RM-001'));
        expect(await source.generateNextBillNumber(), 'RM-002');
      },
    );

    test('deleteWeighment removes the record', () async {
      final id = await source.saveWeighment(buildEntity());
      final deleted = await source.deleteWeighment(id);
      expect(deleted, 1);
      expect(await source.getWeighmentById(id), isNull);
    });

    test('saveWeighment persists a decimal charge exactly as entered', () async {
      final id = await source.saveWeighment(
        buildEntity(billNumber: 'WB-00001', charges: 250.50),
      );
      final stored = await source.getWeighmentById(id);
      expect(stored!.charges, 250.50);
    });

    test('saveWeighment persists a zero charge (not null)', () async {
      final id = await source.saveWeighment(
        buildEntity(billNumber: 'WB-00001', charges: 0),
      );
      final stored = await source.getWeighmentById(id);
      expect(stored!.charges, 0);
    });

    test('legacy rows without charges read back as null', () async {
      final id = await seedWeighment(db, billNumber: 'WB-00001');
      final stored = await source.getWeighmentById(id);
      expect(stored!.charges, isNull);
    });

    test('updateWeighment can change the charge', () async {
      final id = await source.saveWeighment(
        buildEntity(billNumber: 'WB-00001', charges: 100),
      );
      await source.updateWeighment(
        id,
        buildEntity(billNumber: 'WB-00001', charges: 1000),
      );

      final updated = await source.getWeighmentById(id);
      expect(updated!.charges, 1000);
    });
  });
}
