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
  });
}
