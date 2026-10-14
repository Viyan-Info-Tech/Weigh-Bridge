import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/vehicle_tare_record.dart';
import 'package:weighbridge/features/bill/domain/repositories/vehicle_tare_repository.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';
import 'package:weighbridge/features/bill/presentation/pages/bill_page.dart';
import 'package:weighbridge/features/bill/presentation/widgets/auto_tare_dialog.dart';

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

class ProbeVehicleTareRepository implements VehicleTareRepository {
  @override
  Future<List<VehicleTareRecord>> loadVehicleTares() async => [];

  @override
  Future<VehicleTareRecord> saveVehicleTare({
    required String vehicleNumber,
    required double tareKg,
  }) async =>
      VehicleTareRecord(vehicleNumber: vehicleNumber, tareKg: tareKg);
}

void main() {
  testWidgets('probe dialog open', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final saveBillUseCase = MockSaveBillUseCase();
    final loadRecentBillsUseCase = MockLoadRecentBillsUseCase();
    final generateBillNumberUseCase = MockGenerateBillNumberUseCase();
    when(
      () => loadRecentBillsUseCase(),
    ).thenAnswer((_) => Future.value([]));
    when(
      () => loadRecentBillsUseCase(date: any(named: 'date')),
    ).thenAnswer((_) => Future.value([]));
    when(
      () => generateBillNumberUseCase(),
    ).thenAnswer((_) => Future.value('WB-00002'));

    final billBloc = BillBloc(
      saveBillUseCase: saveBillUseCase,
      loadRecentBillsUseCase: loadRecentBillsUseCase,
      generateBillNumberUseCase: generateBillNumberUseCase,
      vehicleTareRepository: ProbeVehicleTareRepository(),
    );
    addTearDown(billBloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: billBloc, child: const BillPage()),
      ),
    );
    await tester.runAsync(() async {
      await billBloc.stream.firstWhere(
        (s) => s.status == BillScreenStatus.loaded,
      );
    });
    await tester.pumpAndSettle();
    debugPrint('STATUS: ${billBloc.state.status}');

    await tester.tap(find.byKey(const Key('auto_tare_indicator')));
    await tester.pumpAndSettle();
    debugPrint(
      'AFTER TAP+SETTLE: records=${billBloc.state.vehicleTareRecords} '
      'dialogs=${find.byType(AutoTareDialog).evaluate().length}',
    );
    expect(find.byType(AutoTareDialog), findsOneWidget);
  });
}
