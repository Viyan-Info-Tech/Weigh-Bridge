import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/features/bill/data/datasources/vehicle_tare_local_datasource.dart';
import 'package:weighbridge/features/bill/domain/entities/vehicle_tare_record.dart'
    as entity;
import 'package:weighbridge/features/bill/presentation/widgets/auto_tare_dialog.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late VehicleTareLocalDataSource dataSource;

  setUp(() async {
    db = createInMemoryDatabase();
    dataSource = VehicleTareLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Auto Tare 11 Default Vehicle Tare Weights', () {
    test('seeds exactly 11 default vehicle records in expected order', () async {
      // 1. Initially empty
      expect(await dataSource.loadVehicleTares(), isEmpty);

      // 2. Run seedDefaultTareWeights
      await db.vehicleTareRecordsDao.seedDefaultTareWeights();

      // 3. Query records
      final records = await dataSource.loadVehicleTares();
      expect(records, hasLength(11));

      final expected = [
        {'vehicleNo': 'TN 14 L 1112', 'weight': 8200.0},
        {'vehicleNo': 'TN 21 AW 4924', 'weight': 7850.0},
        {'vehicleNo': 'TN 21 AV 2459', 'weight': 7510.0},
        {'vehicleNo': 'TN 21 AV 2463', 'weight': 7300.0},
        {'vehicleNo': 'TN 21 AV 2464', 'weight': 7540.0},
        {'vehicleNo': 'TN 01 X 0793', 'weight': 4700.0},
        {'vehicleNo': 'BULK QUARTZ', 'weight': 21500.0},
        {'vehicleNo': 'JCB - 11', 'weight': 7180.0},
        {'vehicleNo': 'JCB - 19', 'weight': 7470.0},
        {'vehicleNo': 'JCB - 33', 'weight': 7970.0},
        {'vehicleNo': 'JCB - 45', 'weight': 7700.0},
      ];

      for (var i = 0; i < expected.length; i++) {
        expect(
          records[i].vehicleNumber,
          expected[i]['vehicleNo'],
          reason: 'Row ${i + 1} vehicle number must match',
        );
        expect(
          records[i].tareKg,
          expected[i]['weight'],
          reason: 'Row ${i + 1} weight must match',
        );
      }
    });

    test('updates old tare weight of 7,550 kg to 7,850 kg for TN 21 AW 4924', () async {
      // Simulate an existing database with the old tare weight of 7,550 kg
      await dataSource.saveVehicleTare(
        vehicleNumber: 'TN 21 AW 4924',
        tareKg: 7550.0,
      );

      final before = await dataSource.loadVehicleTares();
      expect(before.single.tareKg, 7550.0);

      // Run seeding / migration
      await db.vehicleTareRecordsDao.seedDefaultTareWeights();

      final after = await dataSource.loadVehicleTares();
      expect(after, hasLength(11));

      final tn21 = after.firstWhere((r) => r.vehicleNumber == 'TN 21 AW 4924');
      expect(tn21.tareKg, 7850.0);
    });

    test('re-running seed does not duplicate records or overwrite manual edits', () async {
      await db.vehicleTareRecordsDao.seedDefaultTareWeights();
      expect(await dataSource.loadVehicleTares(), hasLength(11));

      // Operator manually edits JCB - 11 tare weight to 7250 kg
      final jcb11 = (await dataSource.loadVehicleTares())
          .firstWhere((r) => r.vehicleNumber == 'JCB - 11');
      await dataSource.updateVehicleTare(
        id: jcb11.id!,
        vehicleNumber: 'JCB - 11',
        tareKg: 7250.0,
      );

      // Re-run seed (e.g. app restart)
      await db.vehicleTareRecordsDao.seedDefaultTareWeights();

      final records = await dataSource.loadVehicleTares();
      expect(records, hasLength(11));
      final updatedJcb11 = records.firstWhere((r) => r.vehicleNumber == 'JCB - 11');
      expect(updatedJcb11.tareKg, 7250.0);
    });

    testWidgets('AutoTareDialog renders all 11 records in table with SL NO and weights', (
      tester,
    ) async {
      await db.vehicleTareRecordsDao.seedDefaultTareWeights();
      final records = await dataSource.loadVehicleTares();

      entity.VehicleTareRecord? selectedRecord;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutoTareDialog(
              records: records,
              recordsStream: dataSource.watchVehicleTares(),
              liveScaleWeightKg: 0,
              isScaleStable: true,
              isScaleMotion: false,
              isScaleOverload: false,
              weightUnit: 'kg',
              onAdd: (veh, kg) => dataSource.saveVehicleTare(vehicleNumber: veh, tareKg: kg),
              onDelete: (veh) => dataSource.deleteVehicleTare(veh),
              onSelect: (rec) => selectedRecord = rec,
              onUpdate: (id, veh, kg) => dataSource.updateVehicleTare(id: id, vehicleNumber: veh, tareKg: kg),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header titles
      expect(find.text('SL NO'), findsOneWidget);
      expect(find.text('VEHICLE NO'), findsOneWidget);
      expect(find.text('WEIGHT'), findsOneWidget);

      // Check that "No vehicle tare records yet" is not displayed
      expect(find.text('No vehicle tare records yet.\nTap Add to record the first one.'), findsNothing);

      // Check that vehicles and formatted weights are displayed
      expect(find.text('TN 14 L 1112'), findsOneWidget);
      expect(find.text('8,200 Kg'), findsOneWidget);

      expect(find.text('TN 21 AW 4924'), findsOneWidget);
      expect(find.text('7,850 Kg'), findsOneWidget);

      expect(find.text('BULK QUARTZ'), findsOneWidget);
      expect(find.text('21,500 Kg'), findsOneWidget);

      expect(find.text('JCB - 45'), findsOneWidget);
      expect(find.text('7,700 Kg'), findsOneWidget);

      // Tap on a record row to select it
      await tester.tap(find.text('TN 14 L 1112'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(selectedRecord, isNotNull);
      expect(selectedRecord!.vehicleNumber, 'TN 14 L 1112');
      expect(selectedRecord!.tareKg, 8200.0);
    });

    test('net weight calculation: Gross 25,000 kg - Tare 8,200 kg = 16,800 kg', () {
      const grossWeight = 25000.0;
      const tareWeight = 8200.0;
      final netWeight = grossWeight - tareWeight;
      expect(netWeight, 16800.0);
    });
  });
}
