import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../customer/domain/entities/customer.dart';
import '../../../customer/domain/repositories/customer_repository.dart';
import '../../../material/domain/entities/material_item.dart';
import '../../../material/domain/repositories/material_item_repository.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/entities/auto_tare_entry.dart';
import '../../domain/usecases/save_bill.dart';
import '../../domain/repositories/auto_tare_repository.dart';
import '../../domain/usecases/get_auto_tare_for_date.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import 'bill_auto_tare_handlers.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> with BillAutoTareHandlers {
  final CustomerRepository _customerRepository;

  CustomerRepository get customerRepository => _customerRepository;

  final MaterialItemRepository _materialRepository;

  MaterialItemRepository get materialRepository => _materialRepository;

  Future<Customer?> findCustomerByCode(String code) async {
    final customer = await _customerRepository.getCustomerByCode(code.trim());
    if (customer == null || !customer.isActive) return null;
    return customer;
  }

  Future<MaterialItem?> findMaterialByCode(String code) async {
    final material = await _materialRepository.getMaterialByCode(code.trim());
    if (material == null || !material.isActive) return null;
    return material;
  }

  final SaveBillUseCase _saveBillUseCase;
  final LoadRecentBillsUseCase _loadRecentBillsUseCase;
  final GenerateBillNumberUseCase _generateBillNumberUseCase;
  final SettingsRepository? _settingsRepository;
  final AutoTareRepository? _autoTareRepository;

  @override
  AutoTareRepository? get autoTareRepository => _autoTareRepository;

  @override
  void recalculateWeights(Emitter<BillState> emit) => _recalculate(emit);

  BillBloc({
    required CustomerRepository customerRepository,
    required MaterialItemRepository materialRepository,
    required SaveBillUseCase saveBillUseCase,
    required LoadRecentBillsUseCase loadRecentBillsUseCase,
    required GenerateBillNumberUseCase generateBillNumberUseCase,
    SettingsRepository? settingsRepository,
    AutoTareRepository? autoTareRepository,
  }) : _customerRepository = customerRepository,
       _materialRepository = materialRepository,
       _saveBillUseCase = saveBillUseCase,
       _loadRecentBillsUseCase = loadRecentBillsUseCase,
       _generateBillNumberUseCase = generateBillNumberUseCase,
       _settingsRepository = settingsRepository,
       _autoTareRepository = autoTareRepository,
       super(const BillState()) {
    on<LoadBillScreen>(_onLoadBillScreen);
    on<CustomerSelected>(_onCustomerSelected);
    on<VehicleNumberChanged>(_onVehicleNumberChanged);
    on<MaterialSelected>(_onMaterialSelected);
    on<GrossWeightChanged>(_onGrossWeightChanged);
    on<TareWeightChanged>(_onTareWeightChanged);
    on<GrossWeightCommitted>(_onGrossWeightCommitted);
    on<TareWeightCommitted>(_onTareWeightCommitted);
    on<GrossCapturedAtChanged>(_onGrossCapturedAtChanged);
    on<TareCapturedAtChanged>(_onTareCapturedAtChanged);
    on<LoadBillForEdit>(_onLoadBillForEdit);
    on<RemarksChanged>(_onRemarksChanged);
    on<PaymentModeChanged>(_onPaymentModeChanged);
    on<WeightUnitChanged>(_onWeightUnitChanged);
    on<VehicleChargeChanged>(_onVehicleChargeChanged);
    on<ResetVehicleCharge>(_onResetVehicleCharge);
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
    on<CustomerQuickAddRequested>(_onCustomerQuickAdd);
    on<MaterialQuickAddRequested>(_onMaterialQuickAdd);
    on<MaterialCreatedToState>(_onMaterialCreatedToState);
    on<CustomerCreatedToState>(_onCustomerCreatedToState);
    on<CaptureLiveWeight>(_onCaptureLiveWeight);
    on<LiveScaleWeightUpdated>(_onLiveScaleWeightUpdated);
    on<WeightTypeSelected>(_onWeightTypeSelected);
    on<MobileNumberChanged>(_onMobileNumberChanged);
    on<LoadAutoTare>(handleLoadAutoTare);
    on<SaveAutoTare>(handleSaveAutoTare);
    on<DeleteAutoTare>(handleDeleteAutoTare);
    on<ApplyAutoTareToBill>(handleApplyAutoTareToBill);
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
      final customers = await _customerRepository.getAllActiveCustomers();
      if (emit.isDone) return;
      final materials = await _materialRepository.getMaterialsByStatus(
        isActive: true,
      );
      if (emit.isDone) return;
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

      emit(
        state.copyWith(
          status: BillScreenStatus.loaded,
          customers: customers,
          materials: materials,
          recentBills: recentBills,
          billsDate: billsDate,
          currentBillNumber: billNumber,
          weightUnit: unit,
          autoTareKg: autoTare?.tareKg ?? 0,
          autoTareDate: autoTare?.tareDate,
          clearAutoTare: autoTare == null,
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

  void _onCustomerSelected(CustomerSelected event, Emitter<BillState> emit) {
    final updatedErrors = Map<String, String>.from(state.fieldErrors)
      ..remove('customer');
    final mobile = (event.customer.mobile ?? '').trim();
    if (mobile.isEmpty || RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      updatedErrors.remove('mobile');
    }
    emit(
      state.copyWith(
        selectedCustomer: event.customer,
        mobileNumber: event.customer.mobile ?? '',
        fieldErrors: updatedErrors,
        clearError: true,
      ),
    );
  }

  void _onMobileNumberChanged(
    MobileNumberChanged event,
    Emitter<BillState> emit,
  ) {
    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    final trimmed = event.value.trim();
    if (trimmed.isEmpty || RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed)) {
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
    final trimmed = event.vehicleNumber.trim().toUpperCase();
    if (RegExp(r'^[A-Z0-9]{10}$').hasMatch(trimmed)) {
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

  void _onMaterialSelected(MaterialSelected event, Emitter<BillState> emit) {
    final updatedErrors = Map<String, String>.from(state.fieldErrors)
      ..remove('material');
    emit(
      state.copyWith(
        selectedMaterial: event.material,
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
        editingFirstWeightType: state.editingFirstWeightType ?? 'GROSS',
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
        editingFirstWeightType: state.editingFirstWeightType ?? 'TARE',
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

  void _onLoadBillForEdit(LoadBillForEdit event, Emitter<BillState> emit) {
    final bill = event.bill;
    final customer = state.customers
        .where((c) => c.id == bill.customerId)
        .firstOrNull;
    final material = state.materials
        .where((m) => m.id == bill.materialId)
        .firstOrNull;

    final isTon = bill.weightUnit.toLowerCase() == 'ton';
    final gw = bill.grossWeightKg ?? 0;
    final tw = bill.tareWeightKg ?? 0;

    String grossText = '';
    if (gw > 0) {
      grossText = isTon
          ? (gw / 1000).toStringAsFixed(3)
          : gw.toStringAsFixed(0);
    }
    String tareText = '';
    if (tw > 0) {
      tareText = isTon ? (tw / 1000).toStringAsFixed(3) : tw.toStringAsFixed(0);
    }

    emit(
      state.copyWith(
        editingBillId: bill.id,
        currentBillNumber: bill.billNumber,
        selectedCustomer: customer,
        vehicleNumber: bill.vehicleNumber,
        selectedMaterial: material,
        paymentMode: bill.paymentMode,
        editingFirstWeightType: bill.firstWeightType,
        editingFirstWeightKg: bill.firstWeightKg,
        editingBillCreatedAt: bill.createdAt,
        grossWeightKg: gw,
        grossWeightText: grossText,
        grossCapturedAt: bill.grossCapturedAt,
        tareWeightKg: tw,
        tareWeightText: tareText,
        tareCapturedAt: bill.tareCapturedAt,
        netWeightKg: bill.netWeightKg ?? 0,
        vehicleCharge: bill.vehicleCharge,
        amount: bill.amount,
        remarksText: bill.remarks ?? '',
        weightUnit: bill.weightUnit,
        clearError: true,
      ),
    );
    _recalculate(emit);
  }

  void _onRemarksChanged(RemarksChanged event, Emitter<BillState> emit) {
    emit(state.copyWith(remarksText: event.value));
  }

  void _onPaymentModeChanged(
    PaymentModeChanged event,
    Emitter<BillState> emit,
  ) {
    emit(state.copyWith(paymentMode: event.value));
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

  void _onVehicleChargeChanged(
    VehicleChargeChanged event,
    Emitter<BillState> emit,
  ) {
    final value = double.tryParse(event.value) ?? 0;
    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    if (value > 0) {
      updatedErrors.remove('charges');
    }
    emit(
      state.copyWith(
        vehicleCharge: value,
        amount: value,
        fieldErrors: updatedErrors,
        clearError: true,
      ),
    );
  }

  void _onResetVehicleCharge(
    ResetVehicleCharge event,
    Emitter<BillState> emit,
  ) {
    emit(state.copyWith(vehicleCharge: 0, amount: 0, clearError: true));
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
          editingFirstWeightType: state.editingFirstWeightType ?? 'GROSS',
          tareWeightKg: shouldApplyAutoTare ? autoTareKg : null,
          tareWeightText: shouldApplyAutoTare ? autoTareText : null,
          tareCapturedAt: shouldApplyAutoTare ? now : null,
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
          editingFirstWeightType: state.editingFirstWeightType ?? 'TARE',
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
  /// Validates all fields in a defined order before saving.
  /// Returns a map of field errors (field key -> error message).
  Map<String, String> _validateAll() {
    final errors = <String, String>{};

    // ── 1. Truck / Vehicle Number ──────────────────────────────
    final rawVehicle = state.vehicleNumber.trim();
    if (rawVehicle.isEmpty) {
      errors['vehicleNumber'] = 'Truck number is required.';
    } else if (!RegExp(r'^[A-Z0-9]{10}$').hasMatch(rawVehicle.toUpperCase())) {
      errors['vehicleNumber'] =
          'Truck number must be exactly 10 alphanumeric characters.';
    }

    // ── 2. Material ───────────────────────────────────────────
    if (state.selectedMaterial == null) {
      errors['material'] = 'Material code is required.';
    }

    // ── 3. Customer ───────────────────────────────────────────
    if (state.selectedCustomer == null) {
      errors['customer'] = 'Customer code is required.';
    }

    // ── 4. Charges / Amount ───────────────────────────────────
    if (state.vehicleCharge <= 0 && state.amount <= 0) {
      errors['charges'] = 'Weighment charge is required.';
    }

    // ── 5. Weight presence ────────────────────────────────────
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

    // ── 6. Mobile number (optional) ───────────────────────────
    final mobile = state.mobileNumber.trim();
    if (mobile.isNotEmpty) {
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
        errors['mobile'] =
            'Enter a valid 10-digit mobile number (starting with 6, 7, 8 or 9).';
      }
    }

    return errors;
  }

  Future<void> _onSaveBillRequested(
    SaveBillRequested event,
    Emitter<BillState> emit,
  ) async {
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
      await _saveOrUpdateBill(emit);
      if (emit.isDone) return;
      final bills = await _loadBillsFor(state.effectiveBillsDate);
      if (emit.isDone) return;
      emit(state.copyWith(status: BillScreenStatus.saved, recentBills: bills));
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
      final savedData = await _saveOrUpdateBill(emit);
      if (emit.isDone) return;
      final bills = await _loadBillsFor(state.effectiveBillsDate);
      if (emit.isDone) return;
      emit(
        state.copyWith(
          status: BillScreenStatus.printing,
          recentBills: bills,
          printReceiptBill: savedData.bill,
          printReceiptCustomer: savedData.customer,
          printReceiptMaterialName: savedData.materialName,
        ),
      );
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

  Future<({Weighment bill, Customer? customer, String materialName})>
  _saveOrUpdateBill(Emitter<BillState> emit) async {
    final savedCustomer = state.selectedCustomer;
    final savedMaterialName = state.selectedMaterial?.name ?? '—';
    double firstWeightKg;
    String firstWeightType;
    double? secondWeightKg;
    String? secondWeightType;

    if (state.isEditing) {
      final origFirstType =
          state.editingFirstWeightType?.toUpperCase() ??
          (state.editingFirstWeightKg != null && state.editingFirstWeightKg! > 0
              ? 'GROSS'
              : (state.tareWeightKg > 0 ? 'TARE' : 'GROSS'));

      if (origFirstType == 'TARE') {
        firstWeightKg = state.editingFirstWeightKg ?? state.tareWeightKg;
        firstWeightType = 'TARE';
        secondWeightKg = state.grossWeightKg > 0 ? state.grossWeightKg : null;
        secondWeightType = state.grossWeightKg > 0 ? 'GROSS' : null;
      } else {
        firstWeightKg = state.editingFirstWeightKg ?? state.grossWeightKg;
        firstWeightType = 'GROSS';
        secondWeightKg = state.tareWeightKg > 0 ? state.tareWeightKg : null;
        secondWeightType = state.tareWeightKg > 0 ? 'TARE' : null;
      }
    } else {
      // Persist the first captured weight and leave the second absent until
      // the truck returns for its other weighing.
      firstWeightType =
          state.editingFirstWeightType?.toUpperCase() ??
          (state.grossWeightKg > 0 ? 'GROSS' : 'TARE');
      firstWeightKg = firstWeightType == 'GROSS'
          ? state.grossWeightKg
          : state.tareWeightKg;
      final secondWeight = firstWeightType == 'GROSS'
          ? state.tareWeightKg
          : state.grossWeightKg;
      secondWeightKg = secondWeight > 0 ? secondWeight : null;
      secondWeightType = secondWeightKg == null
          ? null
          : (firstWeightType == 'GROSS' ? 'TARE' : 'GROSS');
    }

    final DateTime createdAt;
    final DateTime updatedAt;

    if (state.isEditing) {
      createdAt = state.editingBillCreatedAt ?? DateTime.now();
      updatedAt =
          (secondWeightType == 'GROSS'
              ? state.grossCapturedAt
              : state.tareCapturedAt) ??
          DateTime.now();
    } else {
      createdAt =
          (firstWeightType == 'GROSS'
              ? state.grossCapturedAt
              : state.tareCapturedAt) ??
          DateTime.now();
      if (secondWeightKg != null && secondWeightKg > 0) {
        updatedAt =
            (secondWeightType == 'GROSS'
                ? state.grossCapturedAt
                : state.tareCapturedAt) ??
            createdAt;
      } else {
        updatedAt = createdAt;
      }
    }

    final netWeight = (state.grossWeightKg > 0 && state.tareWeightKg > 0)
        ? (state.grossWeightKg - state.tareWeightKg).abs()
        : null;

    int savedId = state.editingBillId ?? 0;

    final weighment = Weighment(
      id: savedId,
      // Placeholder only: a new bill's number is allocated by the database
      // inside the insert transaction. The value stored on the returned row is
      // authoritative and replaces this immediately below.
      billNumber: state.currentBillNumber,
      customerId: state.selectedCustomer!.id,
      vehicleNumber: state.vehicleNumber.trim().toUpperCase(),
      materialId: state.selectedMaterial!.id,
      paymentMode: state.paymentMode,
      firstWeightKg: firstWeightKg,
      firstWeightType: firstWeightType,
      secondWeightKg: secondWeightKg,
      secondWeightType: secondWeightType,
      netWeightKg: netWeight,
      vehicleCharge: state.vehicleCharge,
      amount: state.amount,
      remarks: state.remarksText.isNotEmpty ? state.remarksText : null,
      weightUnit: state.weightUnit,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    String savedBillNumber;

    if (state.isEditing) {
      await _saveBillUseCase.updateWeighment(state.editingBillId!, weighment);
      savedId = state.editingBillId!;
      savedBillNumber = weighment.billNumber;
    } else {
      // A new bill never reuses the previewed serial number. The database
      // allocates it inside the insert transaction, which is the only place
      // that can guarantee the number is unused, and the returned value is what
      // gets displayed, printed and stored on the saved weighment.
      final result = await _saveBillUseCase.withNewBillNumber(weighment);
      savedId = result.id;
      savedBillNumber = result.billNumber;
    }

    final savedWeighment = Weighment(
      id: savedId,
      billNumber: savedBillNumber,
      customerId: weighment.customerId,
      vehicleNumber: weighment.vehicleNumber,
      materialId: weighment.materialId,
      paymentMode: weighment.paymentMode,
      firstWeightKg: weighment.firstWeightKg,
      firstWeightType: weighment.firstWeightType,
      secondWeightKg: weighment.secondWeightKg,
      secondWeightType: weighment.secondWeightType,
      netWeightKg: weighment.explicitNetWeightKg,
      vehicleCharge: weighment.vehicleCharge,
      amount: weighment.amount,
      remarks: weighment.remarks,
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

    return (
      bill: savedWeighment,
      customer: savedCustomer,
      materialName: savedMaterialName,
    );
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
        clearCustomer: true,
        vehicleNumber: '',
        clearMaterial: true,
        clearEditingBillId: true,
        clearEditingFirstWeight: true,
        clearEditingBillCreatedAt: true,
        grossWeightText: '',
        tareWeightText: '',
        remarksText: '',
        mobileNumber: '',
        grossWeightKg: 0,
        tareWeightKg: 0,
        netWeightKg: 0,
        vehicleCharge: 0,
        amount: 0,
        paymentMode: 'Cash',
        currentBillNumber: nextBillNumber,
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

  Future<void> _onCustomerQuickAdd(
    CustomerQuickAddRequested event,
    Emitter<BillState> emit,
  ) async {
    try {
      final existingCustomers = await _customerRepository.searchCustomers(
        event.name,
      );
      if (emit.isDone) return;
      final exactMatch = existingCustomers.where(
        (c) => c.name.toLowerCase() == event.name.toLowerCase(),
      );
      if (exactMatch.isNotEmpty) {
        emit(
          state.copyWith(
            errorMessage: 'Customer with this name already exists',
          ),
        );
        return;
      }

      final newId = await _customerRepository.createCustomer(
        name: event.name,
        customerCode: 'Q${DateTime.now().microsecondsSinceEpoch}',
        contactPerson: event.contactPerson,
      );
      if (emit.isDone) return;

      final customers = await _customerRepository.getAllActiveCustomers();
      if (emit.isDone) return;
      final newCustomer = customers.firstWhere((c) => c.id == newId);

      emit(
        state.copyWith(
          customers: customers,
          selectedCustomer: newCustomer,
          clearError: true,
        ),
      );
    } catch (e) {
      if (emit.isDone) return;
      emit(
        state.copyWith(
          errorMessage: 'Failed to create customer: ${e.toString()}',
        ),
      );
    }
  }

  Future<MaterialItem> quickAddMaterial(String code, String name) async {
    final completer = Completer<MaterialItem?>();
    add(
      MaterialQuickAddRequested(code: code, name: name, completer: completer),
    );
    final result = await completer.future;
    if (result == null) {
      throw Exception('Failed to create material');
    }
    return result;
  }

  Future<MaterialItem> createMaterial(String code, String name) =>
      quickAddMaterial(code, name);

  Future<Customer> createCustomer(String name, String contactPerson) async {
    final existing = await _customerRepository.searchCustomers(name);
    if (existing.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      throw Exception('Customer with this name already exists');
    }
    final newId = await _customerRepository.createCustomer(
      name: name,
      customerCode: 'Q${DateTime.now().microsecondsSinceEpoch}',
      contactPerson: contactPerson,
    );
    final refreshed = await _customerRepository.getAllActiveCustomers();
    final created = refreshed.firstWhere((c) => c.id == newId);
    add(CustomerCreatedToState(customers: refreshed, selected: created));
    return created;
  }

  Future<void> _onMaterialQuickAdd(
    MaterialQuickAddRequested event,
    Emitter<BillState> emit,
  ) async {
    final trimmedCode = event.code.trim();
    final trimmedName = event.name.trim();
    if (trimmedName.isEmpty) {
      const errorMsg = 'Material name is required';
      emit(state.copyWith(errorMessage: errorMsg));
      if (event.completer != null && !event.completer!.isCompleted) {
        event.completer!.completeError(Exception(errorMsg));
      }
      return;
    }
    if (trimmedCode.isEmpty) {
      const errorMsg = 'Material code is required';
      emit(state.copyWith(errorMessage: errorMsg));
      if (event.completer != null && !event.completer!.isCompleted) {
        event.completer!.completeError(Exception(errorMsg));
      }
      return;
    }

    try {
      final duplicate = await _materialRepository.getMaterialByCode(
        trimmedCode,
      );
      if (emit.isDone) return;

      if (duplicate != null) {
        final errorMsg = duplicate.isActive
            ? 'Material with code "${duplicate.code}" already exists'
            : 'Material "${duplicate.name}" already exists but is deactivated';
        emit(state.copyWith(errorMessage: errorMsg));
        if (event.completer != null && !event.completer!.isCompleted) {
          event.completer!.completeError(Exception(errorMsg));
        }
        return;
      }

      final newId = await _materialRepository.createMaterial(
        code: trimmedCode,
        name: trimmedName,
      );
      if (emit.isDone) return;

      final created = await _materialRepository.getMaterialById(newId);
      if (created == null) {
        throw Exception('Failed to retrieve newly created material');
      }

      final updatedMaterials = [
        ...state.materials.where((m) => m.id != newId),
        created,
      ];

      emit(
        state.copyWith(
          materials: updatedMaterials,
          selectedMaterial: created,
          clearError: true,
        ),
      );

      if (event.completer != null && !event.completer!.isCompleted) {
        event.completer!.complete(created);
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (emit.isDone) return;
      emit(
        state.copyWith(errorMessage: 'Failed to create material: $errorMsg'),
      );
      if (event.completer != null && !event.completer!.isCompleted) {
        event.completer!.completeError(Exception(errorMsg));
      }
    }
  }

  void _onMaterialCreatedToState(
    MaterialCreatedToState event,
    Emitter<BillState> emit,
  ) {
    emit(
      state.copyWith(
        materials: event.materials,
        selectedMaterial: event.selected,
        clearError: true,
      ),
    );
  }

  void _onCustomerCreatedToState(
    CustomerCreatedToState event,
    Emitter<BillState> emit,
  ) {
    emit(
      state.copyWith(
        customers: event.customers,
        selectedCustomer: event.selected,
        clearError: true,
      ),
    );
  }
}
