import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/weighment_report_item.dart';

class ReportLocalDataSource {
  final AppDatabase _database;

  ReportLocalDataSource(this._database);

  Future<List<WeighmentReportItem>> getReportRecords(
    ReportFilter filter,
  ) async {
    final start = filter.effectiveStartDate;
    final end = filter.effectiveEndDate;

    final query = _database.select(_database.weighments).join([
      leftOuterJoin(
        _database.customers,
        _database.customers.id.equalsExp(_database.weighments.customerId),
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

    // Customer filter
    if (filter.customerId != null) {
      query.where(_database.weighments.customerId.equals(filter.customerId!));
    }

    // Vehicle number filter
    final vehicleQuery = filter.vehicleNumber.trim();
    if (vehicleQuery.isNotEmpty) {
      query.where(
        _database.weighments.vehicleNumber.lower().like(
          '%${vehicleQuery.toLowerCase()}%',
        ),
      );
    }

    // Material filter
    if (filter.materialId != null) {
      query.where(_database.weighments.materialId.equals(filter.materialId!));
    }

    // Payment mode filter
    if (filter.paymentMode != 'all') {
      query.where(
        _database.weighments.paymentMode.lower().equals(
          filter.paymentMode.toLowerCase(),
        ),
      );
    }

    // Order by created_at desc
    query.orderBy([OrderingTerm.desc(_database.weighments.createdAt)]);

    final rows = await query.get();

    final List<WeighmentReportItem> results = [];
    final search = filter.searchQuery.trim().toLowerCase();

    for (final row in rows) {
      final w = row.readTable(_database.weighments);
      final customer = row.readTableOrNull(_database.customers);
      final material = row.readTableOrNull(_database.materials);

      final customerName = customer?.name ?? 'Customer #${w.customerId}';
      final vehicleNumber = w.vehicleNumber;
      final materialName = material?.name ?? 'Material #${w.materialId}';

      // If search query is present, check match
      if (search.isNotEmpty) {
        final matchesBill = w.billNumber.toLowerCase().contains(search);
        final matchesVehicle = vehicleNumber.toLowerCase().contains(search);
        final matchesCustomer = customerName.toLowerCase().contains(search);
        final matchesMaterial = materialName.toLowerCase().contains(search);

        if (!matchesBill &&
            !matchesVehicle &&
            !matchesCustomer &&
            !matchesMaterial) {
          continue;
        }
      }

      results.add(
        WeighmentReportItem(
          id: w.id,
          billNumber: w.billNumber,
          createdAt: w.createdAt,
          vehicleNumber: vehicleNumber,
          customerId: w.customerId,
          customerName: customerName,
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
          weightUnit: w.weightUnit,
        ),
      );
    }

    return results;
  }
}
