import 'package:flutter_test/flutter_test.dart';
import 'package:weighbridge/core/database/app_database.dart';
import 'package:weighbridge/features/report/data/datasources/report_local_datasource.dart';
import 'package:weighbridge/features/report/domain/entities/report_filter.dart';

import '../../../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late ReportLocalDataSource source;
  late SeededRefs refs;
  late int party2;

  final todayNoon = DateTime.now();
  final todayMorning = DateTime.now().subtract(const Duration(hours: 6));

  setUp(() async {
    db = createInMemoryDatabase();
    source = ReportLocalDataSource(db);
    refs = await seedParents(db);

    await seedWeighment(
      db,
      partyId: refs.partyId,
      vehicleId: refs.vehicleId,
      materialId: refs.materialId,
      billNumber: 'WB-00001',
      paymentMode: 'cash',
      firstWeightKg: 20000,
      secondWeightKg: 5000,
      status: 'completed',
      amount: 250,
      createdAt: todayMorning,
    );
    await seedWeighment(
      db,
      partyId: refs.partyId,
      vehicleId: refs.vehicleId,
      materialId: refs.materialId,
      billNumber: 'WB-00002',
      paymentMode: 'credit',
      firstWeightKg: 30000,
      status: 'pending',
      amount: 300,
      createdAt: todayNoon,
    );

    party2 = await seedParty(db, name: 'Second Party');
  });

  tearDown(() async {
    await db.close();
  });

  group('ReportLocalDataSource.getReportRecords', () {
    test('returns all today records ordered newest first with joined names',
        () async {
      final records = await source.getReportRecords(const ReportFilter());
      expect(records.map((r) => r.billNumber), ['WB-00002', 'WB-00001']);
      expect(records.first.partyName, 'Seed Party');
      expect(records.first.vehicleNumber, 'TN31SEED01');
      expect(records.first.vehicleTypeName, 'Truck');
      expect(records.first.materialName, 'Cement');
    });

    test('excludes records outside the date preset', () async {
      final records = await source.getReportRecords(
        const ReportFilter(datePreset: DateRangePreset.yesterday),
      );
      expect(records, isEmpty);
    });

    test('filters by party', () async {
      final records = await source.getReportRecords(
        ReportFilter(
          datePreset: DateRangePreset.today,
          partyId: party2,
        ),
      );
      expect(records, isEmpty);

      final forSeed = await source.getReportRecords(
        ReportFilter(
          datePreset: DateRangePreset.today,
          partyId: refs.partyId,
        ),
      );
      expect(forSeed.length, 2);
    });

    test('filters by status using the stored status column', () async {
      final completed = await source.getReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          status: 'completed',
        ),
      );
      expect(completed.map((r) => r.billNumber), ['WB-00001']);

      final pending = await source.getReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          status: 'pending',
        ),
      );
      expect(pending.map((r) => r.billNumber), ['WB-00002']);
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

    test('searches by bill number, vehicle, party and material', () async {
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

      final byParty = await source.getReportRecords(
        const ReportFilter(
          datePreset: DateRangePreset.today,
          searchQuery: 'seed party',
        ),
      );
      expect(byParty.length, 2);

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
      // Remove the vehicle for WB-00002 first so lookups miss.
      final pendingBill = await db.billDao.getWeighmentByBillNumber('WB-00002');
      await db.vehicleDao.deleteVehicle(pendingBill!.vehicleId);

      final records = await source.getReportRecords(const ReportFilter());
      final orphan = records.firstWhere((r) => r.billNumber == 'WB-00002');
      expect(orphan.vehicleNumber, 'Vehicle #${pendingBill.vehicleId}');
      expect(orphan.vehicleTypeName, '—');
    });

    test('maps weights and computed status onto report items', () async {
      final records = await source.getReportRecords(const ReportFilter());
      final first = records.firstWhere((r) => r.billNumber == 'WB-00002');
      expect(first.firstWeightKg, 30000);
      expect(first.grossWeightKg, 30000);
      expect(first.displayStatus, 'PENDING');
      expect(first.isCompleted, isFalse);
      expect(first.rawStatus, 'pending');

      final second = records.firstWhere((r) => r.billNumber == 'WB-00001');
      expect(second.netWeightKg, 15000);
      expect(second.isCompleted, isTrue);
    });
  });
}