import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../bill/domain/entities/weighment.dart' as domain;
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/weighment_report_item.dart';

/// Reads weighment report rows straight from SQLite.
///
/// All filtering, searching, ordering and paging happen in SQL so the amount of
/// data crossing into Dart stays bounded by the page size instead of the size of
/// the table. Nothing here streams whole result sets into memory.
class ReportLocalDataSource {
  final AppDatabase _database;

  ReportLocalDataSource(this._database);

  /// Returns one page of matching records, newest first.
  ///
  /// When [limit] is null every matching record is returned; that is only used
  /// by exports, which need the full set. Pass a [limit] (with [offset]) for
  /// anything user-facing.
  Future<List<WeighmentReportItem>> getReportRecords(
    ReportFilter filter, {
    int? limit,
    int offset = 0,
  }) async {
    final query = _database.select(_database.weighments)
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        // Stable tie-break so paging cannot repeat or skip a row when two
        // weighments share a timestamp.
        (t) => OrderingTerm.desc(t.id),
      ]);
    _applyWhere(query, filter);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    final rows = await query.get();
    return rows.map(_toReportItem).toList(growable: false);
  }

  /// Counts every record matching [filter], ignoring paging.
  ///
  /// Used for the "showing X of Y" indicator and to decide whether more pages
  /// exist, so it must reflect the whole result set rather than the page.
  Future<int> countReportRecords(ReportFilter filter) async {
    final countColumn = _database.weighments.id.count();
    final query = _database.selectOnly(_database.weighments);
    _applyWhereOnly(query, filter);
    query.addColumns([countColumn]);

    final row = await query.getSingle();
    return row.read(countColumn) ?? 0;
  }

  /// Aggregates every record matching [filter] without materialising them.
  ///
  /// The summary bar must describe the whole filtered result, not just the page
  /// on screen, so it cannot be derived from [getReportRecords]. Only the three
  /// weight columns are selected, and the derivation delegates to
  /// the same pure functions the table rows use, so the totals cannot drift from
  /// what the report displays for the same weighment.
  Future<ReportSummary> summarizeReportRecords(ReportFilter filter) async {
    final query = _database.selectOnly(_database.weighments);
    _applyWhereOnly(query, filter);
    query.addColumns([
      _database.weighments.firstWeightKg,
      _database.weighments.firstWeightType,
      _database.weighments.secondWeightKg,
    ]);

    final rows = await query.get();

    double totalGross = 0;
    double totalTare = 0;
    double totalNet = 0;
    int completed = 0;

    for (final row in rows) {
      final firstWeightKg = row.read(_database.weighments.firstWeightKg) ?? 0;
      final firstWeightType =
          row.read(_database.weighments.firstWeightType) ?? 'GROSS';
      final secondWeightKg = row.read(_database.weighments.secondWeightKg);

      final gross = WeighmentReportItem.deriveGrossWeight(
        firstWeightKg,
        firstWeightType,
        secondWeightKg,
      );
      final tare = WeighmentReportItem.deriveTareWeight(
        firstWeightKg,
        firstWeightType,
        secondWeightKg,
      );

      totalGross += gross ?? 0;
      totalTare += tare ?? 0;
      totalNet += WeighmentReportItem.deriveNetWeight(gross, tare) ?? 0;
      if (domain.Weighment.isCompletedForWeights(gross, tare)) {
        completed++;
      }
    }

    return ReportSummary(
      totalBills: rows.length,
      totalGrossWeightKg: totalGross,
      totalTareWeightKg: totalTare,
      totalNetWeightKg: totalNet,
      completedCount: completed,
    );
  }

  void _applyWhere(
    SimpleSelectStatement<$WeighmentsTable, Weighment> query,
    ReportFilter filter,
  ) {
    query.where(
      (w) =>
          w.createdAt.isBiggerOrEqualValue(filter.effectiveStartDate) &
          w.createdAt.isSmallerOrEqualValue(filter.effectiveEndDate),
    );

    final vehicleQuery = filter.vehicleNumber.trim();
    if (vehicleQuery.isNotEmpty) {
      query.where(
        (w) => w.vehicleNumber.lower().like(
          '%${_escapeLike(vehicleQuery)}%',
          escapeChar: _likeEscapeChar,
        ),
      );
    }

    final search = filter.searchQuery.trim().toLowerCase();
    if (search.isNotEmpty) {
      final pattern = '%${_escapeLike(search)}%';
      query.where(
        (w) =>
            w.billNumber.lower().like(pattern, escapeChar: _likeEscapeChar) |
            w.vehicleNumber.lower().like(pattern, escapeChar: _likeEscapeChar),
      );
    }
  }

  void _applyWhereOnly(
    JoinedSelectStatement<HasResultSet, dynamic> query,
    ReportFilter filter,
  ) {
    final weights = _database.weighments;

    query.where(
      weights.createdAt.isBiggerOrEqualValue(filter.effectiveStartDate) &
          weights.createdAt.isSmallerOrEqualValue(filter.effectiveEndDate),
    );

    final vehicleQuery = filter.vehicleNumber.trim();
    if (vehicleQuery.isNotEmpty) {
      query.where(
        weights.vehicleNumber.lower().like(
          '%${_escapeLike(vehicleQuery)}%',
          escapeChar: _likeEscapeChar,
        ),
      );
    }

    final search = filter.searchQuery.trim().toLowerCase();
    if (search.isNotEmpty) {
      final pattern = '%${_escapeLike(search)}%';
      query.where(
        weights.billNumber.lower().like(pattern, escapeChar: _likeEscapeChar) |
            weights.vehicleNumber.lower().like(
              pattern,
              escapeChar: _likeEscapeChar,
            ),
      );
    }
  }

  WeighmentReportItem _toReportItem(Weighment row) {
    return WeighmentReportItem(
      id: row.id,
      billNumber: row.billNumber,
      createdAt: row.createdAt,
      vehicleNumber: row.vehicleNumber,
      remarks: row.remarks,
      firstWeightKg: row.firstWeightKg,
      firstWeightType: row.firstWeightType,
      secondWeightKg: row.secondWeightKg,
      secondWeightType: row.secondWeightType,
      weightUnit: row.weightUnit,
    );
  }

  /// Neutralises LIKE wildcards so a search for "50%" or "A_B" matches those
  /// characters literally instead of acting as a wildcard.
  ///
  /// The escaping is only honoured by SQLite when the query declares an escape
  /// character, hence [like] must pass [_likeEscapeChar] alongside the pattern.
  static const String _likeEscapeChar = r'\';

  static String _escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
