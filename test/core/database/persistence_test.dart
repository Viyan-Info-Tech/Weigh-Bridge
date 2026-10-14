import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

import '../../support/test_database.dart';

void main() {
  group('Database persistence', () {
    test('weighment data persists across DAO operations', () async {
      await withDatabase((db) async {
        // Create
        final id = await db.billDao.insertWeighment(
          WeighmentsCompanion.insert(
            billNumber: 'WB-PERSIST-001',
            vehicleNumber: 'TN31PER001',
            firstWeightKg: 20000,
            firstWeightType: const Value('GROSS'),
            secondWeightKg: const Value(5000.0),
            secondWeightType: const Value('TARE'),
            netWeightKg: const Value(15000.0),
          ),
        );
        expect(id, greaterThan(0));

        // Read
        final weighment = await db.billDao.getWeighmentById(id);
        expect(weighment, isNotNull);
        expect(weighment!.billNumber, 'WB-PERSIST-001');
        expect(weighment.firstWeightKg, 20000);
        expect(weighment.secondWeightKg, 5000);

        // Update
        await db.billDao.updateWeighment(
          id,
          const WeighmentsCompanion(remarks: Value('Updated remarks')),
        );
        final updated = await db.billDao.getWeighmentById(id);
        expect(updated!.remarks, 'Updated remarks');

        // Delete
        final deleted = await db.billDao.deleteWeighment(id);
        expect(deleted, 1);
        expect(await db.billDao.getWeighmentById(id), isNull);
      });
    });

    test('settings persist across operations', () async {
      await withDatabase((db) async {
        // Get default settings
        final settings = await db.appSettingsDao.getSettings();
        expect(settings.billPrefix, 'WB');

        // Update
        await db.appSettingsDao.updateSettings(
          const AppSettingsCompanion(
            billPrefix: Value('RM'),
            businessName: Value('Custom Business'),
          ),
        );

        final updated = await db.appSettingsDao.getSettings();
        expect(updated.billPrefix, 'RM');
        expect(updated.businessName, 'Custom Business');
      });
    });

    test('weighment lookup by bill number works', () async {
      await withDatabase((db) async {
        await db.billDao.insertWeighment(
          WeighmentsCompanion.insert(
            billNumber: 'WB-LOOKUP-001',
            vehicleNumber: 'TN31AB1234',
            firstWeightKg: 10000,
          ),
        );

        final found = await db.billDao.getWeighmentByBillNumber(
          'WB-LOOKUP-001',
        );
        expect(found, isNotNull);
        expect(found!.billNumber, 'WB-LOOKUP-001');

        final notFound = await db.billDao.getWeighmentByBillNumber(
          'WB-NONEXISTENT',
        );
        expect(notFound, isNull);
      });
    });

    test('bill number generation increments correctly', () async {
      await withDatabase((db) async {
        expect(await db.billDao.generateNextBillNumber(), 'WB-00001');

        await db.billDao.insertWeighment(
          WeighmentsCompanion.insert(
            billNumber: 'WB-00001',
            vehicleNumber: 'TN31AB1234',
            firstWeightKg: 10000,
          ),
        );

        expect(await db.billDao.generateNextBillNumber(), 'WB-00002');
      });
    });
  });
}
