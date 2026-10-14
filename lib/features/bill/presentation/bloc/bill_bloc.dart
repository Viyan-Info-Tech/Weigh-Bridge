import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/weighment.dart';
import '../../domain/entities/auto_tare_entry.dart';
import '../../domain/entities/vehicle_tare_record.dart';
import '../../domain/usecases/save_bill.dart';
import '../../domain/repositories/auto_tare_repository.dart';
import '../../domain/repositories/vehicle_tare_repository.dart';
import '../../domain/usecases/get_auto_tare_for_date.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import 'bill_auto_tare_handlers.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> with BillAutoTareHandlers {
  final SaveBillUseCase _saveBillUseCase;
  final LoadRecentBillsUseCase _loadRecentBillsUseCase;
  final GenerateBillNumberUseCase _generateBillNumberUseCase;
  final SettingsRepository? _settingsRepository;
  final AutoTareRepository? _autoTareRepository;
  final VehicleTareRepository? _vehicleTareRepository;

  /// The form as it stood immediately after the last successful save.
  ///
  /// One Ctrl+S dispatches `SaveAndPrintBillRequested` twice, because
  /// `BillPage` registers both a raw `HardwareKeyboard` handler and a
  /// `Shortcuts` widget and the two key systems are independent. The UI-level
  /// `isSaving()` check cannot catch the duplicate: both events are queued
  /// before the bloc processes the first one, so the status is still `loaded`
  /// when the second is handled.
  ///
  /// Left unguarded, the first event saves and resets the form and the second
  /// then validates the now-empty form, painting a wall of red errors behind
  /// the receipt preview.
  ///
  /// The duplicate is recognised by the *form* rather than by a flag or by the
  /// receipt, because the two key systems can fire in different event-loop
  /// turns. `BillPage` also dispatches `PrintReceiptDismissed` the moment the
  /// preview opens, so a receipt-based check only holds if the duplicate
  /// happens to arrive before that. Comparing the form holds regardless of
  /// ordering: a request that arrives while the form still looks exactly like
  /// the one that was just saved can only be that duplicate, because an empty
  /// form can never pass validation anyway.
  BillState? _formJustSaved;

  /// True when [state] is still untouched since the last successful save.
  bool get _isDuplicateSaveRequest {
    final saved = _formJustSaved;
    if (saved == null) return false;
    return saved.vehicleNumber == state.vehicleNumber &&
        saved.grossWeightKg == state.grossWeightKg &&
        saved.tareWeightKg == state.tareWeightKg &&
        saved.firstWeightType == state.firstWeightType &&
        saved.materialText == state.materialText &&
        saved.descriptionText == state.descriptionText &&
        saved.remarksText == state.remarksText;
  }

  @override
  AutoTareRepository? get autoTareRepository => _autoTareRepository;

  @override
  VehicleTareRepository? get vehicleTareRepository => _vehicleTareRepository;

  @override
  void recalculateWeights(Emitter<BillState> emit) => _recalculate(emit);

  BillBloc({
    required SaveBillUseCase saveBillUseCase,
    required LoadRecentBillsUseCase loadRecentBillsUseCase,
    required GenerateBillNumberUseCase generateBillNumberUseCase,
    SettingsRepository? settingsRepository,
    AutoTareRepository? autoTareRepository,
    VehicleTareRepository? vehicleTareRepository,
  }) : _saveBillUseCase = saveBillUseCase,
       _loadRecentBillsUseCase = loadRecentBillsUseCase,
       _generateBillNumberUseCase = generateBillNumberUseCase,
       _settingsRepository = settingsRepository,
       _autoTareRepository = autoTareRepository,
       _vehicleTareRepository = vehicleTareRepository,
       super(const BillState()) {
    on<LoadBillScreen>(_onLoadBillScreen);
    on<RefreshBillLookups>(_onRefreshBillLookups);
    on<VehicleNumberChanged>(_onVehicleNumberChanged);
    on<GrossWeightChanged>(_onGrossWeightChanged);
    on<TareWeightChanged>(_onTareWeightChanged);
    on<GrossWeightCommitted>(_onGrossWeightCommitted);
    on<TareWeightCommitted>(_onTareWeightCommitted);
    on<GrossCapturedAtChanged>(_onGrossCapturedAtChanged);
    on<TareCapturedAtChanged>(_onTareCapturedAtChanged);
    on<RemarksChanged>(_onRemarksChanged);
    on<MaterialChanged>(_onMaterialChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<WeightUnitChanged>(_onWeightUnitChanged);
    // Saves run one at a time. The default concurrent transformer would let a
    // double tap on SAVE (or F5 plus a click) run two inserts against the same
    // form state, which is how duplicate bill numbers were being produced.
    on<SaveBillRequested>(_onSaveBillRequested, transformer: _sequential());
    on<SaveAndPrintBillRequested>(
      _onSaveAndPrintBillRequested,
      transformer: _sequential(),
    );
    on<PrintReceiptDismissed>(_onPrintReceiptDismissed);
    on<ClearBillRequested>(_onClearBillRequested, transformer: _sequential());
    on<LoadRecentBills>(_onLoadRecentBills);
    on<CaptureLiveWeight>(_onCaptureLiveWeight);
    on<LiveScaleWeightUpdated>(_onLiveScaleWeightUpdated);
    on<WeightTypeSelected>(_onWeightTypeSelected);
    on<MobileNumberChanged>(_onMobileNumberChanged);
    on<LoadAutoTare>(handleLoadAutoTare);
    on<SaveAutoTare>(handleSaveAutoTare);
    on<DeleteAutoTare>(handleDeleteAutoTare);
    on<ApplyAutoTareToBill>(handleApplyAutoTareToBill);
    on<LoadVehicleTares>(handleLoadVehicleTares);
    on<SaveVehicleTare>(handleSaveVehicleTare);
    on<DeleteVehicleTare>(handleDeleteVehicleTare);
  }

  /// Processes one event at a time for handlers that must not overlap.
  static EventTransformer<T> _sequential<T>() {
    return (events, mapper) => events.asyncExpand(mapper);
  }

  Future<void> _onLoadBillScreen(
    LoadBillScreen event,
    Emitter<BillState> emit,
  ) async {
    emit(state.copyWith(status: BillScreenStatus.loading, clearError: true));

    try {
      final billsDate = _dayOnly(DateTime.now());
      final recentBills = await _loadRecentBillsUseCase(date: billsDate);
      if (emit.isDone) return;
      final billNumber = await _generateBillNumberUseCase();
      if (emit.isDone) return;

      String unit = 'kg';
      if (_settingsRepository != null) {
        final settings = await _settingsRepository.getSettings();
        unit = _normalizeUnit(settings.weightUnit);
      }

      final autoTareRepository = _autoTareRepository;
      AutoTareEntry? autoTare;
      if (autoTareRepository != null) {
        try {
          autoTare = await GetAutoTareForDate(autoTareRepository)(billsDate);
        } catch (_) {
          autoTare = null;
        }
      }

      List<VehicleTareRecord> vehicleTareRecords = const [];
      final vehicleTareRepo = _vehicleTareRepository;
      if (vehicleTareRepo != null) {
        try {
          vehicleTareRecords = await vehicleTareRepo.loadVehicleTares();
        } catch (_) {}
      }

      emit(
        state.copyWith(
          status: BillScreenStatus.loaded,
          recentBills: recentBills,
          billsDate: billsDate,
          currentBillNumber: billNumber,
          weightUnit: unit,
          autoTareKg: autoTare?.tareKg ?? 0,
          autoTareDate: autoTare?.tareDate,
          autoTareSavedAt: autoTare?.savedAt,
          clearAutoTare: autoTare == null,
          vehicleTareRecords: vehicleTareRecords,
        ),
      );
    } catch (e) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage: 'Failed to load bill screen: $e',
        ),
      );
    }
  }

  /// Refreshes the bill number and recent bills without touching anything
  /// the operator has already entered on the form.
  Future<void> _onRefreshBillLookups(
    RefreshBillLookups event,
    Emitter<BillState> emit,
  ) async {
    try {
      final bills = await _loadBillsFor(state.effectiveBillsDate);
      if (emit.isDone) return;
      emit(state.copyWith(recentBills: bills));
    } catch (_) {
      // A failed refresh must not disturb the form.
      return;
    }
  }

  void _onMobileNumberChanged(
    MobileNumberChanged event,
    Emitter<BillState> emit,
  ) {
    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    final trimmed = event.value.trim();
    if (trimmed.isEmpty || RegExp(r'^\d+$').hasMatch(trimmed)) {
      updatedErrors.remove('mobile');
    }
    emit(
      state.copyWith(
        mobileNumber: event.value,
        fieldErrors: updatedErrors,
        clearError: true,
      ),
    );
  }

  void _onVehicleNumberChanged(
    VehicleNumberChanged event,
    Emitter<BillState> emit,
  ) {
    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    final trimmed = event.vehicleNumber.trim();
    if (trimmed.isNotEmpty) {
      updatedErrors.remove('vehicleNumber');
    }
    emit(
      state.copyWith(
        vehicleNumber: event.vehicleNumber.trim().toUpperCase(),
        fieldErrors: updatedErrors,
        clearError: true,
      ),
    );
  }

  String _normalizeUnit(String unit) {
    final value = unit.trim().toLowerCase();
    if (value == 'ton' ||
        value == 'tonne' ||
        value == 'tonnes' ||
        value == 't') {
      return 'ton';
    }
    return 'kg';
  }

  double _toKg(double value, [String? unit]) {
    final u = _normalizeUnit(unit ?? state.weightUnit);
    if (u == 'ton') {
      return value * 1000;
    }
    return value;
  }

  void _onGrossWeightChanged(
    GrossWeightChanged event,
    Emitter<BillState> emit,
  ) {
    if (state.status == BillScreenStatus.initial ||
        state.status == BillScreenStatus.loading) {
      return;
    }
    final displayValue = double.tryParse(event.value) ?? 0;
    if (!displayValue.isFinite || displayValue < 0) {
      emit(state.copyWith(weightValidationError: 'Gross weight is invalid'));
      return;
    }
    final kgValue = _toKg(displayValue);
    final isCleared = event.value.trim().isEmpty || displayValue == 0;
    final capturedAt = isCleared
        ? null
        : (state.grossCapturedAt ?? DateTime.now());
    emit(
      state.copyWith(
        grossWeightText: event.value,
        grossWeightKg: kgValue,
        grossCapturedAt: capturedAt,
        clearGrossCapturedAt: isCleared,
        clearError: true,
      ),
    );
    _recalculate(emit);
  }

  void _onGrossWeightCommitted(
    GrossWeightCommitted event,
    Emitter<BillState> emit,
  ) {
    if (state.status == BillScreenStatus.initial ||
        state.status == BillScreenStatus.loading) {
      return;
    }
    final displayValue = double.tryParse(event.value);
    if (displayValue == null || displayValue <= 0) {
      if (event.value.trim().isEmpty || displayValue == 0) {
        emit(
          state.copyWith(
            grossWeightText: event.value,
            grossWeightKg: 0,
            clearGrossCapturedAt: true,
            clearError: true,
          ),
        );
        _recalculate(emit);
      }
      return;
    }
    final kgValue = _toKg(displayValue);
    final capturedAt =
        event.capturedAt ?? state.grossCapturedAt ?? DateTime.now();
    emit(
      state.copyWith(
        grossWeightText: event.value,
        grossWeightKg: kgValue,
        grossCapturedAt: capturedAt,
        firstWeightType: state.firstWeightType ?? 'GROSS',
        clearError: true,
      ),
    );
    _recalculate(emit);
  }

  void _onTareWeightChanged(TareWeightChanged event, Emitter<BillState> emit) {
    if (state.status == BillScreenStatus.initial ||
        state.status == BillScreenStatus.loading) {
      return;
    }
    final displayValue = double.tryParse(event.value) ?? 0;
    if (!displayValue.isFinite || displayValue < 0) {
      emit(state.copyWith(weightValidationError: 'Tare weight is invalid'));
      return;
    }
    final kgValue = _toKg(displayValue);
    final isCleared = event.value.trim().isEmpty || displayValue == 0;
    final capturedAt = isCleared
        ? null
        : (state.tareCapturedAt ?? DateTime.now());
    emit(
      state.copyWith(
        tareWeightText: event.value,
        tareWeightKg: kgValue,
        tareCapturedAt: capturedAt,
        clearTareCapturedAt: isCleared,
        clearError: true,
      ),
    );
    _recalculate(emit);
  }

  void _onTareWeightCommitted(
    TareWeightCommitted event,
    Emitter<BillState> emit,
  ) {
    if (state.status == BillScreenStatus.initial ||
        state.status == BillScreenStatus.loading) {
      return;
    }
    final displayValue = double.tryParse(event.value);
    if (displayValue == null || displayValue <= 0) {
      if (event.value.trim().isEmpty || displayValue == 0) {
        emit(
          state.copyWith(
            tareWeightText: event.value,
            tareWeightKg: 0,
            clearTareCapturedAt: true,
            clearError: true,
          ),
        );
        _recalculate(emit);
      }
      return;
    }
    final kgValue = _toKg(displayValue);
    final capturedAt =
        event.capturedAt ?? state.tareCapturedAt ?? DateTime.now();
    emit(
      state.copyWith(
        tareWeightText: event.value,
        tareWeightKg: kgValue,
        tareCapturedAt: capturedAt,
        firstWeightType: state.firstWeightType ?? 'TARE',
        clearError: true,
      ),
    );
    _recalculate(emit);
  }

  void _onGrossCapturedAtChanged(
    GrossCapturedAtChanged event,
    Emitter<BillState> emit,
  ) {
    emit(
      state.copyWith(
        grossCapturedAt: event.capturedAt,
        clearGrossCapturedAt: event.capturedAt == null,
      ),
    );
  }

  void _onTareCapturedAtChanged(
    TareCapturedAtChanged event,
    Emitter<BillState> emit,
  ) {
    emit(
      state.copyWith(
        tareCapturedAt: event.capturedAt,
        clearTareCapturedAt: event.capturedAt == null,
      ),
    );
  }

  void _onRemarksChanged(RemarksChanged event, Emitter<BillState> emit) {
    emit(state.copyWith(remarksText: event.value));
  }

  void _onMaterialChanged(MaterialChanged event, Emitter<BillState> emit) {
    emit(state.copyWith(materialText: event.value));
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<BillState> emit,
  ) {
    emit(state.copyWith(descriptionText: event.value));
  }

  void _onWeightUnitChanged(WeightUnitChanged event, Emitter<BillState> emit) {
    final oldUnit = _normalizeUnit(state.weightUnit);
    final newUnit = _normalizeUnit(event.value);
    if (oldUnit == newUnit) return;

    final newGrossKg = state.grossWeightKg;
    final newTareKg = state.tareWeightKg;
    final isNewTon = newUnit == 'ton';

    final newGrossText = newGrossKg > 0
        ? (isNewTon
              ? (newGrossKg / 1000).toStringAsFixed(3)
              : newGrossKg.toStringAsFixed(0))
        : '';

    final newTareText = newTareKg > 0
        ? (isNewTon
              ? (newTareKg / 1000).toStringAsFixed(3)
              : newTareKg.toStringAsFixed(0))
        : '';

    emit(
      state.copyWith(
        weightUnit: newUnit,
        grossWeightText: newGrossText,
        tareWeightText: newTareText,
      ),
    );
    _recalculate(emit);
  }

  void _recalculate(Emitter<BillState> emit) {
    final gw = state.grossWeightKg;
    final tw = state.tareWeightKg;

    double netWeightKg = 0;
    String? weightError;

    if (gw.isFinite && tw.isFinite && gw > 0 && tw > 0) {
      if (tw >= gw) {
        weightError = 'Gross weight must be greater than tare weight.';
        netWeightKg = 0;
      } else {
        netWeightKg = gw - tw;
      }
    }

    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    if (weightError != null) {
      updatedErrors['weight'] = weightError;
    } else if (gw > 0 || tw > 0) {
      updatedErrors.remove('weight');
    }

    emit(
      state.copyWith(
        netWeightKg: netWeightKg,
        weightValidationError: weightError,
        clearWeightError: weightError == null,
        fieldErrors: updatedErrors,
      ),
    );
  }

  void _onCaptureLiveWeight(CaptureLiveWeight event, Emitter<BillState> emit) {
    final rawLiveKg = state.liveScaleWeightKg;
    if (!rawLiveKg.isFinite || rawLiveKg == 0) {
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage: 'No valid live scale weight is available.',
        ),
      );
      return;
    }
    final liveKg = rawLiveKg.abs();
    if (!state.isScaleStable || state.isScaleMotion || state.isScaleOverload) {
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage: state.isScaleOverload
              ? 'Scale overload. Weight was not captured.'
              : 'Scale weight is not stable. Weight was not captured.',
        ),
      );
      return;
    }
    final isTon = state.weightUnit.toLowerCase() == 'ton';
    final weightStr = isTon
        ? (liveKg / 1000).toStringAsFixed(3)
        : liveKg.toStringAsFixed(0);
    final now = DateTime.now();

    if (event.type.toLowerCase() == 'gross') {
      // The day's auto tare is a copy source only: it fills an empty tare
      // field for this bill. Bills saved earlier keep their own tare value.
      final autoTareKg = state.hasAutoTare ? state.autoTareKg : 0.0;
      final shouldApplyAutoTare =
          autoTareKg > 0 &&
          !(state.tareWeightKg.isFinite && state.tareWeightKg > 0);
      final autoTareText = isTon
          ? (autoTareKg / 1000).toStringAsFixed(3)
          : autoTareKg.toStringAsFixed(0);

      emit(
        state.copyWith(
          grossWeightKg: liveKg,
          grossWeightText: weightStr,
          grossCapturedAt: now,
          firstWeightType: state.firstWeightType ?? 'GROSS',
          tareWeightKg: shouldApplyAutoTare ? autoTareKg : null,
          tareWeightText: shouldApplyAutoTare ? autoTareText : null,
          tareCapturedAt: shouldApplyAutoTare
              ? (state.autoTareSavedAt ?? state.autoTareDate ?? now)
              : null,
          status: BillScreenStatus.loaded,
          clearError: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          tareWeightKg: liveKg,
          tareWeightText: weightStr,
          tareCapturedAt: now,
          firstWeightType: state.firstWeightType ?? 'TARE',
          status: BillScreenStatus.loaded,
          clearError: true,
        ),
      );
    }
    _recalculate(emit);
  }

  void _onLiveScaleWeightUpdated(
    LiveScaleWeightUpdated event,
    Emitter<BillState> emit,
  ) {
    if (!event.weightKg.isFinite) return;
    emit(
      state.copyWith(
        liveScaleWeightKg: event.weightKg,
        isScaleStable: event.isStable ?? state.isScaleStable,
        isScaleMotion: event.isMotion ?? state.isScaleMotion,
        isScaleOverload: event.isOverload ?? state.isScaleOverload,
      ),
    );
  }

  void _onWeightTypeSelected(
    WeightTypeSelected event,
    Emitter<BillState> emit,
  ) {
    emit(state.copyWith(selectedWeightType: event.type));
  }

  /// Validates all fields in a defined order before saving.
  ///
  /// Returns a map of field errors (field key -> error message).
  Map<String, String> _validateAll() {
    final errors = <String, String>{};

    // ── 1. Truck / Vehicle Number ──────────────────────────────
    final rawVehicle = state.vehicleNumber.trim();
    if (rawVehicle.isEmpty) {
      errors['vehicleNumber'] = 'Truck number is required.';
    }

    // ── 2. Weight presence ────────────────────────────────────
    final hasGross = state.grossWeightKg.isFinite && state.grossWeightKg > 0;
    final hasTare = state.tareWeightKg.isFinite && state.tareWeightKg > 0;
    if (!hasGross && !hasTare) {
      errors['weight'] = 'Enter or capture Gross or Tare weight.';
    } else if (hasGross &&
        (!state.grossWeightKg.isFinite || state.grossWeightKg < 0)) {
      errors['weight'] = 'Gross weight is invalid';
    } else if (hasTare &&
        (!state.tareWeightKg.isFinite || state.tareWeightKg < 0)) {
      errors['weight'] = 'Tare weight is invalid';
    } else if (hasGross &&
        hasTare &&
        state.tareWeightKg >= state.grossWeightKg) {
      errors['weight'] = 'Gross weight must be greater than tare weight.';
    } else if (state.weightValidationError != null) {
      errors['weight'] = state.weightValidationError!;
    } else if (hasGross && state.grossCapturedAt == null) {
      errors['weight'] =
          'Gross weight timestamp is missing. Re-enter the gross weight.';
    } else if (hasTare && state.tareCapturedAt == null) {
      errors['weight'] =
          'Tare weight timestamp is missing. Re-enter the tare weight.';
    }

    // ── 3. Mobile number (optional) ───────────────────────────
    final mobile = state.mobileNumber.trim();
    if (mobile.isNotEmpty) {
      if (!RegExp(r'^\d+$').hasMatch(mobile)) {
        errors['mobile'] = 'Mobile number can contain digits only.';
      }
    }

    return errors;
  }

  Future<void> _onSaveBillRequested(
    SaveBillRequested event,
    Emitter<BillState> emit,
  ) async {
    // Ignore the duplicate half of a single save request; see [_formJustSaved].
    if (_isDuplicateSaveRequest) return;

    final errors = _validateAll();
    if (errors.isNotEmpty) {
      emit(
        state.copyWith(fieldErrors: errors, errorMessage: errors.values.first),
      );
      return;
    }

    emit(
      state.copyWith(
        status: BillScreenStatus.saving,
        clearError: true,
        clearFieldErrors: true,
      ),
    );

    try {
      await _insertNewBill(emit);
      if (emit.isDone) return;
      final bills = await _loadBillsFor(state.effectiveBillsDate);
      if (emit.isDone) return;
      emit(state.copyWith(status: BillScreenStatus.saved, recentBills: bills));
      _formJustSaved = state;
    } catch (e) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage: 'Failed to save bill: $e',
        ),
      );
    }
  }

  Future<void> _onSaveAndPrintBillRequested(
    SaveAndPrintBillRequested event,
    Emitter<BillState> emit,
  ) async {
    // Ignore the duplicate half of a single Ctrl+S; see [_formJustSaved].
    if (_isDuplicateSaveRequest) return;

    final errors = _validateAll();
    if (errors.isNotEmpty) {
      emit(
        state.copyWith(fieldErrors: errors, errorMessage: errors.values.first),
      );
      return;
    }

    emit(
      state.copyWith(
        status: BillScreenStatus.printing,
        clearError: true,
        clearFieldErrors: true,
      ),
    );

    try {
      final savedBill = await _insertNewBill(emit);
      if (emit.isDone) return;
      final bills = await _loadBillsFor(state.effectiveBillsDate);
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: BillScreenStatus.printing,
          recentBills: bills,
          printReceiptBill: savedBill,
        ),
      );
      _formJustSaved = state;
    } catch (e) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage: 'Failed to save bill: $e',
        ),
      );
    }
  }

  void _onPrintReceiptDismissed(
    PrintReceiptDismissed event,
    Emitter<BillState> emit,
  ) {
    emit(
      state.copyWith(clearPrintReceipt: true, status: BillScreenStatus.loaded),
    );
  }

  /// Persists the active form as a brand new bill.
  ///
  /// There is deliberately no update path: a saved bill is an immutable
  /// historical record and is never edited in place. Every save allocates a
  /// fresh serial number inside the database insert transaction.
  Future<Weighment> _insertNewBill(Emitter<BillState> emit) async {
    // Persist the first captured weight and leave the second absent until
    // the truck returns for its other weighing.
    final firstWeightType =
        state.firstWeightType?.toUpperCase() ??
        (state.grossWeightKg > 0 ? 'GROSS' : 'TARE');
    final firstWeightKg = firstWeightType == 'GROSS'
        ? state.grossWeightKg
        : state.tareWeightKg;
    final secondWeight = firstWeightType == 'GROSS'
        ? state.tareWeightKg
        : state.grossWeightKg;
    final secondWeightKg = secondWeight > 0 ? secondWeight : null;
    final secondWeightType = secondWeightKg == null
        ? null
        : (firstWeightType == 'GROSS' ? 'TARE' : 'GROSS');

    // The billing time of this bill is the moment it is saved. It is
    // deliberately not derived from the weight capture fields: those may carry
    // the day's shared Auto Tare reference time, which is identical for every
    // bill weighed that day and would make Recent Billings show one frozen
    // timestamp instead of when each bill was actually created.
    //
    // [updatedAt] is stamped with the same moment so a two-weight bill can
    // never end up with an `updatedAt` older than its `createdAt`.
    final createdAt = DateTime.now();
    final updatedAt = createdAt;

    final netWeight = (state.grossWeightKg > 0 && state.tareWeightKg > 0)
        ? (state.grossWeightKg - state.tareWeightKg).abs()
        : null;

    final grossCapturedAt = state.grossWeightKg > 0
        ? (state.grossCapturedAt ?? createdAt)
        : null;
    final tareCapturedAt = state.tareWeightKg > 0
        ? (state.tareCapturedAt ?? createdAt)
        : null;

    final weighment = Weighment(
      id: 0,
      // Placeholder only: the serial number is allocated by the database
      // inside the insert transaction. The value stored on the returned row is
      // authoritative and replaces this immediately below.
      billNumber: state.currentBillNumber,
      vehicleNumber: state.vehicleNumber.trim().toUpperCase(),
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
      secondWeightType: secondWeightType,
      netWeightKg: netWeight,
      grossCapturedAt: grossCapturedAt,
      tareCapturedAt: tareCapturedAt,
      material: state.materialText.trim().isNotEmpty
          ? state.materialText.trim()
          : null,
      description: state.descriptionText.trim().isNotEmpty
          ? state.descriptionText.trim()
          : null,
      remarks: state.remarksText.isNotEmpty ? state.remarksText : null,
      mobileNumber: null,
      weightUnit: state.weightUnit,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    // A new bill never reuses the previewed serial number. The database
    // allocates it inside the insert transaction, which is the only place
    // that can guarantee the number is unused, and the returned value is what
    // gets displayed, printed and stored on the saved weighment.
    final result = await _saveBillUseCase.withNewBillNumber(weighment);

    final savedWeighment = Weighment(
      id: result.id,
      billNumber: result.billNumber,
      vehicleNumber: weighment.vehicleNumber,
      firstWeightKg: weighment.firstWeightKg,
      firstWeightType: weighment.firstWeightType,
      secondWeightKg: weighment.secondWeightKg,
      secondWeightType: weighment.secondWeightType,
      netWeightKg: weighment.explicitNetWeightKg,
      grossCapturedAt: weighment.grossCapturedAt,
      tareCapturedAt: weighment.tareCapturedAt,
      material: weighment.material,
      description: weighment.description,
      remarks: weighment.remarks,
      mobileNumber: weighment.mobileNumber,
      weightUnit: weighment.weightUnit,
      createdAt: weighment.createdAt,
      updatedAt: weighment.updatedAt,
    );

    final nextBillNumber = await _generateBillNumberUseCase();
    String unit = 'kg';
    if (_settingsRepository != null) {
      final settings = await _settingsRepository.getSettings();
      unit = _normalizeUnit(settings.weightUnit);
    }
    _resetForm(emit, nextBillNumber: nextBillNumber, weightUnit: unit);

    return savedWeighment;
  }

  Future<void> _onClearBillRequested(
    ClearBillRequested event,
    Emitter<BillState> emit,
  ) async {
    final billNumber = await _generateBillNumberUseCase();
    if (emit.isDone) return;
    String unit = 'kg';
    if (_settingsRepository != null) {
      final settings = await _settingsRepository.getSettings();
      unit = _normalizeUnit(settings.weightUnit);
    }
    _resetForm(emit, nextBillNumber: billNumber, weightUnit: unit);
  }

  void _resetForm(
    Emitter<BillState> emit, {
    required String nextBillNumber,
    String? weightUnit,
  }) {
    emit(
      state.copyWith(
        vehicleNumber: '',
        clearFirstWeightType: true,
        grossWeightText: '',
        tareWeightText: '',
        remarksText: '',
        materialText: '',
        descriptionText: '',
        mobileNumber: '',
        grossWeightKg: 0,
        tareWeightKg: 0,
        netWeightKg: 0,
        currentBillNumber: nextBillNumber,
        formResetRevision: state.formResetRevision + 1,
        clearError: true,
        clearWeightError: true,
        clearGrossCapturedAt: true,
        clearTareCapturedAt: true,
        clearFieldErrors: true,
        weightUnit: weightUnit ?? state.weightUnit,
      ),
    );
  }

  Future<void> _onLoadRecentBills(
    LoadRecentBills event,
    Emitter<BillState> emit,
  ) async {
    try {
      if (event.startDate != null && event.endDate != null) {
        final bills = await _loadRecentBillsUseCase.byDateRange(
          startDate: _dayOnly(event.startDate!),
          endDate: _dayOnly(event.endDate!),
        );
        if (emit.isDone) return;
        emit(
          state.copyWith(
            recentBills: bills,
            billsStartDate: _dayOnly(event.startDate!),
            billsEndDate: _dayOnly(event.endDate!),
            clearDateRange: false,
          ),
        );
      } else {
        final billsDate = _dayOnly(event.date ?? DateTime.now());
        final bills = await _loadBillsFor(billsDate);
        if (emit.isDone) return;
        emit(
          state.copyWith(
            recentBills: bills,
            billsDate: billsDate,
            clearDateRange: true,
          ),
        );
      }
    } catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(errorMessage: 'Failed to load recent bills'));
    }
  }

  DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<List<Weighment>> _loadBillsFor(DateTime date) {
    return _loadRecentBillsUseCase(date: _dayOnly(date));
  }
}
