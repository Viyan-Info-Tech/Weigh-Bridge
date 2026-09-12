import 'package:equatable/equatable.dart';

import '../../../party/domain/entities/party.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import '../../../material/domain/entities/material_item.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object?> get props => [];
}

class LoadBillScreen extends BillEvent {
  const LoadBillScreen();
}

class PartySelected extends BillEvent {
  final Party party;
  const PartySelected(this.party);

  @override
  List<Object?> get props => [party];
}

class VehicleSelected extends BillEvent {
  final Vehicle vehicle;
  const VehicleSelected(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

class MaterialSelected extends BillEvent {
  final MaterialItem material;
  const MaterialSelected(this.material);

  @override
  List<Object?> get props => [material];
}

class GrossWeightChanged extends BillEvent {
  final String value;
  const GrossWeightChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class TareWeightChanged extends BillEvent {
  final String value;
  const TareWeightChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class RemarksChanged extends BillEvent {
  final String value;
  const RemarksChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class PaymentModeChanged extends BillEvent {
  final String value;
  const PaymentModeChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class VehicleChargeChanged extends BillEvent {
  final String value;
  const VehicleChargeChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class ResetVehicleCharge extends BillEvent {
  const ResetVehicleCharge();
}

class SaveBillRequested extends BillEvent {
  const SaveBillRequested();
}

class SaveAndPrintBillRequested extends BillEvent {
  const SaveAndPrintBillRequested();
}

class LoadPendingBill extends BillEvent {
  final int billId;
  const LoadPendingBill(this.billId);

  @override
  List<Object?> get props => [billId];
}

class LoadPendingBills extends BillEvent {
  const LoadPendingBills();
}

class ClearBillRequested extends BillEvent {
  const ClearBillRequested();
}

class LoadRecentBills extends BillEvent {
  final DateTime? date;
  final DateTime? startDate;
  final DateTime? endDate;
  const LoadRecentBills({this.date, this.startDate, this.endDate});

  @override
  List<Object?> get props => [date, startDate, endDate];
}

class PartyQuickAddRequested extends BillEvent {
  final String name;
  final String? contactPerson;
  const PartyQuickAddRequested({required this.name, this.contactPerson});

  @override
  List<Object?> get props => [name, contactPerson];
}

class VehicleQuickAddRequested extends BillEvent {
  final String vehicleNumber;
  final int vehicleTypeId;
  const VehicleQuickAddRequested({required this.vehicleNumber, required this.vehicleTypeId});

  @override
  List<Object?> get props => [vehicleNumber, vehicleTypeId];
}

class VehicleTypeQuickAddRequested extends BillEvent {
  final String name;
  final double emptyPrice;
  final double loadPrice;
  const VehicleTypeQuickAddRequested({required this.name, this.emptyPrice = 0, this.loadPrice = 0});

  @override
  List<Object?> get props => [name, emptyPrice, loadPrice];
}

class MaterialQuickAddRequested extends BillEvent {
  final String name;
  const MaterialQuickAddRequested({required this.name});

  @override
  List<Object?> get props => [name];
}

class MaterialCreatedToState extends BillEvent {
  final List<MaterialItem> materials;
  final MaterialItem selected;
  const MaterialCreatedToState({required this.materials, required this.selected});

  @override
  List<Object?> get props => [materials, selected];
}

class PartyCreatedToState extends BillEvent {
  final List<Party> parties;
  final Party selected;
  const PartyCreatedToState({required this.parties, required this.selected});

  @override
  List<Object?> get props => [parties, selected];
}

class VehicleTypeCreatedToState extends BillEvent {
  final List<VehicleType> vehicleTypes;
  final VehicleType selected;
  const VehicleTypeCreatedToState({required this.vehicleTypes, required this.selected});

  @override
  List<Object?> get props => [vehicleTypes, selected];
}
