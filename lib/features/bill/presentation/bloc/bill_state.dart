import 'package:equatable/equatable.dart';

import '../../../party/domain/entities/party.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import '../../../material/domain/entities/material_item.dart';
import '../../domain/entities/weighment.dart';

enum BillScreenStatus { initial, loading, loaded, saving, saved, printing, error }

class BillState extends Equatable {
  final BillScreenStatus status;
  final String? errorMessage;

  final List<Party> parties;
  final List<Vehicle> vehicles;
  final List<VehicleType> vehicleTypes;
  final List<MaterialItem> materials;
  final List<Weighment> recentBills;
  final List<Weighment> pendingBills;
  final DateTime? billsDate;
  final DateTime? billsStartDate;
  final DateTime? billsEndDate;

  final Party? selectedParty;
  final Vehicle? selectedVehicle;
  final VehicleType? selectedVehicleType;
  final MaterialItem? selectedMaterial;

  final String paymentMode;

  final String grossWeightText;
  final String tareWeightText;
  final String remarksText;

  final double grossWeightKg;
  final double tareWeightKg;
  final double netWeightKg;
  final double vehicleCharge;
  final double defaultVehicleCharge;
  final bool isVehicleChargeManuallyEdited;
  final double amount;

  final String currentBillNumber;
  final int? editingBillId;
  final String? editingFirstWeightType;
  final double? editingFirstWeightKg;
  final String? weightValidationError;

  const BillState({
    this.status = BillScreenStatus.initial,
    this.errorMessage,
    this.parties = const [],
    this.vehicles = const [],
    this.vehicleTypes = const [],
    this.materials = const [],
    this.recentBills = const [],
    this.pendingBills = const [],
    this.billsDate,
    this.billsStartDate,
    this.billsEndDate,
    this.selectedParty,
    this.selectedVehicle,
    this.selectedVehicleType,
    this.selectedMaterial,
    this.paymentMode = 'Cash',
    this.grossWeightText = '',
    this.tareWeightText = '',
    this.remarksText = '',
    this.grossWeightKg = 0,
    this.tareWeightKg = 0,
    this.netWeightKg = 0,
    this.vehicleCharge = 0,
    this.defaultVehicleCharge = 0,
    this.isVehicleChargeManuallyEdited = false,
    this.amount = 0,
    this.currentBillNumber = 'WB-00001',
    this.editingBillId,
    this.editingFirstWeightType,
    this.editingFirstWeightKg,
    this.weightValidationError,
  });

  bool get isEditing => editingBillId != null;
  bool get isCompleted => grossWeightKg > 0 && tareWeightKg > 0;
  bool get isPending => !isCompleted;

  DateTime get effectiveBillsDate {
    final d = billsDate ?? DateTime.now();
    return DateTime(d.year, d.month, d.day);
  }

  bool get isViewingTodaysBills {
    final now = DateTime.now();
    final d = effectiveBillsDate;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool get hasDateRange => billsStartDate != null || billsEndDate != null;
  bool get hasWeightError => weightValidationError != null;

  BillState copyWith({
    BillScreenStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<Party>? parties,
    List<Vehicle>? vehicles,
    List<VehicleType>? vehicleTypes,
    List<MaterialItem>? materials,
    List<Weighment>? recentBills,
    List<Weighment>? pendingBills,
    DateTime? billsDate,
    DateTime? billsStartDate,
    DateTime? billsEndDate,
    bool clearDateRange = false,
    Party? selectedParty,
    bool clearParty = false,
    Vehicle? selectedVehicle,
    bool clearVehicle = false,
    VehicleType? selectedVehicleType,
    bool clearVehicleType = false,
    MaterialItem? selectedMaterial,
    bool clearMaterial = false,
    String? paymentMode,
    String? grossWeightText,
    String? tareWeightText,
    String? remarksText,
    double? grossWeightKg,
    double? tareWeightKg,
    double? netWeightKg,
    double? vehicleCharge,
    double? defaultVehicleCharge,
    bool clearManualCharge = false,
    bool? isVehicleChargeManuallyEdited,
    double? amount,
    String? currentBillNumber,
    int? editingBillId,
    bool clearEditingBillId = false,
    String? editingFirstWeightType,
    double? editingFirstWeightKg,
    bool clearEditingFirstWeight = false,
    String? weightValidationError,
    bool clearWeightError = false,
  }) {
    return BillState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      parties: parties ?? this.parties,
      vehicles: vehicles ?? this.vehicles,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      materials: materials ?? this.materials,
      recentBills: recentBills ?? this.recentBills,
      pendingBills: pendingBills ?? this.pendingBills,
      billsDate: billsDate ?? this.billsDate,
      billsStartDate: clearDateRange ? null : (billsStartDate ?? this.billsStartDate),
      billsEndDate: clearDateRange ? null : (billsEndDate ?? this.billsEndDate),
      selectedParty: clearParty ? null : (selectedParty ?? this.selectedParty),
      selectedVehicle: clearVehicle ? null : (selectedVehicle ?? this.selectedVehicle),
      selectedVehicleType: clearVehicleType ? null : (selectedVehicleType ?? this.selectedVehicleType),
      selectedMaterial: clearMaterial ? null : (selectedMaterial ?? this.selectedMaterial),
      paymentMode: paymentMode ?? this.paymentMode,
      grossWeightText: grossWeightText ?? this.grossWeightText,
      tareWeightText: tareWeightText ?? this.tareWeightText,
      remarksText: remarksText ?? this.remarksText,
      grossWeightKg: grossWeightKg ?? this.grossWeightKg,
      tareWeightKg: tareWeightKg ?? this.tareWeightKg,
      netWeightKg: netWeightKg ?? this.netWeightKg,
      vehicleCharge: vehicleCharge ?? this.vehicleCharge,
      defaultVehicleCharge: clearManualCharge ? (vehicleCharge ?? this.vehicleCharge) : (defaultVehicleCharge ?? this.defaultVehicleCharge),
      isVehicleChargeManuallyEdited: clearManualCharge ? false : (isVehicleChargeManuallyEdited ?? this.isVehicleChargeManuallyEdited),
      amount: amount ?? this.amount,
      currentBillNumber: currentBillNumber ?? this.currentBillNumber,
      editingBillId: clearEditingBillId ? null : (editingBillId ?? this.editingBillId),
      editingFirstWeightType: clearEditingFirstWeight ? null : (editingFirstWeightType ?? this.editingFirstWeightType),
      editingFirstWeightKg: clearEditingFirstWeight ? null : (editingFirstWeightKg ?? this.editingFirstWeightKg),
      weightValidationError: clearWeightError ? null : (weightValidationError ?? this.weightValidationError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        parties,
        vehicles,
        vehicleTypes,
        materials,
        recentBills,
        pendingBills,
        billsDate,
        billsStartDate,
        billsEndDate,
        selectedParty,
        selectedVehicle,
        selectedVehicleType,
        selectedMaterial,
        paymentMode,
        grossWeightText,
        tareWeightText,
        remarksText,
        grossWeightKg,
        tareWeightKg,
        netWeightKg,
        vehicleCharge,
        defaultVehicleCharge,
        isVehicleChargeManuallyEdited,
        amount,
        currentBillNumber,
        editingBillId,
        editingFirstWeightType,
        editingFirstWeightKg,
        weightValidationError,
      ];
}
