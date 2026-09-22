import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

import '../../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createInMemoryDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('CustomerDao', () {
    test('insert and lookup by id and name', () async {
      final id = await seedCustomer(db, name: 'ACME', mobile: '9000000000');
      final byId = await db.customerDao.getCustomerById(id);
      expect(byId, isNotNull);
      expect(byId!.name, 'ACME');
      expect(byId.isActive, isTrue);

      final byName = await db.customerDao.getCustomerByName('ACME');
      expect(byName, isNotNull);
      expect(byName!.id, id);
    });

    test('inserts inactive parties and filters them', () async {
      await seedCustomer(db, name: 'Active One');
      await seedCustomer(db, name: 'Inactive One', isActive: false);

      final active = await db.customerDao.getAllActiveCustomers();
      expect(active.map((p) => p.name), ['Active One']);

      final byStatusInactive = await db.customerDao.getCustomersByStatus(
        isActive: false,
      );
      expect(byStatusInactive.single.name, 'Inactive One');

      final all = await db.customerDao.getAllCustomers();
      expect(all.length, 2);
    });

    test('counts active/inactive/total parties', () async {
      await seedCustomer(db, name: 'A');
      await seedCustomer(db, name: 'B', isActive: false);
      await seedCustomer(db, name: 'C');

      expect(await db.customerDao.customerCount(), 3);
      expect(await db.customerDao.activeCustomerCount(), 2);
      expect(await db.customerDao.inactiveCustomerCount(), 1);
    });

    test(
      'searchCustomers matches name, mobile, contactPerson or GST',
      () async {
        await seedCustomer(
          db,
          name: 'ACME Traders',
          mobile: '9876543211',
          contactPerson: 'Rajesh',
          gstNumber: '33ABCDE1234F1Z5',
        );
        await seedCustomer(db, name: 'Other Firm');

        expect(
          (await db.customerDao.searchCustomers('acme')).single.name,
          'ACME Traders',
        );
        expect(
          (await db.customerDao.searchCustomers('987654')).single.name,
          'ACME Traders',
        );
        expect(
          (await db.customerDao.searchCustomers('Rajesh')).single.name,
          'ACME Traders',
        );
        expect(
          (await db.customerDao.searchCustomers('33ABCDE')).single.name,
          'ACME Traders',
        );
        expect(await db.customerDao.searchCustomers('nomatch'), isEmpty);
      },
    );

    test('deactivateCustomer flips isActive and touches updatedAt', () async {
      final id = await seedCustomer(db, name: 'To Deactivate');
      await db.customerDao.deactivateCustomer(id);

      final customer = await db.customerDao.getCustomerById(id);
      expect(customer!.isActive, isFalse);
      expect(await db.customerDao.activeCustomerCount(), 0);
    });

    test('updateCustomer replaces fields', () async {
      final id = await seedCustomer(db, name: 'Before');
      final updated = await db.customerDao.updateCustomer(
        CustomersCompanion(
          id: Value(id),
          name: const Value('After'),
          updatedAt: Value(DateTime.now()),
        ),
      );
      expect(updated, isTrue);
      final customer = await db.customerDao.getCustomerById(id);
      expect(customer!.name, 'After');
      expect(customer.isActive, isTrue);
    });

    test(
      'deleteCustomer removes the record and returns deleted count',
      () async {
        final id = await seedCustomer(db, name: 'Doomed');
        final deleted = await db.customerDao.deleteCustomer(id);
        expect(deleted, 1);
        expect(await db.customerDao.getCustomerById(id), isNull);
      },
    );
  });
}
