import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

import '../../support/test_database.dart';

void main() {
  group('Database persistence', () {
    test('customer data persists across DAO operations', () async {
      await withDatabase((db) async {
        // Create
        final id = await db.customerDao.insertCustomer(
          CustomersCompanion.insert(name: 'Persistent Customer'),
        );
        expect(id, greaterThan(0));

        // Read
        final customer = await db.customerDao.getCustomerById(id);
        expect(customer, isNotNull);
        expect(customer!.name, 'Persistent Customer');
        expect(customer.isActive, isTrue);

        // Update
        await db.customerDao.updateCustomer(
          CustomersCompanion(
            id: Value(id),
            name: const Value('Updated Customer'),
          ),
        );
        final updated = await db.customerDao.getCustomerById(id);
        expect(updated!.name, 'Updated Customer');

        // Deactivate
        await db.customerDao.deactivateCustomer(id);
        final deactivated = await db.customerDao.getCustomerById(id);
        expect(deactivated!.isActive, isFalse);

        // Delete
        final deleted = await db.customerDao.deleteCustomer(id);
        expect(deleted, 1);
        expect(await db.customerDao.getCustomerById(id), isNull);
      });
    });

    test('material data persists across DAO operations', () async {
      await withDatabase((db) async {
        // Create
        final id = await db.materialDao.insertMaterial(
          MaterialsCompanion.insert(code: '1', name: 'Persistent Material'),
        );
        expect(id, greaterThan(0));

        // Read
        final material = await db.materialDao.getMaterialById(id);
        expect(material, isNotNull);
        expect(material!.name, 'Persistent Material');
        expect(material.code, '1');

        // Update
        await db.materialDao.updateMaterial(
          MaterialsCompanion(
            id: Value(id),
            code: const Value('2'),
            name: const Value('Updated Material'),
            updatedAt: Value(DateTime.now()),
          ),
        );
        final updated = await db.materialDao.getMaterialById(id);
        expect(updated!.name, 'Updated Material');

        // Deactivate
        await db.materialDao.deactivateMaterial(id);
        final deactivated = await db.materialDao.getMaterialById(id);
        expect(deactivated!.isActive, isFalse);

        // Activate
        await db.materialDao.activateMaterial(id);
        final activated = await db.materialDao.getMaterialById(id);
        expect(activated!.isActive, isTrue);

        // Delete
        final deleted = await db.materialDao.deleteMaterial(id);
        expect(deleted, 1);
        expect(await db.materialDao.getMaterialById(id), isNull);
      });
    });

    test('weighment data persists across DAO operations', () async {
      await withDatabase((db) async {
        final refs = await seedParents(db);

        // Create
        final id = await db.billDao.insertWeighment(
          WeighmentsCompanion.insert(
            billNumber: 'WB-PERSIST-001',
            customerId: refs.customerId,
            vehicleNumber: 'TN31PER001',
            materialId: Value(refs.materialId),
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

    test('multiple customers can be created and queried', () async {
      await withDatabase((db) async {
        final id1 = await db.customerDao.insertCustomer(
          CustomersCompanion.insert(name: 'Customer 1'),
        );
        final id2 = await db.customerDao.insertCustomer(
          CustomersCompanion.insert(name: 'Customer 2'),
        );
        final id3 = await db.customerDao.insertCustomer(
          CustomersCompanion.insert(name: 'Customer 3'),
        );

        expect(id1, isNot(equals(id2)));
        expect(id2, isNot(equals(id3)));

        final all = await db.customerDao.getAllCustomers();
        expect(all.length, 3);

        expect(await db.customerDao.customerCount(), 3);
      });
    });

    test('customer search works correctly', () async {
      await withDatabase((db) async {
        await db.customerDao.insertCustomer(
          CustomersCompanion.insert(
            name: 'ACME Traders',
            mobile: const Value('9876543210'),
            contactPerson: const Value('Rajesh'),
          ),
        );
        await db.customerDao.insertCustomer(
          CustomersCompanion.insert(name: 'Beta Corp'),
        );

        // Search by name
        final byName = await db.customerDao.searchCustomers('ACME');
        expect(byName.length, 1);
        expect(byName.first.name, 'ACME Traders');

        // Search by mobile
        final byMobile = await db.customerDao.searchCustomers('987654');
        expect(byMobile.length, 1);

        // Search by contact person
        final byContact = await db.customerDao.searchCustomers('Rajesh');
        expect(byContact.length, 1);

        // No match
        final noMatch = await db.customerDao.searchCustomers('zzz');
        expect(noMatch, isEmpty);
      });
    });

    test('material search works correctly', () async {
      await withDatabase((db) async {
        await db.materialDao.insertMaterial(
          MaterialsCompanion.insert(code: 'PC1', name: 'Portland Cement'),
        );
        await db.materialDao.insertMaterial(
          MaterialsCompanion.insert(code: 'SR1', name: 'Steel Rebar'),
        );

        final byName = await db.materialDao.searchMaterials('Cement');
        expect(byName.length, 1);
        expect(byName.first.name, 'Portland Cement');

        final byCode = await db.materialDao.searchMaterials('SR1');
        expect(byCode.length, 1);

        final noMatch = await db.materialDao.searchMaterials('zzz');
        expect(noMatch, isEmpty);
      });
    });

    test('weighment lookup by bill number works', () async {
      await withDatabase((db) async {
        final refs = await seedParents(db);

        await db.billDao.insertWeighment(
          WeighmentsCompanion.insert(
            billNumber: 'WB-LOOKUP-001',
            customerId: refs.customerId,
            vehicleNumber: 'TN31AB1234',
            materialId: Value(refs.materialId),
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

        final refs = await seedParents(db);
        await db.billDao.insertWeighment(
          WeighmentsCompanion.insert(
            billNumber: 'WB-00001',
            customerId: refs.customerId,
            vehicleNumber: 'TN31AB1234',
            materialId: Value(refs.materialId),
            firstWeightKg: 10000,
          ),
        );

        expect(await db.billDao.generateNextBillNumber(), 'WB-00002');
      });
    });
  });
}
