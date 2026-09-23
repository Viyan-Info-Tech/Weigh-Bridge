import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../material/domain/repositories/material_item_repository.dart';
import '../../../customer/domain/repositories/customer_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/export_report_usecase.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _reportRepository;
  final CustomerRepository _customerRepository;
  final MaterialItemRepository _materialRepository;
  final ExportReportUseCase _exportReportUseCase;
  final SettingsRepository? _settingsRepository;

  ReportBloc({
    required ReportRepository reportRepository,
    required CustomerRepository customerRepository,
    required MaterialItemRepository materialRepository,
    required ExportReportUseCase exportReportUseCase,
    SettingsRepository? settingsRepository,
  }) : _reportRepository = reportRepository,
       _customerRepository = customerRepository,
       _materialRepository = materialRepository,
       _exportReportUseCase = exportReportUseCase,
       _settingsRepository = settingsRepository,
       super(const ReportState()) {
    on<LoadReportInitial>(_onLoadReportInitial);
    on<ReportFilterPresetChanged>(_onFilterPresetChanged);
    on<ReportCustomDateChanged>(_onCustomDateChanged);
    on<ReportCustomerFilterChanged>(_onCustomerFilterChanged);
    on<ReportVehicleFilterChanged>(_onVehicleFilterChanged);
    on<ReportMaterialFilterChanged>(_onMaterialFilterChanged);
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
      final customers = await _customerRepository.getAllCustomers();
      final materials = await _materialRepository.getAllMaterials();

      final records = await _reportRepository.getReportRecords(state.filter);
      final summary = _reportRepository.calculateSummary(records);
      final settings = await _settingsRepository?.getSettings();

      emit(
        state.copyWith(
          status: ReportStatus.loaded,
          customers: customers,
          materials: materials,
          records: records,
          summary: summary,
          weightUnit: _normalizeUnit(settings?.weightUnit ?? state.weightUnit),
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

  void _onCustomerFilterChanged(
    ReportCustomerFilterChanged event,
    Emitter<ReportState> emit,
  ) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          customerId: event.customerId,
          clearCustomer: event.customerId == null,
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
        filter: state.filter.copyWith(vehicleNumber: event.vehicleNumber),
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
      final settings = await _settingsRepository?.getSettings();
      emit(
        state.copyWith(
          status: ReportStatus.loaded,
          records: records,
          summary: summary,
          weightUnit: _normalizeUnit(settings?.weightUnit ?? state.weightUnit),
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
    final result = await _exportReportUseCase(
      state.filter,
      weightUnit: state.weightUnit,
    );
    emit(state.copyWith(isExporting: false, exportResult: result));
  }

  void _onClearExportResult(
    ClearExportResult event,
    Emitter<ReportState> emit,
  ) {
    emit(state.copyWith(clearExportResult: true));
  }

  String _normalizeUnit(String unit) {
    final normalized = unit.trim().toLowerCase();
    return normalized == 'ton' || normalized == 'tonne' || normalized == 't'
        ? 'ton'
        : 'kg';
  }
}
