import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/customer/data/datasources/customer_local_datasource.dart';
import 'package:weighbridge/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:weighbridge/features/customer/domain/entities/customer.dart';

class MockCustomerLocalDataSource extends Mock
    implements CustomerLocalDataSource {}

void main() {
  late MockCustomerLocalDataSource mockDataSource;
  late CustomerRepositoryImpl repository;

  final now = DateTime(2026, 9, 21);

  final testCustomer = Customer(
    id: 1,
    name: 'Test Customer',
    contactPerson: 'John',
    mobile: '9876543210',
    email: 'test@example.com',
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockDataSource = MockCustomerLocalDataSource();
    repository = CustomerRepositoryImpl(mockDataSource);
  });

  group('CustomerRepositoryImpl', () {
    group('getAllCustomers', () {
      test('delegates to datasource', () async {
        when(
          () => mockDataSource.getAllCustomers(),
        ).thenAnswer((_) async => [testCustomer]);

        final result = await repository.getAllCustomers();

        expect(result, [testCustomer]);
        verify(() => mockDataSource.getAllCustomers()).called(1);
      });

      test('returns empty list when datasource returns empty', () async {
        when(
          () => mockDataSource.getAllCustomers(),
        ).thenAnswer((_) async => []);

        final result = await repository.getAllCustomers();
        expect(result, isEmpty);
      });
    });

    group('getAllActiveCustomers', () {
      test('delegates to datasource', () async {
        when(
          () => mockDataSource.getAllActiveCustomers(),
        ).thenAnswer((_) async => [testCustomer]);

        final result = await repository.getAllActiveCustomers();
        expect(result, [testCustomer]);
        verify(() => mockDataSource.getAllActiveCustomers()).called(1);
      });
    });

    group('getCustomersByStatus', () {
      test('delegates to datasource with isActive parameter', () async {
        when(
          () => mockDataSource.getCustomersByStatus(isActive: true),
        ).thenAnswer((_) async => [testCustomer]);

        final result = await repository.getCustomersByStatus(isActive: true);
        expect(result, [testCustomer]);
        verify(
          () => mockDataSource.getCustomersByStatus(isActive: true),
        ).called(1);
      });
    });

    group('getCustomerById', () {
      test('returns customer when found', () async {
        when(
          () => mockDataSource.getCustomerById(1),
        ).thenAnswer((_) async => testCustomer);

        final result = await repository.getCustomerById(1);
        expect(result, testCustomer);
      });

      test('returns null when not found', () async {
        when(
          () => mockDataSource.getCustomerById(999),
        ).thenAnswer((_) async => null);

        final result = await repository.getCustomerById(999);
        expect(result, isNull);
      });
    });

    group('createCustomer', () {
      test('delegates to datasource and returns id', () async {
        when(
          () => mockDataSource.createCustomer(
            name: 'New Customer',
            contactPerson: 'Jane',
            mobile: '9999999999',
          ),
        ).thenAnswer((_) async => 42);

        final id = await repository.createCustomer(
          name: 'New Customer',
          contactPerson: 'Jane',
          mobile: '9999999999',
        );

        expect(id, 42);
        verify(
          () => mockDataSource.createCustomer(
            name: 'New Customer',
            contactPerson: 'Jane',
            mobile: '9999999999',
          ),
        ).called(1);
      });
    });

    group('updateCustomer', () {
      test('delegates to datasource', () async {
        when(
          () => mockDataSource.updateCustomer(id: 1, name: 'Updated'),
        ).thenAnswer((_) async => true);

        final result = await repository.updateCustomer(id: 1, name: 'Updated');

        expect(result, isTrue);
        verify(
          () => mockDataSource.updateCustomer(id: 1, name: 'Updated'),
        ).called(1);
      });
    });

    group('deactivateCustomer', () {
      test('delegates to datasource', () async {
        when(
          () => mockDataSource.deactivateCustomer(1),
        ).thenAnswer((_) async {});

        await repository.deactivateCustomer(1);
        verify(() => mockDataSource.deactivateCustomer(1)).called(1);
      });
    });

    group('deleteCustomer', () {
      test('delegates to datasource', () async {
        when(() => mockDataSource.deleteCustomer(1)).thenAnswer((_) async {});

        await repository.deleteCustomer(1);
        verify(() => mockDataSource.deleteCustomer(1)).called(1);
      });
    });

    group('searchCustomers', () {
      test('delegates to datasource with query', () async {
        when(
          () => mockDataSource.searchCustomers('ACME'),
        ).thenAnswer((_) async => [testCustomer]);

        final result = await repository.searchCustomers('ACME');
        expect(result, [testCustomer]);
        verify(() => mockDataSource.searchCustomers('ACME')).called(1);
      });
    });

    group('counts', () {
      test('totalCustomerCount delegates', () async {
        when(
          () => mockDataSource.totalCustomerCount(),
        ).thenAnswer((_) async => 10);

        expect(await repository.totalCustomerCount(), 10);
      });

      test('activeCustomerCount delegates', () async {
        when(
          () => mockDataSource.activeCustomerCount(),
        ).thenAnswer((_) async => 8);

        expect(await repository.activeCustomerCount(), 8);
      });

      test('inactiveCustomerCount delegates', () async {
        when(
          () => mockDataSource.inactiveCustomerCount(),
        ).thenAnswer((_) async => 2);

        expect(await repository.inactiveCustomerCount(), 2);
      });
    });
  });
}
