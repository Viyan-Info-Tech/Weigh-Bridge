import 'package:equatable/equatable.dart';

import '../../domain/entities/report_filter.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportInitial extends ReportEvent {
  const LoadReportInitial();
}

class ReportFilterPresetChanged extends ReportEvent {
  final DateRangePreset preset;

  const ReportFilterPresetChanged(this.preset);

  @override
  List<Object?> get props => [preset];
}

class ReportCustomDateChanged extends ReportEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportCustomDateChanged({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class ReportCustomerFilterChanged extends ReportEvent {
  final int? customerId;

  const ReportCustomerFilterChanged(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class ReportVehicleFilterChanged extends ReportEvent {
  final String vehicleNumber;

  const ReportVehicleFilterChanged(this.vehicleNumber);

  @override
  List<Object?> get props => [vehicleNumber];
}

class ReportMaterialFilterChanged extends ReportEvent {
  final int? materialId;

  const ReportMaterialFilterChanged(this.materialId);

  @override
  List<Object?> get props => [materialId];
}

class ReportPaymentFilterChanged extends ReportEvent {
  final String paymentMode;

  const ReportPaymentFilterChanged(this.paymentMode);

  @override
  List<Object?> get props => [paymentMode];
}

class ReportSearchQueryChanged extends ReportEvent {
  final String query;

  const ReportSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ApplyReportFilters extends ReportEvent {
  const ApplyReportFilters();
}

class ResetReportFilters extends ReportEvent {
  const ResetReportFilters();
}

class RefreshReport extends ReportEvent {
  const RefreshReport();
}

class ExportReportCsv extends ReportEvent {
  const ExportReportCsv();
}

class ClearExportResult extends ReportEvent {
  const ClearExportResult();
}
