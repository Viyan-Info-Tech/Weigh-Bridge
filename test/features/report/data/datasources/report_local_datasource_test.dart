import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/features/report/data/datasources/report_local_datasource.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';

import '../../../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late ReportLocalDataSource source;
  late SeededRefs refs;
  late int customer2;

  final todayNoon = DateTime.now();
  final todayMorning = DateTime.now().subtract(const Duration(hours: 6));

  setUp(() async {
    db = createInMemoryDatabase();
    source = ReportLocalDataSource(db);
    refs = await seedParents(db);

    await seedWeighment(
      db,
      customerId: refs.customerId,
      materialId: refs.materialId,
      billNumber: 'WB-00001',
      paymentMode: 'cash',
      firstWeightKg: 20000,
      secondWeightKg: 5000,
      amount: 250,
      createdAt: todayMorning,
    );
    await seedWeighment(
      db,
      customerId: refs.customerId,
      materialId: refs.materialId,
      billNumber: 'WB-00002',
      paymentMode: 'credit',
      firstWeightKg: 30000,
      amount: 300,
      createdAt: todayNoon,
    );

    customer2 = await seedCustomer(db, name: 'Second Customer');
  });

  tearDown(() async {
    await db.close();
  });

  group('ReportLocalDataSource.getReportRecords', () {
    test(
      'returns all today records ordered newest first with joined names',
      () async {
        final records = await source.getReportRecords(const ReportFilter());
        expect(records.map((r) => r.billNumber), ['WB-00002', 'WB-00001']);
        expect(records.first.customerName, 'Seed Customer');
        expect(records.first.vehicleNumber, 'TN31SEED01');
        expect(records.first.materialName, 'Cement');
      },
    );

    test('excludes records outside the date preset', () async {
      final records = await source.getReportRecords(
        const ReportFilter(datePreset: DateRangePreset.yesterday),
      );
      expect(records, isEmpty);
    });

    test('filters by customer', () async {
      final records = await source.getReportRecords(
        ReportFilter(datePreset: DateRangePreset.today, customerId: customer2),
      );
      expect(records, isEmpty);

      final forSeed = await source.getReportRecords(
        ReportFilter(
          datePreset: DateRangePreset.today,
          customerId: refs.customerId,
        ),
      );
      expect(forSeed.length, 2);
    });

    test('filters by payment mode case-insensitively', () async {
      final credit = await source.getReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          paymentMode: 'CREDIT',
        ),
      );
      expect(credit.map((r) => r.billNumber), ['WB-00002']);

      final cash = await source.getReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          paymentMode: 'cash',
        ),
      );
      expect(cash.map((r) => r.billNumber), ['WB-00001']);
    });

    test('searches by bill number, vehicle, customer and material', () async {
      final byBill = await source.getReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          searchQuery: 'WB-00002',
        ),
      );
      expect(byBill.single.billNumber, 'WB-00002');

      final byVehicle = await source.getReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          searchQuery: 'TN31SEED',
        ),
      );
      expect(byVehicle.length, 2);

      final byCustomer = await source.getReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          searchQuery: 'seed customer',
        ),
      );
      expect(byCustomer.length, 2);

      final byMaterial = await source.getReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          searchQuery: 'cement',
        ),
      );
      expect(byMaterial.length, 2);

      final none = await source.getReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          searchQuery: 'zzz-nothing',
        ),
      );
      expect(none, isEmpty);
    });

    test('falls back to ids for missing parent records', () async {
      await seedWeighment(
        db,
        customerId: 9999,
        materialId: 8888,
        billNumber: 'WB-00003',
        firstWeightKg: 1000,
        createdAt: DateTime.now(),
      );

      final records = await source.getReportRecords(const ReportFilter());
      final orphan = records.firstWhere((r) => r.billNumber == 'WB-00003');
      expect(orphan.customerName, 'Customer #9999');
      expect(orphan.materialName, 'Material #8888');
    });

    test('maps weights and completion onto report items', () async {
      final records = await source.getReportRecords(const ReportFilter());
      final first = records.firstWhere((r) => r.billNumber == 'WB-00002');
      expect(first.firstWeightKg, 30000);
      expect(first.grossWeightKg, 30000);
      expect(first.isCompleted, isFalse);

      final second = records.firstWhere((r) => r.billNumber == 'WB-00001');
      expect(second.netWeightKg, 15000);
      expect(second.isCompleted, isTrue);
    });

    test('treats LIKE wildcards in the search as literal characters', () async {
      final nothing = await source.getReportRecords(
        const ReportFilter(datePreset: DateRangePreset.today, searchQuery: '%'),
      );
      expect(nothing, isEmpty, reason: "'%' must not match every record");

      final underscore = await source.getReportRecords(
        const ReportFilter(datePreset: DateRangePreset.today, searchQuery: '_'),
      );
      expect(underscore, isEmpty, reason: "'_' must not match every character");
    });

    test('still finds substrings containing an escaped wildcard', () async {
      final materialId = await seedMaterial(
        db,
        code: 'pct',
        name: '50% Grade Cement',
      );
      await seedWeighment(
        db,
        customerId: refs.customerId,
        materialId: materialId,
        billNumber: 'WB-00004',
        firstWeightKg: 1000,
        createdAt: todayNoon,
      );

      final records = await source.getReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          searchQuery: '50%',
        ),
      );
      expect(records.map((r) => r.billNumber), ['WB-00004']);
    });
  });

  group('ReportLocalDataSource paging', () {
    test(
      'returns a limited, ordered page and counts the full result',
      () async {
        const filter = ReportFilter(datePreset: DateRangePreset.today);

        final firstPage = await source.getReportRecords(
          filter,
          limit: 1,
          offset: 0,
        );
        final secondPage = await source.getReportRecords(
          filter,
          limit: 1,
          offset: 1,
        );

        expect(firstPage.map((r) => r.billNumber), ['WB-00002']);
        expect(secondPage.map((r) => r.billNumber), ['WB-00001']);
        expect(
          await source.countReportRecords(filter),
          2,
          reason: 'count must ignore paging',
        );
      },
    );

    test('omits the limit only when explicitly not paged', () async {
      const filter = ReportFilter(datePreset: DateRangePreset.today);

      expect(await source.getReportRecords(filter), hasLength(2));
      expect(await source.getReportRecords(filter, limit: 200), hasLength(2));
    });

    test('breaks ties on identical timestamps without skipping rows', () async {
      final stamp = DateTime.now();
      // drift stores DateTime columns as unix seconds.
      final stampSeconds = stamp.millisecondsSinceEpoch ~/ 1000;

      for (final billNumber in ['WB-10001', 'WB-10003']) {
        await seedWeighment(
          db,
          customerId: refs.customerId,
          materialId: refs.materialId,
          billNumber: billNumber,
          firstWeightKg: 1,
          createdAt: stamp,
        );
      }

      // Force both rows onto one exact timestamp: inserting them at slightly
      // different instants would leave the tie-break untested.
      await db.customStatement(
        "UPDATE weighments SET created_at = ? WHERE bill_number IN ('WB-10001', 'WB-10003')",
        [stampSeconds],
      );

      const filter = ReportFilter(datePreset: DateRangePreset.today);
      final tied = await source.getReportRecords(filter, limit: 2);
      expect(tied, hasLength(2));
      expect(
        tied.first.id,
        greaterThan(tied.last.id),
        reason: 'id DESC must order rows sharing a timestamp',
      );
      expect(
        tied.map((r) => r.createdAt.millisecondsSinceEpoch).toSet(),
        hasLength(1),
        reason: 'the fixture must actually share one timestamp',
      );

      final page = await source.getReportRecords(filter, limit: 4);
      expect(page, hasLength(4));
      expect(await source.countReportRecords(filter), 4);
    });

    test('offset past the end returns nothing without error', () async {
      final records = await source.getReportRecords(
        const ReportFilter(datePreset: DateRangePreset.today),
        limit: 10,
        offset: 99,
      );
      expect(records, isEmpty);
    });
  });

  group('ReportLocalDataSource.countReportRecords', () {
    test('applies the same filters as the record query', () async {
      expect(await source.countReportRecords(const ReportFilter()), 2);
      expect(
        await source.countReportRecords(
          const ReportFilter(
            datePreset: DateRangePreset.today,
            paymentMode: 'credit',
          ),
        ),
        1,
      );
      expect(
        await source.countReportRecords(
          const ReportFilter(datePreset: DateRangePreset.yesterday),
        ),
        0,
      );
      expect(
        await source.countReportRecords(
          const ReportFilter(
            datePreset: DateRangePreset.today,
            searchQuery: 'WB-00001',
          ),
        ),
        1,
      );
    });
  });

  group('ReportLocalDataSource.summarizeReportRecords', () {
    test('aggregates the whole filtered result, not just one page', () async {
      const filter = ReportFilter(datePreset: DateRangePreset.today);

      // A single-row page would understate the totals if the summary were
      // derived from paged records.
      final page = await source.getReportRecords(filter, limit: 1);
      expect(page, hasLength(1));

      final summary = await source.summarizeReportRecords(filter);
      expect(summary.totalBills, 2);
      expect(summary.totalGrossWeightKg, 50000);
      expect(summary.totalTareWeightKg, 5000);
      expect(summary.totalNetWeightKg, 15000);
      expect(summary.totalRevenue, 550);
      expect(summary.completedCount, 1);
    });

    test('is zero for an empty result set', () async {
      final summary = await source.summarizeReportRecords(
        const ReportFilter(datePreset: DateRangePreset.yesterday),
      );
      expect(summary.totalBills, 0);
      expect(summary.totalGrossWeightKg, 0);
      expect(summary.totalRevenue, 0);
      expect(summary.completedCount, 0);
    });

    test('respects the filter when aggregating', () async {
      final summary = await source.summarizeReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          paymentMode: 'cash',
        ),
      );
      expect(summary.totalBills, 1);
      expect(summary.totalGrossWeightKg, 20000);
      expect(summary.totalRevenue, 250);
    });

    test('handles TARE-first weighments the same way the table does', () async {
      final tareFirstId = await seedCustomer(db, name: 'Tare First Co');
      await seedWeighment(
        db,
        customerId: tareFirstId,
        materialId: refs.materialId,
        billNumber: 'WB-20001',
        firstWeightKg: 5000,
        firstWeightType: 'TARE',
        secondWeightKg: 20000,
        amount: 100,
        createdAt: todayNoon,
      );

      const filter = ReportFilter(datePreset: DateRangePreset.today);
      final summary = await source.summarizeReportRecords(filter);
      final rows = await source.getReportRecords(filter);
      final tareFirst = rows.firstWhere((r) => r.billNumber == 'WB-20001');

      expect(summary.totalGrossWeightKg, 70000);
      expect(summary.totalTareWeightKg, 10000);
      expect(summary.totalNetWeightKg, 30000);
      expect(summary.completedCount, 2);

      // The aggregate must agree with the row it summarises.
      expect(
        summary.totalGrossWeightKg - tareFirst.grossWeightKg!,
        rows
            .where((r) => r.billNumber != 'WB-20001')
            .fold<double>(0, (sum, r) => sum + r.grossWeightKg!),
      );
    });
  });
}
