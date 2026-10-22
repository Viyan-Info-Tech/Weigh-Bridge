import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

class FakeWeighment extends Fake implements Weighment {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeWeighment());
  });

  test('ClearBillRequested clears vehicle, material and weights', () async {
    final mockSave = MockSaveBillUseCase();
    final mockLoad = MockLoadRecentBillsUseCase();
    final mockGen = MockGenerateBillNumberUseCase();
    when(
      () => mockLoad.call(date: any(named: 'date')),
    ).thenAnswer((_) async => <Weighment>[]);
    when(() => mockGen.call()).thenAnswer((_) async => 'WB-00002');

    final bloc = BillBloc(
      saveBillUseCase: mockSave,
      loadRecentBillsUseCase: mockLoad,
      generateBillNumberUseCase: mockGen,
    );
    bloc.add(const LoadBillScreen());
    await bloc.stream.firstWhere((s) => s.status == BillScreenStatus.loaded);

    bloc.add(const VehicleNumberChanged('TN32AB1234'));
    bloc.add(const MaterialChanged('Sand'));
    bloc.add(const RemarksChanged('CONT-01'));
    await bloc.stream.firstWhere(
      (s) =>
          s.vehicleNumber == 'TN32AB1234' &&
          s.materialText == 'Sand' &&
          s.remarksText == 'CONT-01',
    );

    bloc.add(const ClearBillRequested());
    await bloc.stream.firstWhere(
      (s) =>
          s.vehicleNumber.isEmpty &&
          s.materialText.isEmpty &&
          s.remarksText.isEmpty,
    );

    expect(bloc.state.vehicleNumber, isEmpty);
    expect(bloc.state.materialText, isEmpty);
    expect(bloc.state.remarksText, isEmpty);
    expect(bloc.state.grossWeightKg, 0);
    expect(bloc.state.tareWeightKg, 0);
    await bloc.close();
  });

  test('MaterialChanged updates state', () async {
    final mockSave = MockSaveBillUseCase();
    final mockLoad = MockLoadRecentBillsUseCase();
    final mockGen = MockGenerateBillNumberUseCase();
    when(
      () => mockLoad.call(date: any(named: 'date')),
    ).thenAnswer((_) async => <Weighment>[]);
    when(() => mockGen.call()).thenAnswer((_) async => 'WB-00002');

    final bloc = BillBloc(
      saveBillUseCase: mockSave,
      loadRecentBillsUseCase: mockLoad,
      generateBillNumberUseCase: mockGen,
    );
    bloc.add(const LoadBillScreen());
    await bloc.stream.firstWhere((s) => s.status == BillScreenStatus.loaded);

    bloc.add(const MaterialChanged('Stone'));
    await bloc.stream.firstWhere((s) => s.materialText == 'Stone');
    expect(bloc.state.materialText, 'Stone');
    await bloc.close();
  });
}
