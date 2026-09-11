import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/party.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/material.dart';
import '../../domain/entities/weighment.dart';
import '../../domain/usecases/load_parties.dart';
import '../../domain/usecases/load_vehicles.dart';
import '../../domain/usecases/load_materials.dart';
import '../../domain/usecases/save_bill.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final LoadPartiesUseCase _loadPartiesUseCase;
  final LoadVehiclesUseCase _loadVehiclesUseCase;
  final LoadMaterialsUseCase _loadMaterialsUseCase;
  final SaveBillUseCase _saveBillUseCase;
  final LoadRecentBillsUseCase _loadRecentBillsUseCase;
  final GenerateBillNumberUseCase _generateBillNumberUseCase;

  BillBloc({
    required LoadPartiesUseCase loadPartiesUseCase,
    required LoadVehiclesUseCase loadVehiclesUseCase,
    required LoadMaterialsUseCase loadMaterialsUseCase,
    required SaveBillUseCase saveBillUseCase,
    required LoadRecentBillsUseCase loadRecentBillsUseCase,
    required GenerateBillNumberUseCase generateBillNumberUseCase,
  })  : _loadPartiesUseCase = loadPartiesUseCase,
        _loadVehiclesUseCase = loadVehiclesUseCase,
        _loadMaterialsUseCase = loadMaterialsUseCase,
        _saveBillUseCase = saveBillUseCase,
        _loadRecentBillsUseCase = loadRecentBillsUseCase,
        _generateBillNumberUseCase = generateBillNumberUseCase,
        super(const BillState()) {
    on<LoadBillScreen>(_onLoadBillScreen);
    on<PartySelected>(_onPartySelected);
    on<VehicleSelected>(_onVehicleSelected);
    on<MaterialSelected>(_onMaterialSelected);
    on<FirstWeightChanged>(_onFirstWeightChanged);
    on<SecondWeightChanged>(_onSecondWeightChanged);
    on<RateChanged>(_onRateChanged);
    on<RemarksChanged>(_onRemarksChanged);
    on<EntryTypeChanged>(_onEntryTypeChanged);
    on<PaymentModeChanged>(_onPaymentModeChanged);
    on<SaveBillRequested>(_onSaveBillRequested);
    on<ClearBillRequested>(_onClearBillRequested);
    on<LoadRecentBills>(_onLoadRecentBills);
  }

  Future<void> _onLoadBillScreen(LoadBillScreen event, Emitter<BillState> emit) async {
    emit(state.copyWith(status: BillScreenStatus.loading, clearError: true));

    try {
      final results = await Future.wait([
        _loadPartiesUseCase(),
        _loadVehiclesUseCase(),
        _loadMaterialsUseCase(),
        _loadRecentBillsUseCase(),
        _generateBillNumberUseCase(),
      ]);

      final parties = results[0] as List<Party>;
      final vehicles = results[1] as List<Vehicle>;
      final materials = results[2] as List<Material>;
      final recentBills = results[3] as List<Weighment>;
      final billNumber = results[4] as String;

      emit(state.copyWith(
        status: BillScreenStatus.loaded,
        parties: parties,
        vehicles: vehicles,
        materials: materials,
        recentBills: recentBills,
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
    emit(state.copyWith(
      selectedVehicle: event.vehicle,
      clearError: true,
    ));
  }

  void _onMaterialSelected(MaterialSelected event, Emitter<BillState> emit) {
    final material = event.material;
    emit(state.copyWith(
      selectedMaterial: material,
      rateText: material.defaultRate > 0 ? material.defaultRate.toStringAsFixed(0) : '',
      ratePerTon: material.defaultRate,
      clearError: true,
    ));
    _recalculate(emit,
      ratePerTon: material.defaultRate,
    );
  }

  void _onFirstWeightChanged(FirstWeightChanged event, Emitter<BillState> emit) {
    final value = double.tryParse(event.value) ?? 0;
    emit(state.copyWith(
      firstWeightText: event.value,
      firstWeightKg: value,
      clearError: true,
    ));
    _recalculate(emit, firstWeightKg: value);
  }

  void _onSecondWeightChanged(SecondWeightChanged event, Emitter<BillState> emit) {
    final value = double.tryParse(event.value) ?? 0;
    emit(state.copyWith(
      secondWeightText: event.value,
      secondWeightKg: value,
      clearError: true,
    ));
    _recalculate(emit, secondWeightKg: value);
  }

  void _onRateChanged(RateChanged event, Emitter<BillState> emit) {
    final value = double.tryParse(event.value) ?? 0;
    emit(state.copyWith(
      rateText: event.value,
      ratePerTon: value,
      clearError: true,
    ));
    _recalculate(emit, ratePerTon: value);
  }

  void _onRemarksChanged(RemarksChanged event, Emitter<BillState> emit) {
    emit(state.copyWith(remarksText: event.value));
  }

  void _onEntryTypeChanged(EntryTypeChanged event, Emitter<BillState> emit) {
    emit(state.copyWith(entryType: event.value));
  }

  void _onPaymentModeChanged(PaymentModeChanged event, Emitter<BillState> emit) {
    emit(state.copyWith(paymentMode: event.value));
  }

  void _recalculate(Emitter<BillState> emit, {
    double? firstWeightKg,
    double? secondWeightKg,
    double? ratePerTon,
  }) {
    final fw = firstWeightKg ?? state.firstWeightKg;
    final sw = secondWeightKg ?? state.secondWeightKg;
    final rate = ratePerTon ?? state.ratePerTon;

    final netWeightKg = (fw - sw).abs();
    final netWeightTon = netWeightKg / 1000;
    final amount = netWeightTon * rate;

    emit(state.copyWith(
      netWeightKg: netWeightKg,
      netWeightTon: netWeightTon,
      amount: amount,
    ));
  }

  Future<void> _onSaveBillRequested(SaveBillRequested event, Emitter<BillState> emit) async {
    if (state.selectedParty == null) {
      emit(state.copyWith(errorMessage: 'Please select a party'));
      return;
    }
    if (state.selectedVehicle == null) {
      emit(state.copyWith(errorMessage: 'Please select a vehicle'));
      return;
    }
    if (state.selectedMaterial == null) {
      emit(state.copyWith(errorMessage: 'Please select a material'));
      return;
    }
    if (state.firstWeightKg <= 0) {
      emit(state.copyWith(errorMessage: 'Please enter first weight'));
      return;
    }
    if (state.secondWeightKg <= 0) {
      emit(state.copyWith(errorMessage: 'Please enter second weight'));
      return;
    }
    if (state.ratePerTon <= 0) {
      emit(state.copyWith(errorMessage: 'Please enter rate'));
      return;
    }

    emit(state.copyWith(status: BillScreenStatus.saving, clearError: true));

    try {
      final weighment = Weighment(
        id: 0,
        billNumber: state.currentBillNumber,
        partyId: state.selectedParty!.id,
        vehicleId: state.selectedVehicle!.id,
        materialId: state.selectedMaterial!.id,
        entryType: state.entryType,
        paymentMode: state.paymentMode,
        firstWeightKg: state.firstWeightKg,
        secondWeightKg: state.secondWeightKg,
        netWeightKg: state.netWeightKg,
        ratePerTon: state.ratePerTon,
        amount: state.amount,
        remarks: state.remarksText.isNotEmpty ? state.remarksText : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _saveBillUseCase(weighment);

      final bills = await _loadRecentBillsUseCase();
      final nextBillNumber = await _generateBillNumberUseCase();

      emit(state.copyWith(
        status: BillScreenStatus.saved,
        recentBills: bills,
        currentBillNumber: nextBillNumber,
        selectedParty: null,
        selectedVehicle: null,
        selectedMaterial: null,
        firstWeightText: '',
        secondWeightText: '',
        rateText: '',
        remarksText: '',
        firstWeightKg: 0,
        secondWeightKg: 0,
        netWeightKg: 0,
        netWeightTon: 0,
        ratePerTon: 0,
        amount: 0,
        entryType: 'Inbound',
        paymentMode: 'Cash',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BillScreenStatus.error,
        errorMessage: 'Failed to save bill: $e',
      ));
    }
  }

  void _onClearBillRequested(ClearBillRequested event, Emitter<BillState> emit) {
    emit(state.copyWith(
      clearParty: true,
      clearVehicle: true,
      clearMaterial: true,
      firstWeightText: '',
      secondWeightText: '',
      rateText: '',
      remarksText: '',
      firstWeightKg: 0,
      secondWeightKg: 0,
      netWeightKg: 0,
      netWeightTon: 0,
      ratePerTon: 0,
      amount: 0,
      entryType: 'Inbound',
      paymentMode: 'Cash',
      clearError: true,
    ));
  }

  Future<void> _onLoadRecentBills(LoadRecentBills event, Emitter<BillState> emit) async {
    try {
      final bills = await _loadRecentBillsUseCase();
      emit(state.copyWith(recentBills: bills));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load recent bills'));
    }
  }
}
