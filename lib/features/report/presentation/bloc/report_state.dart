import 'package:equatable/equatable.dart';

import '../../../customer/domain/entities/customer.dart';
import '../../../material/domain/entities/material_item.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/weighment_report_item.dart';
import '../../domain/usecases/export_report_usecase.dart';

enum ReportStatus { initial, loading, loaded, error }

class ReportState extends Equatable {
  final ReportStatus status;

  /// The records currently loaded, i.e. everything fetched so far. With paging
  /// this grows by one page at a time rather than holding the whole table.
  final List<WeighmentReportItem> records;
  final ReportSummary summary;
  final ReportFilter filter;
  final List<Customer> customers;
  final List<MaterialItem> materials;
  final String? errorMessage;
  final String weightUnit;
  final bool isExporting;
  final ExportReportResult? exportResult;

  /// Total records matching [filter] across all pages.
  final int totalRecords;
  final int pageSize;
  final bool isLoadingMore;

  const ReportState({
    this.status = ReportStatus.initial,
    this.records = const [],
    this.summary = const ReportSummary(),
    this.filter = const ReportFilter(),
    this.customers = const [],
    this.materials = const [],
    this.errorMessage,
    this.weightUnit = 'kg',
    this.isExporting = false,
    this.exportResult,
    this.totalRecords = 0,
    this.pageSize = ReportFilter.defaultPageSize,
    this.isLoadingMore = false,
  });

  bool get isLoading => status == ReportStatus.loading;

  /// Whether another page exists beyond the ones already loaded.
  bool get hasMoreRecords => records.length < totalRecords;

  ReportState copyWith({
    ReportStatus? status,
    List<WeighmentReportItem>? records,
    ReportSummary? summary,
    ReportFilter? filter,
    List<Customer>? customers,
    List<MaterialItem>? materials,
    String? errorMessage,
    bool clearError = false,
    String? weightUnit,
    bool? isExporting,
    ExportReportResult? exportResult,
    bool clearExportResult = false,
    int? totalRecords,
    int? pageSize,
    bool? isLoadingMore,
  }) {
    return ReportState(
      status: status ?? this.status,
      records: records ?? this.records,
      summary: summary ?? this.summary,
      filter: filter ?? this.filter,
      customers: customers ?? this.customers,
      materials: materials ?? this.materials,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      weightUnit: weightUnit ?? this.weightUnit,
      isExporting: isExporting ?? this.isExporting,
      exportResult: clearExportResult
          ? null
          : (exportResult ?? this.exportResult),
      totalRecords: totalRecords ?? this.totalRecords,
      pageSize: pageSize ?? this.pageSize,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    records,
    summary,
    filter,
    customers,
    materials,
    errorMessage,
    weightUnit,
    isExporting,
    exportResult,
    totalRecords,
    pageSize,
    isLoadingMore,
  ];
}
