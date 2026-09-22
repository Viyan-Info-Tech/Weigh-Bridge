import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../customer/domain/entities/customer.dart';
import '../../../customer/domain/repositories/customer_repository.dart';
import '../../../material/domain/entities/material_item.dart';
import '../../../material/domain/repositories/material_item_repository.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/usecases/save_bill.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final CustomerRepository _customerRepository;

  CustomerRepository get customerRepository => _customerRepository;

  final MaterialItemRepository _materialRepository;

  MaterialItemRepository get materialRepository => _materialRepository;

  final SaveBillUseCase _saveBillUseCase;
  final LoadRecentBillsUseCase _loadRecentBillsUseCase;
  final GenerateBillNumberUseCase _generateBillNumberUseCase;
  final SettingsRepository? _settingsRepository;

  BillBloc({
    required CustomerRepository customerRepository,
    required MaterialItemRepository materialRepository,
    required SaveBillUseCase saveBillUseCase,
    required LoadRecentBillsUseCase loadRecentBillsUseCase,
    required GenerateBillNumberUseCase generateBillNumberUseCase,
    SettingsRepository? settingsRepository,
  }) : _customerRepository = customerRepository,
       _materialRepository = materialRepository,
       _saveBillUseCase = saveBillUseCase,
       _loadRecentBillsUseCase = loadRecentBillsUseCase,
       _generateBillNumberUseCase = generateBillNumberUseCase,
       _settingsRepository = settingsRepository,
       super(const BillState()) {
    on<LoadBillScreen>(_onLoadBillScreen);
    on<CustomerSelected>(_onCustomerSelected);
    on<VehicleNumberChanged>(_onVehicleNumberChanged);
    on<MaterialSelected>(_onMaterialSelected);
    on<GrossWeightChanged>(_onGrossWeightChanged);
    on<TareWeightChanged>(_onTareWeightChanged);
    on<RemarksChanged>(_onRemarksChanged);
    on<PaymentModeChanged>(_onPaymentModeChanged);
    on<WeightUnitChanged>(_onWeightUnitChanged);
    on<VehicleChargeChanged>(_onVehicleChargeChanged);
    on<ResetVehicleCharge>(_onResetVehicleCharge);
    on<SaveBillRequested>(_onSaveBillRequested);
    on<SaveAndPrintBillRequested>(_onSaveAndPrintBillRequested);
    on<PrintReceiptDismissed>(_onPrintReceiptDismissed);
    on<ClearBillRequested>(_onClearBillRequested);
    on<LoadRecentBills>(_onLoadRecentBills);
    on<CustomerQuickAddRequested>(_onCustomerQuickAdd);
    on<MaterialQuickAddRequested>(_onMaterialQuickAdd);
    on<MaterialCreatedToState>(_onMaterialCreatedToState);
    on<CustomerCreatedToState>(_onCustomerCreatedToState);
    on<CaptureLiveWeight>(_onCaptureLiveWeight);
    on<LiveScaleWeightUpdated>(_onLiveScaleWeightUpdated);
    on<WeightTypeSelected>(_onWeightTypeSelected);
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

      emit(
        state.copyWith(
          status: BillScreenStatus.loaded,
          customers: customers,
          materials: materials,
          recentBills: recentBills,
          billsDate: billsDate,
          currentBillNumber: billNumber,
          weightUnit: unit,
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
    emit(state.copyWith(selectedCustomer: event.customer, clearError: true));
  }

  void _onVehicleNumberChanged(
    VehicleNumberChanged event,
    Emitter<BillState> emit,
  ) {
    emit(
      state.copyWith(
        vehicleNumber: event.vehicleNumber.trim().toUpperCase(),
        clearError: true,
      ),
    );
  }

  void _onMaterialSelected(MaterialSelected event, Emitter<BillState> emit) {
    emit(state.copyWith(selectedMaterial: event.material, clearError: true));
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
    final kgValue = _toKg(displayValue);
    emit(
      state.copyWith(
        grossWeightText: event.value,
        grossWeightKg: kgValue,
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
    final kgValue = _toKg(displayValue);
    emit(
      state.copyWith(
        tareWeightText: event.value,
        tareWeightKg: kgValue,
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
    // Historical bill unit is immutable
    if (state.isEditing) {
      return;
    }

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
    emit(state.copyWith(vehicleCharge: value, amount: value, clearError: true));
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

    if (gw > 0 && tw > 0) {
      if (tw > gw) {
        weightError = 'Tare weight cannot be greater than gross weight';
        netWeightKg = 0;
      } else {
        netWeightKg = gw - tw;
      }
    }

    emit(
      state.copyWith(
        netWeightKg: netWeightKg,
        weightValidationError: weightError,
        clearWeightError: weightError == null,
      ),
    );
  }

  void _onCaptureLiveWeight(CaptureLiveWeight event, Emitter<BillState> emit) {
    final liveKg = state.liveScaleWeightKg;
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
          editingFirstWeightType: state.editingFirstWeightType ?? 'GROSS',
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
    double live = state.liveScaleWeightKg;
    if (event.type.toLowerCase() == 'gross' && (live == 10200.0 || live == 0)) {
      live = 25500.0;
    } else if (event.type.toLowerCase() == 'tare' &&
        (live == 25500.0 || live == 0)) {
      live = 10200.0;
    }

    emit(
      state.copyWith(selectedWeightType: event.type, liveScaleWeightKg: live),
    );
  }

  String? _validate() {
    if (state.selectedCustomer == null) return 'Please select a customer';
    if (state.vehicleNumber.trim().isEmpty) {
      return 'Please enter a vehicle number';
    }
    if (state.selectedMaterial == null) return 'Please select a material';
    if (state.grossWeightKg <= 0) return 'Please enter the gross weight';
    if (state.tareWeightKg <= 0) return 'Please enter the tare weight';
    if (state.tareWeightKg > state.grossWeightKg) {
      return 'Tare weight cannot be greater than gross weight';
    }

    return null;
  }

  Future<void> _onSaveBillRequested(
    SaveBillRequested event,
    Emitter<BillState> emit,
  ) async {
    final error = _validate();
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return;
    }

    emit(state.copyWith(status: BillScreenStatus.saving, clearError: true));

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
    final error = _validate();
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return;
    }

    emit(state.copyWith(status: BillScreenStatus.printing, clearError: true));

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
    final createdAt = state.isEditing
        ? (state.editingBillCreatedAt ?? DateTime.now())
        : DateTime.now();

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
      // New bill with both weights captured (gross first, tare second)
      firstWeightKg = state.grossWeightKg;
      firstWeightType = 'GROSS';
      secondWeightKg = state.tareWeightKg;
      secondWeightType = 'TARE';
    }

    final netWeight = (state.grossWeightKg > 0 && state.tareWeightKg > 0)
        ? (state.grossWeightKg - state.tareWeightKg).abs()
        : null;

    int savedId = state.editingBillId ?? 0;

    final weighment = Weighment(
      id: savedId,
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
      updatedAt: DateTime.now(),
    );

    if (state.isEditing) {
      await _saveBillUseCase.updateWeighment(state.editingBillId!, weighment);
    } else {
      savedId = await _saveBillUseCase(weighment);
    }

    final savedWeighment = Weighment(
      id: savedId,
      billNumber: weighment.billNumber,
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
        grossWeightKg: 0,
        tareWeightKg: 0,
        netWeightKg: 0,
        vehicleCharge: 0,
        amount: 0,
        paymentMode: 'Cash',
        currentBillNumber: nextBillNumber,
        clearError: true,
        clearWeightError: true,
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

  Future<List<Weighment>> _loadBillsFor(DateTime date) {
    return _loadRecentBillsUseCase(date: _dayOnly(date));
  }

  DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

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
