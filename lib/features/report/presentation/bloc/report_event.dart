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

class ReportPartyFilterChanged extends ReportEvent {
  final int? partyId;

  const ReportPartyFilterChanged(this.partyId);

  @override
  List<Object?> get props => [partyId];
}

class ReportVehicleFilterChanged extends ReportEvent {
  final int? vehicleId;

  const ReportVehicleFilterChanged(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class ReportMaterialFilterChanged extends ReportEvent {
  final int? materialId;

  const ReportMaterialFilterChanged(this.materialId);

  @override
  List<Object?> get props => [materialId];
}

class ReportStatusFilterChanged extends ReportEvent {
  final String status;

  const ReportStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
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
