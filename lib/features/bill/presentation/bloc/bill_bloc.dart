import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../material/domain/entities/material_item.dart';
import '../../../material/domain/repositories/material_repository.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/usecases/save_bill.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final SaveBillUseCase _saveBillUseCase;
  final LoadRecentBillsUseCase _loadRecentBillsUseCase;
  final GenerateBillNumberUseCase _generateBillNumberUseCase;

  /// Looks up the previous single-weight bill of a returning truck.
  ///
  /// Optional so older unit tests that construct the bloc without it keep
  /// compiling; without it the SECOND WEIGHT lookup reports no match.
  final GetPreviousWeighmentUseCase? _previousWeighmentUseCase;
  final SettingsRepository? _settingsRepository;

  /// Monotonic token for previous-weighment lookups.
  ///
  /// Vehicle-number edits fire a lookup per change, so two lookups can be in
  /// flight at once against the default concurrent transformer. A result is
  /// applied only while its token is still the newest, which stops a slow
  /// query for an earlier vehicle number from repopulating stale weights
  /// after a newer one already answered.
  int _previousWeightLookupSeq = 0;

  /// Master data for the material dropdown. When null (e.g. in older unit
  /// tests that don't wire it), the material field falls back to plain text.
  final MaterialRepository? _materialRepository;

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
        saved.chargesText == state.chargesText &&
        saved.remarksText == state.remarksText;
  }

  BillBloc({
    required SaveBillUseCase saveBillUseCase,
    required LoadRecentBillsUseCase loadRecentBillsUseCase,
    required GenerateBillNumberUseCase generateBillNumberUseCase,
    GetPreviousWeighmentUseCase? previousWeighmentUseCase,
    SettingsRepository? settingsRepository,
    MaterialRepository? materialRepository,
  }) : _saveBillUseCase = saveBillUseCase,
       _loadRecentBillsUseCase = loadRecentBillsUseCase,
       _generateBillNumberUseCase = generateBillNumberUseCase,
       _previousWeighmentUseCase = previousWeighmentUseCase,
       _settingsRepository = settingsRepository,
       _materialRepository = materialRepository,
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
    on<ChargesChanged>(_onChargesChanged);
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
    on<SecondWeightModeChanged>(_onSecondWeightModeChanged);
    on<FetchPreviousWeightForVehicle>(_onFetchPreviousWeightForVehicle);
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

      final materials = await _loadMaterialOptions();

      emit(
        state.copyWith(
          status: BillScreenStatus.loaded,
          recentBills: recentBills,
          billsDate: billsDate,
          currentBillNumber: billNumber,
          weightUnit: unit,
          materialOptions: materials,
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

  /// Refreshes the bill number, recent bills and material options without
  /// touching anything the operator has already entered on the form.
  Future<void> _onRefreshBillLookups(
    RefreshBillLookups event,
    Emitter<BillState> emit,
  ) async {
    try {
      final bills = await _loadBillsFor(state.effectiveBillsDate);
      final materials = await _loadMaterialOptions();
      if (emit.isDone) return;
      emit(state.copyWith(recentBills: bills, materialOptions: materials));
    } catch (_) {
      // A failed refresh must not disturb the form.
      return;
    }
  }

  /// Active materials for the dropdown, or an empty list when the material
  /// feature is not wired (older tests / manual construction).
  Future<List<MaterialItem>> _loadMaterialOptions() async {
    final repository = _materialRepository;
    if (repository == null) return const [];
    try {
      return await repository.getActive();
    } catch (_) {
      // A failed material load must not block bill entry.
      return const [];
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
    final normalized = event.vehicleNumber.trim().toUpperCase();
    final vehicleChanged = normalized != state.vehicleNumber;

    var updated = state.copyWith(
      vehicleNumber: normalized,
      fieldErrors: updatedErrors,
      clearError: true,
    );

    // A different vehicle makes any previously matched bill and its
    // populated weight stale; drop the match, the operator-facing note and
    // the weight that came from it, so they can never be saved against the
    // new number while the fresh lookup runs.
    if (vehicleChanged) {
      updated = _clearPreviousWeightData(updated);
      if (state.isSecondWeightMode) {
        updated = updated.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeightMessage: true,
        );
      }
    }

    emit(updated);

    // Typing over the number in SECOND WEIGHT mode must re-run the search so
    // the correct record is retrieved for the newly entered vehicle.
    if (vehicleChanged && state.isSecondWeightMode) {
      add(const FetchPreviousWeightForVehicle());
    }
  }

  /// Drops the matched previous bill and the weight that was populated
  /// from it, leaving the operator's own captured weight untouched.
  BillState _clearPreviousWeightData(BillState state) {
    final previous = state.previousWeighment;
    var updated = state.copyWith(
      clearPreviousWeighment: true,
      clearPreviousWeightMessage: true,
      isFetchingPreviousWeight: false,
    );
    if (previous == null) return updated;

    // The populated field is the one holding the previous bill's weight
    // type; the opposite field is where the operator captures the current
    // weight, and it must survive untouched.
    final previousIsTare = previous.firstWeightType.toUpperCase() == 'TARE';
    updated = previousIsTare
        ? updated.copyWith(
            tareWeightText: '',
            tareWeightKg: 0,
            clearTareCapturedAt: true,
            clearFirstWeightType: true,
          )
        : updated.copyWith(
            grossWeightText: '',
            grossWeightKg: 0,
            clearGrossCapturedAt: true,
            clearFirstWeightType: true,
          );
    return updated.copyWith(netWeightKg: 0);
  }

  /// Toggles the SECOND WEIGHT workflow.
  ///
  /// Both directions drop every weight and second-weight artefact (matched
  /// bill, populated weight, messages), so a mode change can never carry
  /// stale state into the restored form. The vehicle number, material and
  /// charges the operator typed are kept: they are not second-weight state.
  void _onSecondWeightModeChanged(
    SecondWeightModeChanged event,
    Emitter<BillState> emit,
  ) {
    if (event.enabled == state.isSecondWeightMode) return;

    emit(
      _clearWeightsAndSecondWeightArtifacts(
        state.copyWith(
          isSecondWeightMode: event.enabled,
          // Leaving the mode restores the default GROSS capture target so
          // F1 never fires into a field the previous mode dictated.
          selectedWeightType: event.enabled
              ? state.selectedWeightType
              : 'Gross',
        ),
      ),
    );

    if (event.enabled && state.vehicleNumber.trim().isNotEmpty) {
      add(const FetchPreviousWeightForVehicle());
    }
  }

  /// Clears both weight fields, their capture timestamps and every
  /// second-weight artefact, while leaving the rest of the form intact.
  BillState _clearWeightsAndSecondWeightArtifacts(BillState state) {
    return state.copyWith(
      grossWeightText: '',
      grossWeightKg: 0,
      tareWeightText: '',
      tareWeightKg: 0,
      netWeightKg: 0,
      clearGrossCapturedAt: true,
      clearTareCapturedAt: true,
      clearFirstWeightType: true,
      clearWeightError: true,
      clearPreviousWeighment: true,
      clearPreviousWeightMessage: true,
      isFetchingPreviousWeight: false,
    );
  }

  /// Looks up the previous single-weight bill for the entered vehicle.
  Future<void> _onFetchPreviousWeightForVehicle(
    FetchPreviousWeightForVehicle event,
    Emitter<BillState> emit,
  ) async {
    if (!state.isSecondWeightMode) return;

    final vehicle = state.vehicleNumber.trim().toUpperCase();
    final lookupId = ++_previousWeightLookupSeq;

    if (vehicle.isEmpty) {
      emit(
        state.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeighment: true,
          clearPreviousWeightMessage: true,
        ),
      );
      return;
    }

    final useCase = _previousWeighmentUseCase;
    if (useCase == null) {
      emit(
        state.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeighment: true,
          previousWeightMessage:
              'Previous weighments are unavailable. Return to normal mode '
              'and weigh this truck from scratch.',
        ),
      );
      return;
    }

    emit(state.copyWith(isFetchingPreviousWeight: true));

    Weighment? previous;
    try {
      previous = await useCase(vehicle);
    } catch (e) {
      // A failed lookup surfaces as a message, never as an exception that
      // would leave the form stuck in the fetching state.
      if (lookupId != _previousWeightLookupSeq || emit.isDone) return;
      emit(
        state.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeighment: true,
          previousWeightMessage:
              'Could not search previous weighments: $e. '
              'Return to normal mode or try again.',
        ),
      );
      return;
    }

    // A newer lookup owns the form now; this result is stale and dropped.
    if (lookupId != _previousWeightLookupSeq || emit.isDone) return;

    if (previous == null) {
      emit(
        state.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeighment: true,
          previousWeightMessage:
              'No previous weighment found for $vehicle. '
              'Check the number or return to normal mode.',
        ),
      );
      return;
    }

    // The previous bill must carry exactly one usable weight; anything else
    // would make the second weighing's net weight wrong.
    final previousIsTare = previous.firstWeightType.toUpperCase() == 'TARE';
    final previousWeightKg = previousIsTare
        ? previous.tareWeightKg
        : previous.grossWeightKg;
    if (previousWeightKg == null ||
        !previousWeightKg.isFinite ||
        previousWeightKg <= 0) {
      emit(
        state.copyWith(
          isFetchingPreviousWeight: false,
          clearPreviousWeighment: true,
          previousWeightMessage:
              'The previous weighment ${previous.billNumber} for $vehicle '
              'has invalid weight data and cannot be used. '
              'Return to normal mode and weigh this truck from scratch.',
        ),
      );
      return;
    }

    // The previous weight is displayed in its own field (converted to the
    // form's unit) and locked; the operator captures the opposite weight.
    final displayValue = _fromKg(previousWeightKg, state.weightUnit);
    final text = _formatWeightText(displayValue, state.weightUnit);

    emit(
      state.copyWith(
        isFetchingPreviousWeight: false,
        previousWeighment: previous,
        clearPreviousWeightMessage: true,
        firstWeightType: previousIsTare ? 'TARE' : 'GROSS',
        selectedWeightType: previousIsTare ? 'Gross' : 'Tare',
        grossWeightText: previousIsTare ? '' : text,
        grossWeightKg: previousIsTare ? 0 : previousWeightKg,
        clearGrossCapturedAt: previousIsTare,
        grossCapturedAt: previousIsTare ? null : previous.createdAt,
        tareWeightText: previousIsTare ? text : '',
        tareWeightKg: previousIsTare ? previousWeightKg : 0,
        clearTareCapturedAt: !previousIsTare,
        tareCapturedAt: previousIsTare ? previous.createdAt : null,
      ),
    );
    _recalculate(emit);
  }

  double _fromKg(double valueKg, String unit) {
    return _normalizeUnit(unit) == 'ton' ? valueKg / 1000 : valueKg;
  }

  String _formatWeightText(double displayValue, String unit) {
    return _normalizeUnit(unit) == 'ton'
        ? displayValue.toStringAsFixed(3)
        : displayValue.toStringAsFixed(0);
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
    emit(
      state.copyWith(
        grossWeightText: event.value,
        grossWeightKg: kgValue,
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
    emit(
      state.copyWith(
        tareWeightText: event.value,
        tareWeightKg: kgValue,
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
    emit(
      state.copyWith(
        materialText: event.value,
        selectedMaterialId: event.materialId,
        clearSelectedMaterialId: event.materialId == null,
      ),
    );
  }

  void _onChargesChanged(ChargesChanged event, Emitter<BillState> emit) {
    // While typing, only clear a stale error once the text parses again; the
    // authoritative validation still runs on save in [_validateAll].
    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    if (event.value.trim().isEmpty || parseChargesInput(event.value) != null) {
      updatedErrors.remove('charges');
    }
    emit(
      state.copyWith(
        chargesText: event.value,
        fieldErrors: updatedErrors,
        clearError: true,
      ),
    );
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
    // In SECOND WEIGHT mode the previous weighment decides which field is
    // locked and which one is captured now. Capturing before the lookup
    // answered would put the live weight into an ambiguous field, so it is
    // refused until a previous bill is matched.
    if (state.isSecondWeightMode && state.previousWeighment == null) {
      emit(
        state.copyWith(
          status: BillScreenStatus.error,
          errorMessage:
              'Enter the truck number to retrieve its previous weighment '
              'before capturing weight.',
        ),
      );
      return;
    }
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
      emit(
        state.copyWith(
          grossWeightKg: liveKg,
          grossWeightText: weightStr,
          grossCapturedAt: now,
          firstWeightType: state.firstWeightType ?? 'GROSS',
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

    // ── 2b. Second-weight workflow ───────────────────────────
    // A second weighing pairs a retrieved previous weight with the weight
    // captured now, so both must be present before the bill can be saved.
    if (state.isSecondWeightMode) {
      if (state.previousWeighment == null) {
        errors['vehicleNumber'] =
            state.previousWeightMessage ?? 'Retrieve the previous weighment.';
      } else if (!hasGross || !hasTare) {
        errors['weight'] =
            'Capture the current weight to complete the second weighing.';
      } else if (state.weightValidationError != null) {
        // Gross/tare relationship could not be validated (e.g. tare >= gross).
        errors['weight'] = state.weightValidationError!;
      }
    }

    // ── 3. Mobile number (optional) ───────────────────────────
    final mobile = state.mobileNumber.trim();
    if (mobile.isNotEmpty) {
      if (!RegExp(r'^\d+$').hasMatch(mobile)) {
        errors['mobile'] = 'Mobile number can contain digits only.';
      }
    }

    // ── 4. Charges (optional) ─────────────────────────────────
    // Empty is valid (no charge); anything typed must be a non-negative
    // amount with at most two decimals.
    final chargesText = state.chargesText.trim();
    if (chargesText.isNotEmpty && parseChargesInput(chargesText) == null) {
      errors['charges'] = 'Enter a valid amount (digits, up to two decimals).';
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
    // deliberately not derived from the weight capture fields, so Recent
    // Billings always shows when each bill was actually created rather than
    // when a weight was captured.
    //
    // [updatedAt] is stamped with the same moment so a two-weight bill can
    // never end up with an `updatedAt` older than its `createdAt`.
    final createdAt = DateTime.now();
    final updatedAt = createdAt;

    final netWeight = (state.grossWeightKg > 0 && state.tareWeightKg > 0)
        ? (state.grossWeightKg - state.tareWeightKg).abs()
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
      material: state.materialText.trim().isNotEmpty
          ? state.materialText.trim()
          : null,
      materialId: state.selectedMaterialId,
      // Manually entered charges: empty means no charge (NULL), a valid
      // amount is stored exactly as typed (never recalculated).
      charges: parseChargesInput(state.chargesText),
      // Traceable link to the single-weight bill this second weighing
      // completes. Normal weighments store NULL. The original bill itself is
      // never modified: this is a one-way reference on the new row only.
      previousWeighmentId: state.isSecondWeightMode
          ? state.previousWeighment?.id
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
      material: weighment.material,
      materialId: weighment.materialId,
      charges: weighment.charges,
      previousWeighmentId: weighment.previousWeighmentId,
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
    // A reset always returns to the default normal-weighment form. Any
    // in-flight previous-weight lookup is invalidated so its late result can
    // never repopulate the freshly cleared form.
    _previousWeightLookupSeq++;
    emit(
      state.copyWith(
        vehicleNumber: '',
        clearFirstWeightType: true,
        grossWeightText: '',
        tareWeightText: '',
        remarksText: '',
        materialText: '',
        clearSelectedMaterialId: true,
        chargesText: '',
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
        // SECOND WEIGHT mode does not survive a reset: the next truck starts
        // a fresh normal weighment. The capture target returns to the
        // default only when the reset actually leaves the mode, so a normal
        // save keeps the operator's GROSS/TARE selection as before.
        isSecondWeightMode: false,
        isFetchingPreviousWeight: false,
        clearPreviousWeighment: true,
        clearPreviousWeightMessage: true,
        selectedWeightType: state.isSecondWeightMode
            ? 'Gross'
            : state.selectedWeightType,
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
