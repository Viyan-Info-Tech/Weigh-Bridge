import 'package:equatable/equatable.dart';

import '../../domain/entities/party.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/material.dart';
import '../../domain/entities/weighment.dart';

enum BillScreenStatus { initial, loading, loaded, saving, saved, error }

class BillState extends Equatable {
  final BillScreenStatus status;
  final String? errorMessage;

  final List<Party> parties;
  final List<Vehicle> vehicles;
  final List<Material> materials;
  final List<Weighment> recentBills;

  final Party? selectedParty;
  final Vehicle? selectedVehicle;
  final Material? selectedMaterial;

  final String entryType;
  final String paymentMode;

  final String firstWeightText;
  final String secondWeightText;
  final String rateText;
  final String remarksText;

  final double firstWeightKg;
  final double secondWeightKg;
  final double netWeightKg;
  final double netWeightTon;
  final double ratePerTon;
  final double amount;

  final String currentBillNumber;

  const BillState({
    this.status = BillScreenStatus.initial,
    this.errorMessage,
    this.parties = const [],
    this.vehicles = const [],
    this.materials = const [],
    this.recentBills = const [],
    this.selectedParty,
    this.selectedVehicle,
    this.selectedMaterial,
    this.entryType = 'Inbound',
    this.paymentMode = 'Cash',
    this.firstWeightText = '',
    this.secondWeightText = '',
    this.rateText = '',
    this.remarksText = '',
    this.firstWeightKg = 0,
    this.secondWeightKg = 0,
    this.netWeightKg = 0,
    this.netWeightTon = 0,
    this.ratePerTon = 0,
    this.amount = 0,
    this.currentBillNumber = 'WB-00001',
  });

  BillState copyWith({
    BillScreenStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<Party>? parties,
    List<Vehicle>? vehicles,
    List<Material>? materials,
    List<Weighment>? recentBills,
    Party? selectedParty,
    bool clearParty = false,
    Vehicle? selectedVehicle,
    bool clearVehicle = false,
    Material? selectedMaterial,
    bool clearMaterial = false,
    String? entryType,
    String? paymentMode,
    String? firstWeightText,
    String? secondWeightText,
    String? rateText,
    String? remarksText,
    double? firstWeightKg,
    double? secondWeightKg,
    double? netWeightKg,
    double? netWeightTon,
    double? ratePerTon,
    double? amount,
    String? currentBillNumber,
  }) {
    return BillState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      parties: parties ?? this.parties,
      vehicles: vehicles ?? this.vehicles,
      materials: materials ?? this.materials,
      recentBills: recentBills ?? this.recentBills,
      selectedParty: clearParty ? null : (selectedParty ?? this.selectedParty),
      selectedVehicle: clearVehicle ? null : (selectedVehicle ?? this.selectedVehicle),
      selectedMaterial: clearMaterial ? null : (selectedMaterial ?? this.selectedMaterial),
      entryType: entryType ?? this.entryType,
      paymentMode: paymentMode ?? this.paymentMode,
      firstWeightText: firstWeightText ?? this.firstWeightText,
      secondWeightText: secondWeightText ?? this.secondWeightText,
      rateText: rateText ?? this.rateText,
      remarksText: remarksText ?? this.remarksText,
      firstWeightKg: firstWeightKg ?? this.firstWeightKg,
      secondWeightKg: secondWeightKg ?? this.secondWeightKg,
      netWeightKg: netWeightKg ?? this.netWeightKg,
      netWeightTon: netWeightTon ?? this.netWeightTon,
      ratePerTon: ratePerTon ?? this.ratePerTon,
      amount: amount ?? this.amount,
      currentBillNumber: currentBillNumber ?? this.currentBillNumber,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        parties,
        vehicles,
        materials,
        recentBills,
        selectedParty,
        selectedVehicle,
        selectedMaterial,
        entryType,
        paymentMode,
        firstWeightText,
        secondWeightText,
        rateText,
        remarksText,
        firstWeightKg,
        secondWeightKg,
        netWeightKg,
        netWeightTon,
        ratePerTon,
        amount,
        currentBillNumber,
      ];
}
