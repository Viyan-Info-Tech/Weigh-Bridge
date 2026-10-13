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

/// Reloads the lookup lists (customers, materials) without touching anything
/// the operator has already entered on the form.
///
/// The bill screen is kept alive by an [IndexedStack], so it is built once per
/// session and `initState` never runs again. Master screens own their own blocs
/// and write straight to the database, so without this the dropdowns would keep
/// serving the snapshot taken at startup for the rest of the session.
class RefreshBillLookups extends BillEvent {
  const RefreshBillLookups();
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

class WeightUnitChanged extends BillEvent {
  final String value;
  const WeightUnitChanged(this.value);

  @override
  List<Object?> get props => [value];
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

class GrossWeightCommitted extends BillEvent {
  final String value;
  final DateTime? capturedAt;
  const GrossWeightCommitted(this.value, {this.capturedAt});

  @override
  List<Object?> get props => [value, capturedAt];
}

class TareWeightCommitted extends BillEvent {
  final String value;
  final DateTime? capturedAt;
  const TareWeightCommitted(this.value, {this.capturedAt});

  @override
  List<Object?> get props => [value, capturedAt];
}

class GrossCapturedAtChanged extends BillEvent {
  final DateTime? capturedAt;
  const GrossCapturedAtChanged(this.capturedAt);

  @override
  List<Object?> get props => [capturedAt];
}

class TareCapturedAtChanged extends BillEvent {
  final DateTime? capturedAt;
  const TareCapturedAtChanged(this.capturedAt);

  @override
  List<Object?> get props => [capturedAt];
}

class MobileNumberChanged extends BillEvent {
  final String value;
  const MobileNumberChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// Loads the auto tare configured for [date] (defaults to today).
class LoadAutoTare extends BillEvent {
  final DateTime? date;
  const LoadAutoTare({this.date});

  @override
  List<Object?> get props => [date];
}

/// Creates or replaces the day's auto tare. Bills already saved keep their
/// own tare value, so this only affects subsequent weighments.
///
/// [completer] lets the caller await the write. It is completed in all cases,
/// including when the resulting state is identical to the current one, which
/// emits nothing on the state stream.
class SaveAutoTare extends BillEvent {
  final double tareKg;
  final DateTime? date;
  final DateTime? savedAt;
  final Completer<void>? completer;

  const SaveAutoTare(this.tareKg, {this.date, this.savedAt, this.completer});

  @override
  List<Object?> get props => [tareKg, date, savedAt];
}

class DeleteAutoTare extends BillEvent {
  final DateTime? date;
  final Completer<void>? completer;

  const DeleteAutoTare({this.date, this.completer});

  @override
  List<Object?> get props => [date];
}

/// Copies the day's configured auto tare into the current weighment's tare
/// field (F3 / AUTO TARE button).
///
/// This only touches the bill being edited. The configured auto tare itself is
/// unchanged, and a tare already captured on this bill is replaced because the
/// operator explicitly asked for the day's common tare.
class ApplyAutoTareToBill extends BillEvent {
  const ApplyAutoTareToBill();

  @override
  List<Object?> get props => [];
}
