import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';

import '../../../support/test_database.dart';

/// Rules for the previous-weighment lookup that feeds the SECOND WEIGHT
/// workflow: the record it returns decides which weight is locked on the
/// form, so matching, eligibility and ordering must be exact.
void main() {
  late AppDatabase db;

  setUp(() {
    db = createInMemoryDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  group('BillDao.getLatestSingleWeightWeighmentForVehicle', () {
    test('returns the single-weight bill for the vehicle', () async {
      final id = await seedWeighment(
        db,
        billNumber: 'WB-00001',
        vehicleNumber: 'TN31CM2026',
        firstWeightKg: 14710,
        firstWeightType: 'GROSS',
      );

      final found = await db.billDao.getLatestSingleWeightWeighmentForVehicle(
        'TN31CM2026',
      );

      expect(found, isNotNull);
      expect(found!.id, id);
      expect(found.billNumber, 'WB-00001');
    });

    test(
      'matches case-insensitively and ignores surrounding whitespace',
      () async {
        await seedWeighment(
          db,
          billNumber: 'WB-00001',
          vehicleNumber: 'TN31CM2026',
          firstWeightKg: 14710,
        );

        final lower = await db.billDao.getLatestSingleWeightWeighmentForVehicle(
          'tn31cm2026',
        );
        final padded = await db.billDao
            .getLatestSingleWeightWeighmentForVehicle('  TN31CM2026  ');

        expect(lower, isNotNull);
        expect(padded, isNotNull);
        expect(lower!.billNumber, 'WB-00001');
        expect(padded!.billNumber, 'WB-00001');
      },
    );

    test('ignores spaces inside the number on both sides', () async {
      await seedWeighment(
        db,
        billNumber: 'WB-00001',
        vehicleNumber: 'TN31CM2026',
        firstWeightKg: 14710,
      );

      // A spaced lookup finds the compact stored row...
      final spacedLookup = await db.billDao
          .getLatestSingleWeightWeighmentForVehicle('TN 31 CM 2026');

      expect(spacedLookup, isNotNull);
      expect(spacedLookup!.billNumber, 'WB-00001');

      await seedWeighment(
        db,
        billNumber: 'WB-00002',
        vehicleNumber: 'MH 12 AB 1234',
        firstWeightKg: 9800,
      );

      // ...and a compact lookup finds a spaced stored row.
      final compactLookup = await db.billDao
          .getLatestSingleWeightWeighmentForVehicle('MH12AB1234');

      expect(compactLookup, isNotNull);
      expect(compactLookup!.billNumber, 'WB-00002');
    });

    test('skips other vehicles entirely', () async {
      await seedWeighment(
        db,
        billNumber: 'WB-00001',
        vehicleNumber: 'TN31CM2026',
        firstWeightKg: 14710,
      );

      final found = await db.billDao.getLatestSingleWeightWeighmentForVehicle(
        'MH12AB9999',
      );

      expect(found, isNull);
    });

    test(
      'skips bills that already hold both weights (completed pairings)',
      () async {
        await seedWeighment(
          db,
          billNumber: 'WB-00001',
          vehicleNumber: 'TN31CM2026',
          firstWeightKg: 20000,
          secondWeightKg: 8000,
          secondWeightType: 'TARE',
        );

        final found = await db.billDao.getLatestSingleWeightWeighmentForVehicle(
          'TN31CM2026',
        );

        expect(found, isNull);
      },
    );

    test('skips zero-weight rows that can never pair', () async {
      await seedWeighment(
        db,
        billNumber: 'WB-00001',
        vehicleNumber: 'TN31CM2026',
        firstWeightKg: 0,
      );

      final found = await db.billDao.getLatestSingleWeightWeighmentForVehicle(
        'TN31CM2026',
      );

      expect(found, isNull);
    });

    test('returns the most recent eligible bill among several', () async {
      await seedWeighment(
        db,
        billNumber: 'WB-00001',
        vehicleNumber: 'TN31CM2026',
        firstWeightKg: 12000,
        createdAt: DateTime(2026, 10, 1, 8),
      );
      await seedWeighment(
        db,
        billNumber: 'WB-00002',
        vehicleNumber: 'TN31CM2026',
        firstWeightKg: 14710,
        createdAt: DateTime(2026, 10, 2, 9),
      );
      // A completed pair from another visit must not win even though it is
      // the newest row for this vehicle.
      await seedWeighment(
        db,
        billNumber: 'WB-00003',
        vehicleNumber: 'TN31CM2026',
        firstWeightKg: 15000,
        secondWeightKg: 7000,
        secondWeightType: 'TARE',
        createdAt: DateTime(2026, 10, 3, 10),
      );

      final found = await db.billDao.getLatestSingleWeightWeighmentForVehicle(
        'TN31CM2026',
      );

      expect(found, isNotNull);
      expect(found!.billNumber, 'WB-00002');
      expect(found.firstWeightKg, 14710);
    });

    test(
      'breaks same-timestamp ties deterministically with the newest id',
      () async {
        final at = DateTime(2026, 10, 1, 8);
        await seedWeighment(
          db,
          billNumber: 'WB-00001',
          vehicleNumber: 'TN31CM2026',
          firstWeightKg: 10000,
          createdAt: at,
        );
        await seedWeighment(
          db,
          billNumber: 'WB-00002',
          vehicleNumber: 'TN31CM2026',
          firstWeightKg: 11000,
          createdAt: at,
        );

        final first = await db.billDao.getLatestSingleWeightWeighmentForVehicle(
          'TN31CM2026',
        );
        final second = await db.billDao
            .getLatestSingleWeightWeighmentForVehicle('TN31CM2026');

        expect(first!.billNumber, 'WB-00002');
        expect(second!.billNumber, 'WB-00002');
      },
    );

    test(
      'finds a TARE-first single-weight bill so both directions work',
      () async {
        await seedWeighment(
          db,
          billNumber: 'WB-00001',
          vehicleNumber: 'TN31CM2026',
          firstWeightKg: 10000,
          firstWeightType: 'TARE',
        );

        final found = await db.billDao.getLatestSingleWeightWeighmentForVehicle(
          'TN31CM2026',
        );

        expect(found, isNotNull);
        expect(found!.firstWeightType, 'TARE');
        expect(found.firstWeightKg, 10000);
      },
    );
  });

  group('previous_weighment_id column', () {
    test(
      'round-trips the link and defaults to null for normal bills',
      () async {
        final originalId = await seedWeighment(
          db,
          billNumber: 'WB-00001',
          vehicleNumber: 'TN31CM2026',
          firstWeightKg: 14710,
        );
        final secondId = await seedWeighment(
          db,
          billNumber: 'WB-00002',
          vehicleNumber: 'TN31CM2026',
          firstWeightKg: 14710,
          firstWeightType: 'GROSS',
          secondWeightKg: 10000,
          secondWeightType: 'TARE',
          previousWeighmentId: originalId,
        );

        final original = await db.billDao.getWeighmentById(originalId);
        final second = await db.billDao.getWeighmentById(secondId);

        expect(original, isNotNull);
        expect(
          original!.previousWeighmentId,
          isNull,
          reason: 'the original bill must not be modified by the second one',
        );
        expect(second, isNotNull);
        expect(second!.previousWeighmentId, originalId);
      },
    );
  });
}
