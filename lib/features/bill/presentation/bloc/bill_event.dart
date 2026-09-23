import 'dart:async';
import 'package:equatable/equatable.dart';

import '../../../customer/domain/entities/customer.dart';
import '../../../material/domain/entities/material_item.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object?> get props => [];
}

class LoadBillScreen extends BillEvent {
  const LoadBillScreen();
}

class CustomerSelected extends BillEvent {
  final Customer customer;
  const CustomerSelected(this.customer);

  @override
  List<Object?> get props => [customer];
}

class VehicleNumberChanged extends BillEvent {
  final String vehicleNumber;
  const VehicleNumberChanged(this.vehicleNumber);

  @override
  List<Object?> get props => [vehicleNumber];
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

class WeightUnitChanged extends BillEvent {
  final String value;
  const WeightUnitChanged(this.value);

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

class PrintReceiptDismissed extends BillEvent {
  const PrintReceiptDismissed();
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

class CustomerQuickAddRequested extends BillEvent {
  final String name;
  final String? contactPerson;
  const CustomerQuickAddRequested({required this.name, this.contactPerson});

  @override
  List<Object?> get props => [name, contactPerson];
}

class MaterialQuickAddRequested extends BillEvent {
  final String code;
  final String name;
  final Completer<MaterialItem?>? completer;

  const MaterialQuickAddRequested({
    required this.code,
    required this.name,
    this.completer,
  });

  @override
  List<Object?> get props => [code, name];
}

class MaterialCreatedToState extends BillEvent {
  final List<MaterialItem> materials;
  final MaterialItem selected;
  const MaterialCreatedToState({
    required this.materials,
    required this.selected,
  });

  @override
  List<Object?> get props => [materials, selected];
}

class CustomerCreatedToState extends BillEvent {
  final List<Customer> customers;
  final Customer selected;
  const CustomerCreatedToState({
    required this.customers,
    required this.selected,
  });

  @override
  List<Object?> get props => [customers, selected];
}

class CaptureLiveWeight extends BillEvent {
  final String type; // 'Gross' or 'Tare'
  const CaptureLiveWeight({required this.type});

  @override
  List<Object?> get props => [type];
}

class LiveScaleWeightUpdated extends BillEvent {
  final double weightKg;
  final bool? isStable;
  final bool? isMotion;
  final bool? isOverload;

  const LiveScaleWeightUpdated({
    required this.weightKg,
    this.isStable,
    this.isMotion,
    this.isOverload,
  });

  @override
  List<Object?> get props => [weightKg, isStable, isMotion, isOverload];
}

class WeightTypeSelected extends BillEvent {
  final String type; // 'Gross' or 'Tare'
  const WeightTypeSelected(this.type);

  @override
  List<Object?> get props => [type];
}

/// Loads a pending (single-weight) bill into the form so the operator
/// can capture the second weight and complete the weighment.
class LoadBillForContinue extends BillEvent {
  final int billId;
  const LoadBillForContinue(this.billId);

  @override
  List<Object?> get props => [billId];
}
