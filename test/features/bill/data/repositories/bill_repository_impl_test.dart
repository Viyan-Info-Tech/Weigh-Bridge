import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/data/datasources/bill_local_datasource.dart';
import 'package:weighbridge/features/bill/data/repositories/bill_repository_impl.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';

class MockBillLocalDataSource extends Mock implements BillLocalDataSource {}

void main() {
  late MockBillLocalDataSource localDataSource;
  late BillRepositoryImpl repository;

  final weighment = Weighment(
    id: 0,
    billNumber: 'WB-00001',
    customerId: 1,
    vehicleNumber: 'TN31AB1234',
    materialId: 2,
    grossWeightKg: 20000,
    tareWeightKg: 5000,
    createdAt: DateTime(2026, 9, 21, 10, 30),
    updatedAt: DateTime(2026, 9, 21, 10, 30),
  );

  setUp(() {
    localDataSource = MockBillLocalDataSource();
    repository = BillRepositoryImpl(localDataSource: localDataSource);
  });

  test(
    'saveWeighment delegates the entity and returns the generated id',
    () async {
      when(
        () => localDataSource.saveWeighment(weighment),
      ).thenAnswer((_) async => 9);

      final id = await repository.saveWeighment(weighment);

      expect(id, 9);
      verify(() => localDataSource.saveWeighment(weighment)).called(1);
    },
  );

  test('updateWeighment delegates the id and entity', () async {
    when(
      () => localDataSource.updateWeighment(9, weighment),
    ).thenAnswer((_) async {});

    await repository.updateWeighment(9, weighment);

    verify(() => localDataSource.updateWeighment(9, weighment)).called(1);
  });

  test('getRecentBills delegates date and limit arguments', () async {
    final date = DateTime(2026, 9, 21);
    when(
      () => localDataSource.getRecentBills(date: date, limit: 10),
    ).thenAnswer((_) async => [weighment]);

    final result = await repository.getRecentBills(date: date, limit: 10);

    expect(result, [weighment]);
    verify(
      () => localDataSource.getRecentBills(date: date, limit: 10),
    ).called(1);
  });

  test(
    'getRecentBillsByDateRange delegates the inclusive range and limit',
    () async {
      final start = DateTime(2026, 9, 20);
      final end = DateTime(2026, 9, 21);
      when(
        () => localDataSource.getRecentBillsByDateRange(
          startDate: start,
          endDate: end,
          limit: 5,
        ),
      ).thenAnswer((_) async => [weighment]);

      final result = await repository.getRecentBillsByDateRange(
        startDate: start,
        endDate: end,
        limit: 5,
      );

      expect(result, [weighment]);
      verify(
        () => localDataSource.getRecentBillsByDateRange(
          startDate: start,
          endDate: end,
          limit: 5,
        ),
      ).called(1);
    },
  );

  test(
    'lookup and generation methods delegate without changing their results',
    () async {
      when(
        () => localDataSource.getWeighmentById(9),
      ).thenAnswer((_) async => weighment);
      when(
        () => localDataSource.getWeighmentByBillNumber('WB-00001'),
      ).thenAnswer((_) async => weighment);
      when(
        () => localDataSource.generateNextBillNumber(),
      ).thenAnswer((_) async => 'WB-00002');
      when(() => localDataSource.deleteWeighment(9)).thenAnswer((_) async => 1);

      expect(await repository.getWeighmentById(9), same(weighment));
      expect(
        await repository.getWeighmentByBillNumber('WB-00001'),
        same(weighment),
      );
      expect(await repository.generateNextBillNumber(), 'WB-00002');
      expect(await repository.deleteWeighment(9), 1);

      verify(() => localDataSource.getWeighmentById(9)).called(1);
      verify(
        () => localDataSource.getWeighmentByBillNumber('WB-00001'),
      ).called(1);
      verify(() => localDataSource.generateNextBillNumber()).called(1);
      verify(() => localDataSource.deleteWeighment(9)).called(1);
    },
  );
}
