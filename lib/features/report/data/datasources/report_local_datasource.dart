import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/weighment_report_item.dart';

class ReportLocalDataSource {
  final AppDatabase _database;

  ReportLocalDataSource(this._database);

  Future<List<WeighmentReportItem>> getReportRecords(ReportFilter filter) async {
    final start = filter.effectiveStartDate;
    final end = filter.effectiveEndDate;

    final query = _database.select(_database.weighments).join([
      leftOuterJoin(
        _database.parties,
        _database.parties.id.equalsExp(_database.weighments.partyId),
      ),
      leftOuterJoin(
        _database.vehicles,
        _database.vehicles.id.equalsExp(_database.weighments.vehicleId),
      ),
      leftOuterJoin(
        _database.vehicleTypes,
        _database.vehicleTypes.id.equalsExp(_database.vehicles.vehicleTypeId),
      ),
      leftOuterJoin(
        _database.materials,
        _database.materials.id.equalsExp(_database.weighments.materialId),
      ),
    ]);

    // Date range filter
    query.where(
      _database.weighments.createdAt.isBiggerOrEqualValue(start) &
      _database.weighments.createdAt.isSmallerOrEqualValue(end),
    );

    // Party filter
    if (filter.partyId != null) {
      query.where(_database.weighments.partyId.equals(filter.partyId!));
    }

    // Vehicle filter
    if (filter.vehicleId != null) {
      query.where(_database.weighments.vehicleId.equals(filter.vehicleId!));
    }

    // Material filter
    if (filter.materialId != null) {
      query.where(_database.weighments.materialId.equals(filter.materialId!));
    }

    // Status filter
    if (filter.status != 'all') {
      if (filter.status == 'completed') {
        query.where(_database.weighments.status.equals('completed'));
      } else if (filter.status == 'pending') {
        query.where(_database.weighments.status.equals('pending'));
      }
    }

    // Payment mode filter
    if (filter.paymentMode != 'all') {
      query.where(
        _database.weighments.paymentMode.lower().equals(filter.paymentMode.toLowerCase()),
      );
    }

    // Order by created_at desc
    query.orderBy([OrderingTerm.desc(_database.weighments.createdAt)]);

    final rows = await query.get();

    final List<WeighmentReportItem> results = [];
    final search = filter.searchQuery.trim().toLowerCase();

    for (final row in rows) {
      final w = row.readTable(_database.weighments);
      final party = row.readTableOrNull(_database.parties);
      final vehicle = row.readTableOrNull(_database.vehicles);
      final vehicleType = row.readTableOrNull(_database.vehicleTypes);
      final material = row.readTableOrNull(_database.materials);

      final partyName = party?.name ?? 'Party #${w.partyId}';
      final vehicleNumber = vehicle?.vehicleNumber ?? 'Vehicle #${w.vehicleId}';
      final vehicleTypeName = vehicleType?.name ?? '—';
      final materialName = material?.name ?? 'Material #${w.materialId}';

      // If search query is present, check match
      if (search.isNotEmpty) {
        final matchesBill = w.billNumber.toLowerCase().contains(search);
        final matchesVehicle = vehicleNumber.toLowerCase().contains(search);
        final matchesParty = partyName.toLowerCase().contains(search);
        final matchesMaterial = materialName.toLowerCase().contains(search);

        if (!matchesBill && !matchesVehicle && !matchesParty && !matchesMaterial) {
          continue;
        }
      }

      results.add(
        WeighmentReportItem(
          id: w.id,
          billNumber: w.billNumber,
          createdAt: w.createdAt,
          vehicleId: w.vehicleId,
          vehicleNumber: vehicleNumber,
          vehicleTypeName: vehicleTypeName,
          partyId: w.partyId,
          partyName: partyName,
          materialId: w.materialId,
          materialName: materialName,
          paymentMode: w.paymentMode,
          amount: w.amount,
          vehicleCharge: w.vehicleCharge,
          remarks: w.remarks,
          firstWeightKg: w.firstWeightKg,
          firstWeightType: w.firstWeightType,
          secondWeightKg: w.secondWeightKg,
          secondWeightType: w.secondWeightType,
          rawStatus: w.status,
        ),
      );
    }

    return results;
  }
}
