import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../material/domain/repositories/material_item_repository.dart';
import '../../../party/domain/repositories/party_repository.dart';
import '../../../vehicle/domain/repositories/vehicle_repository.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/export_report_usecase.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _reportRepository;
  final PartyRepository _partyRepository;
  final VehicleRepository _vehicleRepository;
  final MaterialItemRepository _materialRepository;
  final ExportReportUseCase _exportReportUseCase;

  ReportBloc({
    required ReportRepository reportRepository,
    required PartyRepository partyRepository,
    required VehicleRepository vehicleRepository,
    required MaterialItemRepository materialRepository,
    required ExportReportUseCase exportReportUseCase,
  })  : _reportRepository = reportRepository,
        _partyRepository = partyRepository,
        _vehicleRepository = vehicleRepository,
        _materialRepository = materialRepository,
        _exportReportUseCase = exportReportUseCase,
        super(const ReportState()) {
    on<LoadReportInitial>(_onLoadReportInitial);
    on<ReportFilterPresetChanged>(_onFilterPresetChanged);
    on<ReportCustomDateChanged>(_onCustomDateChanged);
    on<ReportPartyFilterChanged>(_onPartyFilterChanged);
    on<ReportVehicleFilterChanged>(_onVehicleFilterChanged);
    on<ReportMaterialFilterChanged>(_onMaterialFilterChanged);
    on<ReportStatusFilterChanged>(_onStatusFilterChanged);
    on<ReportPaymentFilterChanged>(_onPaymentFilterChanged);
    on<ReportSearchQueryChanged>(_onSearchQueryChanged);
    on<ApplyReportFilters>(_onApplyReportFilters);
    on<ResetReportFilters>(_onResetReportFilters);
    on<RefreshReport>(_onRefreshReport);
    on<ExportReportCsv>(_onExportReportCsv);
    on<ClearExportResult>(_onClearExportResult);
  }

  Future<void> _onLoadReportInitial(
    LoadReportInitial event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(status: ReportStatus.loading, clearError: true));
    try {
      final parties = await _partyRepository.getAllParties();
      final vehicles = await _vehicleRepository.getAllVehicles();
      final materials = await _materialRepository.getAllMaterials();

      final records = await _reportRepository.getReportRecords(state.filter);
      final summary = _reportRepository.calculateSummary(records);

      emit(
        state.copyWith(
          status: ReportStatus.loaded,
          parties: parties,
          vehicles: vehicles,
          materials: materials,
          records: records,
          summary: summary,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ReportStatus.error,
          errorMessage: 'Failed to load report: $e',
        ),
      );
    }
  }

  Future<void> _onFilterPresetChanged(
    ReportFilterPresetChanged event,
    Emitter<ReportState> emit,
  ) async {
    final updatedFilter = state.filter.copyWith(
      datePreset: event.preset,
      clearCustomDates: event.preset != DateRangePreset.custom,
    );

    emit(state.copyWith(filter: updatedFilter));

    // If preset is not custom, automatically apply filter for smooth UX
    if (event.preset != DateRangePreset.custom) {
      await _fetchRecordsForFilter(updatedFilter, emit);
    }
  }

  void _onCustomDateChanged(
    ReportCustomDateChanged event,
    Emitter<ReportState> emit,
  ) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          datePreset: DateRangePreset.custom,
          customStartDate: event.startDate,
          customEndDate: event.endDate,
        ),
      ),
    );
  }

  void _onPartyFilterChanged(
    ReportPartyFilterChanged event,
    Emitter<ReportState> emit,
  ) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          partyId: event.partyId,
          clearParty: event.partyId == null,
        ),
      ),
    );
  }

  void _onVehicleFilterChanged(
    ReportVehicleFilterChanged event,
    Emitter<ReportState> emit,
  ) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          vehicleId: event.vehicleId,
          clearVehicle: event.vehicleId == null,
        ),
      ),
    );
  }

  void _onMaterialFilterChanged(
    ReportMaterialFilterChanged event,
    Emitter<ReportState> emit,
  ) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          materialId: event.materialId,
          clearMaterial: event.materialId == null,
        ),
      ),
    );
  }

  void _onStatusFilterChanged(
    ReportStatusFilterChanged event,
    Emitter<ReportState> emit,
  ) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(status: event.status),
      ),
    );
  }

  void _onPaymentFilterChanged(
    ReportPaymentFilterChanged event,
    Emitter<ReportState> emit,
  ) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(paymentMode: event.paymentMode),
      ),
    );
  }

  Future<void> _onSearchQueryChanged(
    ReportSearchQueryChanged event,
    Emitter<ReportState> emit,
  ) async {
    final updatedFilter = state.filter.copyWith(searchQuery: event.query);
    emit(state.copyWith(filter: updatedFilter));
    await _fetchRecordsForFilter(updatedFilter, emit);
  }

  Future<void> _onApplyReportFilters(
    ApplyReportFilters event,
    Emitter<ReportState> emit,
  ) async {
    await _fetchRecordsForFilter(state.filter, emit);
  }

  Future<void> _onResetReportFilters(
    ResetReportFilters event,
    Emitter<ReportState> emit,
  ) async {
    const defaultFilter = ReportFilter(
      datePreset: DateRangePreset.today,
      status: 'all',
      paymentMode: 'all',
      searchQuery: '',
    );
    emit(state.copyWith(filter: defaultFilter));
    await _fetchRecordsForFilter(defaultFilter, emit);
  }

  Future<void> _onRefreshReport(
    RefreshReport event,
    Emitter<ReportState> emit,
  ) async {
    await _fetchRecordsForFilter(state.filter, emit);
  }

  Future<void> _fetchRecordsForFilter(
    ReportFilter filter,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(status: ReportStatus.loading, clearError: true));
    try {
      final records = await _reportRepository.getReportRecords(filter);
      final summary = _reportRepository.calculateSummary(records);
      emit(
        state.copyWith(
          status: ReportStatus.loaded,
          records: records,
          summary: summary,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ReportStatus.error,
          errorMessage: 'Failed to load report records: $e',
        ),
      );
    }
  }

  Future<void> _onExportReportCsv(
    ExportReportCsv event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(isExporting: true, clearExportResult: true));
    final result = await _exportReportUseCase(state.filter);
    emit(state.copyWith(isExporting: false, exportResult: result));
  }

  void _onClearExportResult(
    ClearExportResult event,
    Emitter<ReportState> emit,
  ) {
    emit(state.copyWith(clearExportResult: true));
  }
}
