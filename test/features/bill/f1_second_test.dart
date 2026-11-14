import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/weighment.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

class MockGetPreviousWeighmentUseCase extends Mock
    implements GetPreviousWeighmentUseCase {}

class FakeWeighment extends Fake implements Weighment {}

void main() {
  late MockSaveBillUseCase mockSaveBill;
  late MockLoadRecentBillsUseCase mockLoadRecent;
  late MockGenerateBillNumberUseCase mockGenerateBillNumber;
  late MockGetPreviousWeighmentUseCase mockGetPrevious;
  setUpAll(() => registerFallbackValue(FakeWeighment()));
  BillBloc createBloc() => BillBloc(
    saveBillUseCase: mockSaveBill,
    loadRecentBillsUseCase: mockLoadRecent,
    generateBillNumberUseCase: mockGenerateBillNumber,
    previousWeighmentUseCase: mockGetPrevious,
  );
  setUp(() {
    mockSaveBill = MockSaveBillUseCase();
    mockLoadRecent = MockLoadRecentBillsUseCase();
    mockGenerateBillNumber = MockGenerateBillNumberUseCase();
    mockGetPrevious = MockGetPreviousWeighmentUseCase();
    when(
      () => mockLoadRecent.call(date: any(named: 'date')),
    ).thenAnswer((_) async => []);
    when(
      () => mockGenerateBillNumber.call(),
    ).thenAnswer((_) async => 'WB-00001');
    when(() => mockGetPrevious.call('V')).thenAnswer(
      (_) async => Weighment(
        id: 1,
        billNumber: 'WB-00012',
        vehicleNumber: 'V',
        firstWeightKg: 290,
        firstWeightType: 'GROSS',
        createdAt: DateTime(2026, 11, 13),
        updatedAt: DateTime(2026, 11, 13),
      ),
    );
  });

  test('f1 second mode captures', () async {
    final bloc = createBloc();
    bloc.add(const LoadBillScreen());
    await pumpEventQueue();
    bloc.add(const VehicleNumberChanged('V'));
    await pumpEventQueue();
    bloc.add(const SecondWeightModeChanged(true));
    await pumpEventQueue();
    bloc.add(const FetchPreviousWeightForVehicle());
    await pumpEventQueue();
    expect(bloc.state.tareWeightKg, 290);
    bloc.add(
      const LiveScaleWeightUpdated(
        weightKg: 1065,
        isStable: true,
        isMotion: false,
        isOverload: false,
      ),
    );
    await pumpEventQueue();
    bloc.add(const CaptureLiveWeight(type: 'Gross'));
    await pumpEventQueue();
    expect(bloc.state.grossWeightKg, 1065);
    expect(bloc.state.tareWeightKg, 290);
    expect(bloc.state.grossCapturedAt, isNotNull);
    expect(bloc.state.tareCapturedAt, isNotNull);
  });
}
