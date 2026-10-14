import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weighbridge/features/bill/domain/entities/vehicle_tare_record.dart';
import 'package:weighbridge/features/bill/domain/repositories/vehicle_tare_repository.dart';
import 'package:weighbridge/features/bill/domain/usecases/save_bill.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_bloc.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_event.dart';
import 'package:weighbridge/features/bill/presentation/bloc/bill_state.dart';

class MockSaveBillUseCase extends Mock implements SaveBillUseCase {}

class MockLoadRecentBillsUseCase extends Mock
    implements LoadRecentBillsUseCase {}

class MockGenerateBillNumberUseCase extends Mock
    implements GenerateBillNumberUseCase {}

/// In-memory vehicle tare registry mirroring the database upsert rule.
class FakeVehicleTareRepository implements VehicleTareRepository {
  final Map<String, double> _byVehicle = {};
  bool failReads = false;
  bool failWrites = false;

  @override
  Future<List<VehicleTareRecord>> loadVehicleTares() async {
    if (failReads) throw Exception('disk full');
    final vehicles = _byVehicle.keys.toList()..sort();
    return [
      for (final vehicle in vehicles)
        VehicleTareRecord(vehicleNumber: vehicle, tareKg: _byVehicle[vehicle]!),
    ];
  }

  @override
  Future<VehicleTareRecord> saveVehicleTare({
    required String vehicleNumber,
    required double tareKg,
  }) async {
    if (failWrites) throw Exception('disk full');
    final normalized = vehicleNumber.trim().toUpperCase();
    if (normalized.isEmpty) throw ArgumentError('Vehicle number is required.');
    if (!tareKg.isFinite || tareKg <= 0) {
      throw ArgumentError('Tare weight must be greater than zero.');
    }
    _byVehicle[normalized] = tareKg;
    return VehicleTareRecord(vehicleNumber: normalized, tareKg: tareKg);
  }

  @override
  Future<void> deleteVehicleTare(String vehicleNumber) async {
    if (failWrites) throw Exception('disk full');
    _byVehicle.remove(vehicleNumber.trim().toUpperCase());
  }
}

void main() {
  late MockSaveBillUseCase mockSaveBill;
  late MockLoadRecentBillsUseCase mockLoadRecent;
  late MockGenerateBillNumberUseCase mockGenerateBillNumber;
  late FakeVehicleTareRepository vehicleTareRepository;

  setUp(() {
    mockSaveBill = MockSaveBillUseCase();
    mockLoadRecent = MockLoadRecentBillsUseCase();
    mockGenerateBillNumber = MockGenerateBillNumberUseCase();
    vehicleTareRepository = FakeVehicleTareRepository();

    when(
      () => mockLoadRecent.call(date: any(named: 'date')),
    ).thenAnswer((_) async => []);
    when(
      () => mockGenerateBillNumber.call(),
    ).thenAnswer((_) async => 'WB-00001');
  });

  BillBloc createBloc() {
    return BillBloc(
      saveBillUseCase: mockSaveBill,
      loadRecentBillsUseCase: mockLoadRecent,
      generateBillNumberUseCase: mockGenerateBillNumber,
      vehicleTareRepository: vehicleTareRepository,
    );
  }

  Future<BillBloc> createLoadedBloc() async {
    final bloc = createBloc();
    bloc.add(const LoadBillScreen());
    await bloc.stream.firstWhere((s) => s.status == BillScreenStatus.loaded);
    return bloc;
  }

  group('Vehicle tare registry (bloc)', () {
    test('LoadVehicleTares populates state and completes the completer',
        () async {
      final bloc = await createLoadedBloc();
      await vehicleTareRepository.saveVehicleTare(
        vehicleNumber: 'TN14L1112',
        tareKg: 8200,
      );

      final completer = Completer<void>();
      bloc.add(LoadVehicleTares(completer: completer));
      await completer.future.timeout(const Duration(seconds: 5));

      expect(
        bloc.state.vehicleTareRecords.map((r) => r.vehicleNumber),
        ['TN14L1112'],
      );
      expect(bloc.state.vehicleTareRecords.single.tareKg, 8200);
      await bloc.close();
    });

    test('SaveVehicleTare persists, refreshes state and completes with record',
        () async {
      final bloc = await createLoadedBloc();

      final completer = Completer<VehicleTareRecord>();
      bloc.add(SaveVehicleTare('tn21aw4924', 7850, completer: completer));
      final saved = await completer.future.timeout(const Duration(seconds: 5));

      expect(saved.vehicleNumber, 'TN21AW4924');
      expect(saved.tareKg, 7850);
      expect(
        bloc.state.vehicleTareRecords.map((r) => r.vehicleNumber),
        ['TN21AW4924'],
      );
      await bloc.close();
    });

    test('re-adding a vehicle updates its tare instead of duplicating',
        () async {
      final bloc = await createLoadedBloc();

      Future<VehicleTareRecord> save(String vehicle, double tare) {
        final completer = Completer<VehicleTareRecord>();
        bloc.add(SaveVehicleTare(vehicle, tare, completer: completer));
        return completer.future;
      }

      await save('TN14L1112', 8200);
      await save('TN14L1112', 8300);

      expect(bloc.state.vehicleTareRecords, hasLength(1));
      expect(bloc.state.vehicleTareRecords.single.tareKg, 8300);
      await bloc.close();
    });

    test('invalid tare completes the completer with an error', () async {
      final bloc = await createLoadedBloc();

      final completer = Completer<VehicleTareRecord>();
      bloc.add(SaveVehicleTare('TN14L1112', 0, completer: completer));

      await expectLater(completer.future, throwsA(isA<ArgumentError>()));
      expect(bloc.state.vehicleTareRecords, isEmpty);
      await bloc.close();
    });

    test('DeleteVehicleTare removes the record and refreshes state', () async {
      final bloc = await createLoadedBloc();

      Future<VehicleTareRecord> save(String vehicle, double tare) {
        final completer = Completer<VehicleTareRecord>();
        bloc.add(SaveVehicleTare(vehicle, tare, completer: completer));
        return completer.future;
      }

      await save('TN14L1112', 8200);
      await save('TN21AW4924', 7850);
      expect(bloc.state.vehicleTareRecords, hasLength(2));

      final completer = Completer<void>();
      bloc.add(DeleteVehicleTare('TN14L1112', completer: completer));
      await completer.future.timeout(const Duration(seconds: 5));

      expect(
        bloc.state.vehicleTareRecords.map((r) => r.vehicleNumber),
        ['TN21AW4924'],
      );
      await bloc.close();
    });

    test('failed load completes a load completer with an error', () async {
      final bloc = await createLoadedBloc();
      vehicleTareRepository.failReads = true;

      final completer = Completer<void>();
      bloc.add(LoadVehicleTares(completer: completer));

      await expectLater(completer.future, throwsException);
      await bloc.close();
    });

    test('saving never touches the in-progress weighment', () async {
      final bloc = await createLoadedBloc();
      bloc.add(const VehicleNumberChanged('TN09AB1234'));
      await bloc.stream.firstWhere((s) => s.vehicleNumber == 'TN09AB1234');

      final completer = Completer<VehicleTareRecord>();
      bloc.add(SaveVehicleTare('TN14L1112', 8200, completer: completer));
      await completer.future.timeout(const Duration(seconds: 5));

      expect(bloc.state.vehicleNumber, 'TN09AB1234');
      expect(bloc.state.grossWeightKg, 0);
      expect(bloc.state.tareWeightKg, 0);
      await bloc.close();
    });
  });
}
