import 'package:equatable/equatable.dart';

import '../../domain/entities/party.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/material.dart';

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
  final Material material;
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

class RateChanged extends BillEvent {
  final String value;
  const RateChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class RemarksChanged extends BillEvent {
  final String value;
  const RemarksChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class EntryTypeChanged extends BillEvent {
  final String value;
  const EntryTypeChanged(this.value);

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

class ClearBillRequested extends BillEvent {
  const ClearBillRequested();
}

class LoadRecentBills extends BillEvent {
  const LoadRecentBills();
}
