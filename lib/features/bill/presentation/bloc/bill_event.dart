import 'package:equatable/equatable.dart';

import '../../../party/domain/entities/party.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
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

class FirstWeightChanged extends BillEvent {
  final String value;
  const FirstWeightChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class SecondWeightChanged extends BillEvent {
  final String value;
  const SecondWeightChanged(this.value);

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

class ClearBillRequested extends BillEvent {
  const ClearBillRequested();
}

class LoadRecentBills extends BillEvent {
  const LoadRecentBills();
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
