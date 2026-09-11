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

  final Party? selectedParty;
  final Vehicle? selectedVehicle;
  final VehicleType? selectedVehicleType;
  final MaterialItem? selectedMaterial;

  final String paymentMode;

  final String firstWeightText;
  final String secondWeightText;
  final String remarksText;

  final double firstWeightKg;
  final double secondWeightKg;
  final double netWeightKg;
  final double vehicleCharge;
  final double amount;

  final String currentBillNumber;
  final int? editingBillId;

  const BillState({
    this.status = BillScreenStatus.initial,
    this.errorMessage,
    this.parties = const [],
    this.vehicles = const [],
    this.vehicleTypes = const [],
    this.materials = const [],
    this.recentBills = const [],
    this.pendingBills = const [],
    this.selectedParty,
    this.selectedVehicle,
    this.selectedVehicleType,
    this.selectedMaterial,
    this.paymentMode = 'Cash',
    this.firstWeightText = '',
    this.secondWeightText = '',
    this.remarksText = '',
    this.firstWeightKg = 0,
    this.secondWeightKg = 0,
    this.netWeightKg = 0,
    this.vehicleCharge = 0,
    this.amount = 0,
    this.currentBillNumber = 'WB-00001',
    this.editingBillId,
  });

  bool get isEditing => editingBillId != null;
  bool get isPending => secondWeightKg <= 0;
  bool get isCompleted => secondWeightKg > 0;

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
    Party? selectedParty,
    bool clearParty = false,
    Vehicle? selectedVehicle,
    bool clearVehicle = false,
    VehicleType? selectedVehicleType,
    bool clearVehicleType = false,
    MaterialItem? selectedMaterial,
    bool clearMaterial = false,
    String? paymentMode,
    String? firstWeightText,
    String? secondWeightText,
    String? remarksText,
    double? firstWeightKg,
    double? secondWeightKg,
    double? netWeightKg,
    double? vehicleCharge,
    double? amount,
    String? currentBillNumber,
    int? editingBillId,
    bool clearEditingBillId = false,
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
      selectedParty: clearParty ? null : (selectedParty ?? this.selectedParty),
      selectedVehicle: clearVehicle ? null : (selectedVehicle ?? this.selectedVehicle),
      selectedVehicleType: clearVehicleType ? null : (selectedVehicleType ?? this.selectedVehicleType),
      selectedMaterial: clearMaterial ? null : (selectedMaterial ?? this.selectedMaterial),
      paymentMode: paymentMode ?? this.paymentMode,
      firstWeightText: firstWeightText ?? this.firstWeightText,
      secondWeightText: secondWeightText ?? this.secondWeightText,
      remarksText: remarksText ?? this.remarksText,
      firstWeightKg: firstWeightKg ?? this.firstWeightKg,
      secondWeightKg: secondWeightKg ?? this.secondWeightKg,
      netWeightKg: netWeightKg ?? this.netWeightKg,
      vehicleCharge: vehicleCharge ?? this.vehicleCharge,
      amount: amount ?? this.amount,
      currentBillNumber: currentBillNumber ?? this.currentBillNumber,
      editingBillId: clearEditingBillId ? null : (editingBillId ?? this.editingBillId),
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
        selectedParty,
        selectedVehicle,
        selectedVehicleType,
        selectedMaterial,
        paymentMode,
        firstWeightText,
        secondWeightText,
        remarksText,
        firstWeightKg,
        secondWeightKg,
        netWeightKg,
        vehicleCharge,
        amount,
        currentBillNumber,
        editingBillId,
      ];
}
