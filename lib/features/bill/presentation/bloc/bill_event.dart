import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object?> get props => [];
}

class LoadBillScreen extends BillEvent {
  const LoadBillScreen();
}

/// Reloads lookup-independent screen data without touching anything
/// the operator has already entered on the form.
///
/// The bill screen is kept alive by an [IndexedStack], so it is built once per
/// session. This event refreshes the bill number and recent bills while
/// leaving the in-progress weighment alone.
class RefreshBillLookups extends BillEvent {
  const RefreshBillLookups();
}

class VehicleNumberChanged extends BillEvent {
  final String vehicleNumber;
  const VehicleNumberChanged(this.vehicleNumber);

  @override
  List<Object?> get props => [vehicleNumber];
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

/// Material option selected on the weighment form's dropdown.
///
/// [value] is the option's display text (e.g. `Auto - Empty`); [materialId]
/// is the master row it came from. Legacy call sites that only pass text
/// leave [materialId] null, which stores a free-text material without a
/// master reference.
class MaterialChanged extends BillEvent {
  final String value;
  final int? materialId;
  const MaterialChanged(this.value, {this.materialId});

  @override
  List<Object?> get props => [value, materialId];
}

/// Manually entered Charges text on the weighment form.
///
/// The value is stored verbatim; validation happens on save so the operator's
/// in-progress input is never rewritten mid-typing.
class ChargesChanged extends BillEvent {
  final String value;
  const ChargesChanged(this.value);

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

/// Toggles the SECOND WEIGHT workflow on the weighment form.
///
/// When enabled, the GROSS/TARE selector is hidden and entering a vehicle
/// number retrieves that truck's previous single-weight bill. Toggling in
/// either direction drops every second-weight artefact (matched bill,
/// populated weight, messages) so no stale data survives a mode change.
class SecondWeightModeChanged extends BillEvent {
  final bool enabled;
  const SecondWeightModeChanged(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Looks up the previous weighment for the entered vehicle number.
///
/// The vehicle-number field triggers this automatically while SECOND WEIGHT
/// mode is active; it can also be dispatched directly (e.g. to retry after
/// fixing a typo).
class FetchPreviousWeightForVehicle extends BillEvent {
  const FetchPreviousWeightForVehicle();
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
