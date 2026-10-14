import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/repositories/bill_repository.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';

class MockBillRepository extends Mock implements BillRepository {}

void main() {
  late MockBillRepository repository;
  late SaveBillUseCase useCase;

  final weighment = Weighment(
    id: 0,
    billNumber: 'WB-00001',
    vehicleNumber: 'TN31AB1234',
    grossWeightKg: 20000,
    tareWeightKg: 5000,
    createdAt: DateTime(2026, 9, 21, 10, 30),
    updatedAt: DateTime(2026, 9, 21, 10, 30),
  );

  setUp(() {
    repository = MockBillRepository();
    useCase = SaveBillUseCase(repository);
  });

  test('saves a weighment and returns the generated id', () async {
    when(() => repository.saveWeighment(weighment)).thenAnswer((_) async => 7);

    final id = await useCase(weighment);

    expect(id, 7);
    verify(() => repository.saveWeighment(weighment)).called(1);
  });

  test('propagates a save failure without mapping or swallowing it', () async {
    when(
      () => repository.saveWeighment(weighment),
    ).thenAnswer((_) => Future<int>.error(StateError('database unavailable')));

    await expectLater(
      () => useCase(weighment),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'database unavailable',
        ),
      ),
    );
    verify(() => repository.saveWeighment(weighment)).called(1);
  });

  test('updates a weighment by delegating the id and entity', () async {
    when(
      () => repository.updateWeighment(7, weighment),
    ).thenAnswer((_) async {});

    await useCase.updateWeighment(7, weighment);

    verify(() => repository.updateWeighment(7, weighment)).called(1);
  });

  test('loads a weighment by id and preserves the repository result', () async {
    when(
      () => repository.getWeighmentById(7),
    ).thenAnswer((_) async => weighment);

    final result = await useCase.getWeighmentById(7);

    expect(result, same(weighment));
    verify(() => repository.getWeighmentById(7)).called(1);
  });
}
