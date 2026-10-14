import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart' hide Weighment;
import 'package:weighbridge/features/bill/data/datasources/vehicle_tare_local_datasource.dart';

import '../../../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late VehicleTareLocalDataSource source;

  setUp(() async {
    db = createInMemoryDatabase();
    source = VehicleTareLocalDataSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('VehicleTareLocalDataSource', () {
    test('starts empty', () async {
      expect(await source.loadVehicleTares(), isEmpty);
    });

    test('save persists and load returns records ordered by vehicle', () async {
      await source.saveVehicleTare(vehicleNumber: 'TN21AW4924', tareKg: 7850);
      await source.saveVehicleTare(vehicleNumber: 'TN14L1112', tareKg: 8200);

      final records = await source.loadVehicleTares();
      expect(records.map((r) => r.vehicleNumber), ['TN14L1112', 'TN21AW4924']);
      expect(records.first.tareKg, 8200);
      expect(records.first.id, isNotNull);
    });

    test('vehicle numbers are normalized to upper case', () async {
      final saved = await source.saveVehicleTare(
        vehicleNumber: 'tn14l1112',
        tareKg: 8200,
      );
      expect(saved.vehicleNumber, 'TN14L1112');
    });

    test(
      're-adding a vehicle updates its tare instead of duplicating',
      () async {
        await source.saveVehicleTare(vehicleNumber: 'TN14L1112', tareKg: 8200);
        final updated = await source.saveVehicleTare(
          vehicleNumber: 'TN14L1112',
          tareKg: 8300,
        );

        expect(updated.tareKg, 8300);
        final records = await source.loadVehicleTares();
        expect(records, hasLength(1));
        expect(records.single.tareKg, 8300);
      },
    );

    test('blank vehicle numbers are rejected', () async {
      await expectLater(
        source.saveVehicleTare(vehicleNumber: '   ', tareKg: 8200),
        throwsArgumentError,
      );
      expect(await source.loadVehicleTares(), isEmpty);
    });

    test('non-positive and non-finite tares are rejected', () async {
      for (final tare in [0.0, -5.0, double.nan, double.infinity]) {
        await expectLater(
          source.saveVehicleTare(vehicleNumber: 'TN14L1112', tareKg: tare),
          throwsArgumentError,
          reason: 'tare $tare must be rejected',
        );
      }
      expect(await source.loadVehicleTares(), isEmpty);
    });

    test('delete removes the vehicle record only', () async {
      await source.saveVehicleTare(vehicleNumber: 'TN14L1112', tareKg: 8200);
      await source.saveVehicleTare(vehicleNumber: 'TN21AW4924', tareKg: 7850);

      await source.deleteVehicleTare('TN14L1112');

      final records = await source.loadVehicleTares();
      expect(records.map((r) => r.vehicleNumber), ['TN21AW4924']);
    });

    test('delete of a missing vehicle is a no-op', () async {
      await source.saveVehicleTare(vehicleNumber: 'TN14L1112', tareKg: 8200);
      await source.deleteVehicleTare('TN99ZZ9999');
      expect(await source.loadVehicleTares(), hasLength(1));
    });
  });
}
