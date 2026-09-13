import 'package:equatable/equatable.dart';

import '../../../material/domain/entities/material_item.dart';
import '../../../party/domain/entities/party.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/weighment_report_item.dart';

enum ReportStatus { initial, loading, loaded, error }

class ReportState extends Equatable {
  final ReportStatus status;
  final List<WeighmentReportItem> records;
  final ReportSummary summary;
  final ReportFilter filter;
  final List<Party> parties;
  final List<Vehicle> vehicles;
  final List<MaterialItem> materials;
  final String? errorMessage;
  final String weightUnit;

  const ReportState({
    this.status = ReportStatus.initial,
    this.records = const [],
    this.summary = const ReportSummary(),
    this.filter = const ReportFilter(),
    this.parties = const [],
    this.vehicles = const [],
    this.materials = const [],
    this.errorMessage,
    this.weightUnit = 'kg',
  });

  bool get isLoading => status == ReportStatus.loading;

  ReportState copyWith({
    ReportStatus? status,
    List<WeighmentReportItem>? records,
    ReportSummary? summary,
    ReportFilter? filter,
    List<Party>? parties,
    List<Vehicle>? vehicles,
    List<MaterialItem>? materials,
    String? errorMessage,
    bool clearError = false,
    String? weightUnit,
  }) {
    return ReportState(
      status: status ?? this.status,
      records: records ?? this.records,
      summary: summary ?? this.summary,
      filter: filter ?? this.filter,
      parties: parties ?? this.parties,
      vehicles: vehicles ?? this.vehicles,
      materials: materials ?? this.materials,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }

  @override
  List<Object?> get props => [
        status,
        records,
        summary,
        filter,
        parties,
        vehicles,
        materials,
        errorMessage,
        weightUnit,
      ];
}
