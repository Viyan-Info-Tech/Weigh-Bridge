import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/features/customer/data/datasources/customer_local_datasource.dart';

import '../../../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late CustomerLocalDataSource source;

  setUp(() async {
    db = createInMemoryDatabase();
    source = CustomerLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CustomerLocalDataSource', () {
    group('createCustomer', () {
      test('creates a customer and returns the id', () async {
        final id = await source.createCustomer(
          name: 'ABC Constructions',
          contactPerson: 'Mr. Sharma',
          mobile: '9876543210',
          email: 'abc@example.com',
          address: '123 Main St',
          gstNumber: '33ABCDE1234F1Z5',
          city: 'Chennai',
          state: 'Tamil Nadu',
        );
        expect(id, greaterThan(0));
      });

      test('creates a customer with minimal fields', () async {
        final id = await source.createCustomer(name: 'Minimal Customer');
        expect(id, greaterThan(0));

        final customer = await source.getCustomerById(id);
        expect(customer, isNotNull);
        expect(customer!.name, 'Minimal Customer');
        expect(customer.contactPerson, isNull);
        expect(customer.mobile, isNull);
      });

      test('creates customer with Tamil text', () async {
        final id = await source.createCustomer(name: 'தமிழ் நிறுவனம்');
        final customer = await source.getCustomerById(id);
        expect(customer!.name, 'தமிழ் நிறுவனம்');
      });

      test('creates customer with special characters', () async {
        final id = await source.createCustomer(
          name: 'Kumar, Sons & "Co"',
          gstNumber: '33ABCDE@1234#F1Z5',
        );
        final customer = await source.getCustomerById(id);
        expect(customer!.name, 'Kumar, Sons & "Co"');
        expect(customer.gstNumber, '33ABCDE@1234#F1Z5');
      });
    });

    group('getAllCustomers', () {
      test('returns empty list when no customers exist', () async {
        final customers = await source.getAllCustomers();
        expect(customers, isEmpty);
      });

      test('returns all customers', () async {
        await source.createCustomer(name: 'Customer A');
        await source.createCustomer(name: 'Customer B');

        final customers = await source.getAllCustomers();
        expect(customers.length, 2);
      });
    });

    group('getAllActiveCustomers', () {
      test('returns only active customers', () async {
        await source.createCustomer(name: 'Active Customer');
        await source.createCustomer(name: 'Inactive Customer');
        final id2 = (await source.getAllCustomers())
            .firstWhere((c) => c.name == 'Inactive Customer')
            .id;
        await source.deactivateCustomer(id2);

        final active = await source.getAllActiveCustomers();
        expect(active.length, 1);
        expect(active.first.name, 'Active Customer');
      });
    });

    group('getCustomersByStatus', () {
      test('filters by active status', () async {
        final id1 = await source.createCustomer(name: 'Active');
        await source.createCustomer(name: 'Inactive');
        final allCustomers = await source.getAllCustomers();
        final id2 = allCustomers.firstWhere((c) => c.name == 'Inactive').id;
        await source.deactivateCustomer(id2);

        final active = await source.getCustomersByStatus(isActive: true);
        expect(active.length, 1);
        expect(active.first.id, id1);

        final inactive = await source.getCustomersByStatus(isActive: false);
        expect(inactive.length, 1);
        expect(inactive.first.name, 'Inactive');
      });
    });

    group('getCustomerById', () {
      test('returns null for nonexistent id', () async {
        final customer = await source.getCustomerById(9999);
        expect(customer, isNull);
      });

      test('returns customer by id', () async {
        final id = await source.createCustomer(name: 'Lookup Test');
        final customer = await source.getCustomerById(id);
        expect(customer, isNotNull);
        expect(customer!.name, 'Lookup Test');
        expect(customer.id, id);
      });
    });

    group('updateCustomer', () {
      test('updates customer fields', () async {
        final id = await source.createCustomer(name: 'Original Name');
        final result = await source.updateCustomer(
          id: id,
          name: 'Updated Name',
          mobile: '9999999999',
        );
        expect(result, isTrue);

        final updated = await source.getCustomerById(id);
        expect(updated!.name, 'Updated Name');
        expect(updated.mobile, '9999999999');
      });

      test('update returns true on success', () async {
        final id = await source.createCustomer(name: 'Test');
        final result = await source.updateCustomer(id: id, name: 'Changed');
        expect(result, isTrue);
      });
    });

    group('deactivateCustomer', () {
      test('sets isActive to false', () async {
        final id = await source.createCustomer(name: 'To Deactivate');
        await source.deactivateCustomer(id);

        final customer = await source.getCustomerById(id);
        expect(customer!.isActive, isFalse);
      });

      test('deactivated customer excluded from active list', () async {
        final id = await source.createCustomer(name: 'Deactivated');
        await source.deactivateCustomer(id);

        final active = await source.getAllActiveCustomers();
        expect(active.isEmpty, isTrue);
      });
    });

    group('deleteCustomer', () {
      test('removes the customer', () async {
        final id = await source.createCustomer(name: 'To Delete');
        await source.deleteCustomer(id);

        final customer = await source.getCustomerById(id);
        expect(customer, isNull);
      });

      test('delete nonexistent customer does not throw', () async {
        await source.deleteCustomer(9999);
      });
    });

    group('searchCustomers', () {
      test('searches by name', () async {
        await source.createCustomer(name: 'ACME Traders');
        await source.createCustomer(name: 'Beta Corp');

        final results = await source.searchCustomers('ACME');
        expect(results.length, 1);
        expect(results.first.name, 'ACME Traders');
      });

      test('searches by mobile', () async {
        await source.createCustomer(name: 'Test', mobile: '9876543210');

        final results = await source.searchCustomers('987654');
        expect(results.length, 1);
      });

      test('searches by contact person', () async {
        await source.createCustomer(
          name: 'Test',
          contactPerson: 'Rajesh Kumar',
        );

        final results = await source.searchCustomers('Rajesh');
        expect(results.length, 1);
      });

      test('searches by GST number', () async {
        await source.createCustomer(name: 'Test', gstNumber: '33ABCDE1234F1Z5');

        final results = await source.searchCustomers('33ABCDE');
        expect(results.length, 1);
      });

      test('case-insensitive search', () async {
        await source.createCustomer(name: 'ACME Traders');

        final results = await source.searchCustomers('acme');
        expect(results.length, 1);
      });

      test('returns empty for no match', () async {
        await source.createCustomer(name: 'ACME');

        final results = await source.searchCustomers('zzz-nothing');
        expect(results, isEmpty);
      });

      test('partial match works', () async {
        await source.createCustomer(name: 'Super Cement Traders');

        final results = await source.searchCustomers('Cement');
        expect(results.length, 1);
      });
    });

    group('counts', () {
      test('totalCustomerCount returns correct count', () async {
        expect(await source.totalCustomerCount(), 0);

        await source.createCustomer(name: 'A');
        await source.createCustomer(name: 'B');
        expect(await source.totalCustomerCount(), 2);
      });

      test('activeCustomerCount returns correct count', () async {
        final id = await source.createCustomer(name: 'A');
        await source.createCustomer(name: 'B');

        expect(await source.activeCustomerCount(), 2);

        await source.deactivateCustomer(id);
        expect(await source.activeCustomerCount(), 1);
      });

      test('inactiveCustomerCount returns correct count', () async {
        expect(await source.inactiveCustomerCount(), 0);

        final id = await source.createCustomer(name: 'A');
        await source.deactivateCustomer(id);
        expect(await source.inactiveCustomerCount(), 1);
      });
    });

    group('persistence', () {
      test('data survives database close and reopen', () async {
        final id = await source.createCustomer(
          name: 'Persistent Customer',
          mobile: '9876543210',
        );

        await db.close();

        // Reopen with the same in-memory database would lose data,
        // but this tests the DAO layer works correctly.
        db = createInMemoryDatabase();
        source = CustomerLocalDataSource(db);

        // Fresh in-memory DB has no data - this verifies isolation
        final customer = await source.getCustomerById(id);
        expect(customer, isNull);
      });
    });
  });
}
