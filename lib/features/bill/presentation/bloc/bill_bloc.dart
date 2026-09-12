import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../party/domain/entities/party.dart';
import '../../../party/domain/repositories/party_repository.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../vehicle/domain/repositories/vehicle_repository.dart';
import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import '../../../vehicle_type/domain/repositories/vehicle_type_repository.dart';
import '../../../material/domain/entities/material_item.dart';
import '../../../material/domain/repositories/material_item_repository.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/usecases/save_bill.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final PartyRepository _partyRepository;
  final VehicleRepository _vehicleRepository;
  final VehicleTypeRepository _vehicleTypeRepository;
  final MaterialItemRepository _materialRepository;
  final SaveBillUseCase _saveBillUseCase;
  final LoadRecentBillsUseCase _loadRecentBillsUseCase;
  final LoadPendingBillsUseCase _loadPendingBillsUseCase;
  final GenerateBillNumberUseCase _generateBillNumberUseCase;

  BillBloc({
    required PartyRepository partyRepository,
    required VehicleRepository vehicleRepository,
    required VehicleTypeRepository vehicleTypeRepository,
    required MaterialItemRepository materialRepository,
    required SaveBillUseCase saveBillUseCase,
    required LoadRecentBillsUseCase loadRecentBillsUseCase,
    required LoadPendingBillsUseCase loadPendingBillsUseCase,
    required GenerateBillNumberUseCase generateBillNumberUseCase,
  })  : _partyRepository = partyRepository,
        _vehicleRepository = vehicleRepository,
        _vehicleTypeRepository = vehicleTypeRepository,
        _materialRepository = materialRepository,
        _saveBillUseCase = saveBillUseCase,
        _loadRecentBillsUseCase = loadRecentBillsUseCase,
        _loadPendingBillsUseCase = loadPendingBillsUseCase,
        _generateBillNumberUseCase = generateBillNumberUseCase,
        super(const BillState()) {
    on<LoadBillScreen>(_onLoadBillScreen);
    on<PartySelected>(_onPartySelected);
    on<VehicleSelected>(_onVehicleSelected);
    on<MaterialSelected>(_onMaterialSelected);
    on<GrossWeightChanged>(_onGrossWeightChanged);
    on<TareWeightChanged>(_onTareWeightChanged);
    on<RemarksChanged>(_onRemarksChanged);
    on<PaymentModeChanged>(_onPaymentModeChanged);
    on<VehicleChargeChanged>(_onVehicleChargeChanged);
    on<ResetVehicleCharge>(_onResetVehicleCharge);
    on<SaveBillRequested>(_onSaveBillRequested);
    on<SaveAndPrintBillRequested>(_onSaveAndPrintBillRequested);
    on<LoadPendingBill>(_onLoadPendingBill);
    on<LoadPendingBills>(_onLoadPendingBills);
    on<ClearBillRequested>(_onClearBillRequested);
    on<LoadRecentBills>(_onLoadRecentBills);
    on<PartyQuickAddRequested>(_onPartyQuickAdd);
    on<VehicleQuickAddRequested>(_onVehicleQuickAdd);
    on<VehicleTypeQuickAddRequested>(_onVehicleTypeQuickAdd);
    on<MaterialQuickAddRequested>(_onMaterialQuickAdd);
  }

  Future<void> _onLoadBillScreen(LoadBillScreen event, Emitter<BillState> emit) async {
    emit(state.copyWith(status: BillScreenStatus.loading, clearError: true));

    try {
      final parties = await _partyRepository.getAllActiveParties();
      final vehicles = await _vehicleRepository.getVehiclesByStatus(isActive: true);
      final vehicleTypes = await _vehicleTypeRepository.getAllVehicleTypes();
      final materials = await _materialRepository.getMaterialsByStatus(isActive: true);
      final billsDate = _dayOnly(DateTime.now());
      final recentBills = await _loadRecentBillsUseCase(date: billsDate);
      final billNumber = await _generateBillNumberUseCase();

      emit(state.copyWith(
        status: BillScreenStatus.loaded,
        parties: parties,
        vehicles: vehicles,
        vehicleTypes: vehicleTypes,
        materials: materials,
        recentBills: recentBills,
        billsDate: billsDate,
        currentBillNumber: billNumber,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BillScreenStatus.error,
        errorMessage: 'Failed to load bill screen: $e',
      ));
    }
  }

  void _onPartySelected(PartySelected event, Emitter<BillState> emit) {
    emit(state.copyWith(
      selectedParty: event.party,
      clearError: true,
    ));
  }

  void _onVehicleSelected(VehicleSelected event, Emitter<BillState> emit) {
    final vehicle = event.vehicle;
    VehicleType? vehicleType;
    for (final vt in state.vehicleTypes) {
      if (vt.id == vehicle.vehicleTypeId) {
        vehicleType = vt;
        break;
      }
    }

    emit(state.copyWith(
      selectedVehicle: vehicle,
      selectedVehicleType: vehicleType,
      clearManualCharge: true,
      clearError: true,
    ));
    _recalculate(emit);
  }

  void _onMaterialSelected(MaterialSelected event, Emitter<BillState> emit) {
    emit(state.copyWith(
      selectedMaterial: event.material,
      clearError: true,
    ));
  }

  void _onGrossWeightChanged(GrossWeightChanged event, Emitter<BillState> emit) {
    final value = double.tryParse(event.value) ?? 0;
    emit(state.copyWith(
      grossWeightText: event.value,
      grossWeightKg: value,
      clearError: true,
    ));
    _recalculate(emit);
  }

  void _onTareWeightChanged(TareWeightChanged event, Emitter<BillState> emit) {
    final value = double.tryParse(event.value) ?? 0;
    emit(state.copyWith(
      tareWeightText: event.value,
      tareWeightKg: value,
      clearError: true,
    ));
    _recalculate(emit);
  }

  void _onRemarksChanged(RemarksChanged event, Emitter<BillState> emit) {
    emit(state.copyWith(remarksText: event.value));
  }

  void _onPaymentModeChanged(PaymentModeChanged event, Emitter<BillState> emit) {
    emit(state.copyWith(paymentMode: event.value));
  }

  void _onVehicleChargeChanged(VehicleChargeChanged event, Emitter<BillState> emit) {
    final value = double.tryParse(event.value) ?? 0;
    emit(state.copyWith(
      vehicleCharge: value,
      isVehicleChargeManuallyEdited: true,
      clearError: true,
    ));
    final amount = value;
    emit(state.copyWith(amount: amount));
  }

  void _onResetVehicleCharge(ResetVehicleCharge event, Emitter<BillState> emit) {
    emit(state.copyWith(
      vehicleCharge: state.defaultVehicleCharge,
      isVehicleChargeManuallyEdited: false,
      clearError: true,
    ));
    final amount = state.defaultVehicleCharge;
    emit(state.copyWith(amount: amount));
  }

  void _recalculate(Emitter<BillState> emit) {
    final vehicleType = state.selectedVehicleType;
    final fw = state.grossWeightKg;
    final sw = state.tareWeightKg;

    double defaultCharge = 0;
    double netWeightKg = 0;

    if (vehicleType != null && fw > 0) {
      if (sw > 0) {
        netWeightKg = sw - fw;
        defaultCharge = vehicleType.loadPrice;
      } else {
        defaultCharge = vehicleType.emptyPrice;
      }
    }

    final vehicleCharge = state.isVehicleChargeManuallyEdited
        ? state.vehicleCharge
        : defaultCharge;
    final amount = vehicleCharge;

    emit(state.copyWith(
      netWeightKg: netWeightKg,
      defaultVehicleCharge: defaultCharge,
      vehicleCharge: vehicleCharge,
      amount: amount,
    ));
  }

  String? _validate() {
    if (state.selectedParty == null) return 'Please select a party';
    if (state.selectedVehicle == null) return 'Please select a vehicle';
    if (state.selectedVehicleType == null) return 'Vehicle type is missing';
    if (state.selectedMaterial == null) return 'Please select a material';
    if (state.grossWeightKg <= 0) return 'Please enter gross weight';

    if (state.tareWeightKg > 0) {
      if (state.tareWeightKg <= state.grossWeightKg) {
        return 'Tare weight must be greater than gross weight';
      }
      if (state.netWeightKg <= 0) return 'Net weight must be positive';
    }

    return null;
  }

  Future<void> _onSaveBillRequested(SaveBillRequested event, Emitter<BillState> emit) async {
    final error = _validate();
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return;
    }

    emit(state.copyWith(status: BillScreenStatus.saving, clearError: true));

    try {
      await _saveOrUpdateBill(emit);
      final bills = await _loadBillsFor(state.effectiveBillsDate);
      emit(state.copyWith(
        status: BillScreenStatus.saved,
        recentBills: bills,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BillScreenStatus.error,
        errorMessage: 'Failed to save bill: $e',
      ));
    }
  }

  Future<void> _onSaveAndPrintBillRequested(SaveAndPrintBillRequested event, Emitter<BillState> emit) async {
    final error = _validate();
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return;
    }

    emit(state.copyWith(status: BillScreenStatus.printing, clearError: true));

    try {
      await _saveOrUpdateBill(emit);
      final bills = await _loadBillsFor(state.effectiveBillsDate);
      emit(state.copyWith(
        status: BillScreenStatus.saved,
        recentBills: bills,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BillScreenStatus.error,
        errorMessage: 'Failed to save bill: $e',
      ));
    }
  }

  Future<void> _saveOrUpdateBill(Emitter<BillState> emit) async {
    final isCompleted = state.tareWeightKg > 0;
    final status = isCompleted ? 'completed' : 'pending';

    final weighment = Weighment(
      id: state.editingBillId ?? 0,
      billNumber: state.currentBillNumber,
      partyId: state.selectedParty!.id,
      vehicleId: state.selectedVehicle!.id,
      materialId: state.selectedMaterial!.id,
      paymentMode: state.paymentMode,
      grossWeightKg: state.grossWeightKg,
      tareWeightKg: isCompleted ? state.tareWeightKg : null,
      netWeightKg: isCompleted ? state.netWeightKg : null,
      vehicleCharge: state.vehicleCharge,
      amount: state.amount,
      remarks: state.remarksText.isNotEmpty ? state.remarksText : null,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (state.isEditing) {
      await _saveBillUseCase.updateWeighment(state.editingBillId!, weighment);
    } else {
      await _saveBillUseCase(weighment);
    }

    final nextBillNumber = await _generateBillNumberUseCase();
    _resetForm(emit, nextBillNumber: nextBillNumber);
  }

  Future<void> _onLoadPendingBill(LoadPendingBill event, Emitter<BillState> emit) async {
    try {
      final weighment = await _saveBillUseCase.getWeighmentById(event.billId);
      if (weighment == null) {
        emit(state.copyWith(errorMessage: 'Bill not found'));
        return;
      }

      Party? party;
      for (final p in state.parties) {
        if (p.id == weighment.partyId) {
          party = p;
          break;
        }
      }

      Vehicle? vehicle;
      for (final v in state.vehicles) {
        if (v.id == weighment.vehicleId) {
          vehicle = v;
          break;
        }
      }

      VehicleType? vehicleType;
      if (vehicle != null) {
        for (final vt in state.vehicleTypes) {
          if (vt.id == vehicle.vehicleTypeId) {
            vehicleType = vt;
            break;
          }
        }
      }

      MaterialItem? material;
      for (final m in state.materials) {
        if (m.id == weighment.materialId) {
          material = m;
          break;
        }
      }

      double defaultCharge = 0;
      if (vehicleType != null) {
        defaultCharge = vehicleType.emptyPrice;
      }
      final isManuallyEdited = weighment.vehicleCharge != defaultCharge && weighment.vehicleCharge > 0;

      emit(state.copyWith(
        clearError: true,
        editingBillId: weighment.id,
        currentBillNumber: weighment.billNumber,
        selectedParty: party,
        selectedVehicle: vehicle,
        selectedVehicleType: vehicleType,
        selectedMaterial: material,
        paymentMode: weighment.paymentMode,
        grossWeightText: weighment.grossWeightKg.toStringAsFixed(0),
        grossWeightKg: weighment.grossWeightKg,
        tareWeightText: '',
        tareWeightKg: 0,
        netWeightKg: 0,
        defaultVehicleCharge: defaultCharge,
        vehicleCharge: weighment.vehicleCharge,
        isVehicleChargeManuallyEdited: isManuallyEdited,
        amount: weighment.amount,
        remarksText: weighment.remarks ?? '',
      ));
      _recalculate(emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load pending bill: $e'));
    }
  }

  void _onClearBillRequested(ClearBillRequested event, Emitter<BillState> emit) {
    _resetForm(emit);
  }

  Future<void> _onLoadPendingBills(LoadPendingBills event, Emitter<BillState> emit) async {
    try {
      final bills = await _loadPendingBillsUseCase();
      emit(state.copyWith(pendingBills: bills));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load pending bills'));
    }
  }

  void _resetForm(Emitter<BillState> emit, {String? nextBillNumber}) async {
    final billNum = nextBillNumber ?? await _generateBillNumberUseCase();
    emit(state.copyWith(
      clearParty: true,
      clearVehicle: true,
      clearVehicleType: true,
      clearMaterial: true,
      clearEditingBillId: true,
      grossWeightText: '',
      tareWeightText: '',
      remarksText: '',
      grossWeightKg: 0,
      tareWeightKg: 0,
      netWeightKg: 0,
      vehicleCharge: 0,
      defaultVehicleCharge: 0,
      isVehicleChargeManuallyEdited: false,
      amount: 0,
      paymentMode: 'Cash',
      currentBillNumber: billNum,
      clearError: true,
    ));
  }

  Future<void> _onLoadRecentBills(LoadRecentBills event, Emitter<BillState> emit) async {
    try {
      if (event.startDate != null && event.endDate != null) {
        final bills = await _loadRecentBillsUseCase.byDateRange(
          startDate: _dayOnly(event.startDate!),
          endDate: _dayOnly(event.endDate!),
        );
        emit(state.copyWith(
          recentBills: bills,
          billsStartDate: _dayOnly(event.startDate!),
          billsEndDate: _dayOnly(event.endDate!),
          clearDateRange: false,
        ));
      } else {
        final billsDate = _dayOnly(event.date ?? DateTime.now());
        final bills = await _loadBillsFor(billsDate);
        emit(state.copyWith(
          recentBills: bills,
          billsDate: billsDate,
          clearDateRange: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load recent bills'));
    }
  }

  Future<List<Weighment>> _loadBillsFor(DateTime date) {
    return _loadRecentBillsUseCase(date: _dayOnly(date));
  }

  DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<void> _onPartyQuickAdd(PartyQuickAddRequested event, Emitter<BillState> emit) async {
    try {
      final existingParties = await _partyRepository.searchParties(event.name);
      final exactMatch = existingParties.where((p) => p.name.toLowerCase() == event.name.toLowerCase());
      if (exactMatch.isNotEmpty) {
        emit(state.copyWith(errorMessage: 'Party with this name already exists'));
        return;
      }

      final newId = await _partyRepository.createParty(
        name: event.name,
        contactPerson: event.contactPerson,
      );

      final parties = await _partyRepository.getAllActiveParties();
      final newParty = parties.firstWhere((p) => p.id == newId);

      emit(state.copyWith(
        parties: parties,
        selectedParty: newParty,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to create party: ${e.toString()}'));
    }
  }

  Future<void> _onVehicleQuickAdd(VehicleQuickAddRequested event, Emitter<BillState> emit) async {
    try {
      final vehicles = await _vehicleRepository.getVehiclesByStatus(isActive: true);
      final duplicate = vehicles.where((v) => v.vehicleNumber.toUpperCase() == event.vehicleNumber.toUpperCase());
      if (duplicate.isNotEmpty) {
        emit(state.copyWith(errorMessage: 'Vehicle with this number already exists'));
        return;
      }

      final newId = await _vehicleRepository.createVehicle(
        vehicleNumber: event.vehicleNumber,
        vehicleTypeId: event.vehicleTypeId,
      );

      final refreshedVehicles = await _vehicleRepository.getVehiclesByStatus(isActive: true);
      final newVehicle = refreshedVehicles.firstWhere((v) => v.id == newId);

      VehicleType? vehicleType;
      for (final vt in state.vehicleTypes) {
        if (vt.id == newVehicle.vehicleTypeId) {
          vehicleType = vt;
          break;
        }
      }

      emit(state.copyWith(
        vehicles: refreshedVehicles,
        selectedVehicle: newVehicle,
        selectedVehicleType: vehicleType,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to create vehicle: ${e.toString()}'));
    }
  }

  Future<void> _onVehicleTypeQuickAdd(VehicleTypeQuickAddRequested event, Emitter<BillState> emit) async {
    try {
      final vehicleTypes = await _vehicleTypeRepository.getVehicleTypesByStatus(isActive: true);
      final duplicate = vehicleTypes.where((vt) => vt.name.toLowerCase() == event.name.toLowerCase());
      if (duplicate.isNotEmpty) {
        emit(state.copyWith(errorMessage: 'Vehicle type with this name already exists'));
        return;
      }

      final newId = await _vehicleTypeRepository.createVehicleType(
        name: event.name,
        emptyPrice: event.emptyPrice,
        loadPrice: event.loadPrice,
      );

      final refreshedTypes = await _vehicleTypeRepository.getVehicleTypesByStatus(isActive: true);
      final newType = refreshedTypes.firstWhere((vt) => vt.id == newId);

      emit(state.copyWith(
        vehicleTypes: refreshedTypes,
        selectedVehicleType: newType,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to create vehicle type: ${e.toString()}'));
    }
  }

  Future<void> _onMaterialQuickAdd(MaterialQuickAddRequested event, Emitter<BillState> emit) async {
    try {
      final materials = await _materialRepository.getMaterialsByStatus(isActive: true);
      final duplicate = materials.where((m) => m.name.toLowerCase() == event.name.toLowerCase());
      if (duplicate.isNotEmpty) {
        emit(state.copyWith(errorMessage: 'Material with this name already exists'));
        return;
      }

      final newId = await _materialRepository.createMaterial(
        name: event.name,
        category: '',
      );

      final refreshedMaterials = await _materialRepository.getMaterialsByStatus(isActive: true);
      final newMaterial = refreshedMaterials.firstWhere((m) => m.id == newId);

      emit(state.copyWith(
        materials: refreshedMaterials,
        selectedMaterial: newMaterial,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to create material: ${e.toString()}'));
    }
  }
}
