import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bill_bloc.dart';
import '../bloc/bill_event.dart';
import '../bloc/bill_state.dart';
import 'bill_form.dart';

/// Controllers and focus nodes owned by the weighment screen and shared with
/// the form.
///
/// They live here so [BillFormBinding] can rebuild the form without the page
/// re-listing every field.
class BillFormResources {
  const BillFormResources({
    required this.grossWeightController,
    required this.tareWeightController,
    required this.remarksController,
    required this.materialController,
    required this.vehicleNumberController,
    required this.vehicleFocusNode,
    required this.typeFocusNode,
    required this.materialFocusNode,
    required this.remarksFocusNode,
    required this.grossWeightFocusNode,
    required this.tareWeightFocusNode,
    this.chargesController,
    this.chargesFocusNode,
  });

  final TextEditingController grossWeightController;
  final TextEditingController tareWeightController;
  final TextEditingController remarksController;
  final TextEditingController materialController;
  final TextEditingController vehicleNumberController;

  /// Optional: only supplied when the screen wires the Charges field.
  final TextEditingController? chargesController;

  final FocusNode vehicleFocusNode;
  final FocusNode typeFocusNode;
  final FocusNode materialFocusNode;
  final FocusNode? chargesFocusNode;
  final FocusNode remarksFocusNode;
  final FocusNode grossWeightFocusNode;
  final FocusNode tareWeightFocusNode;
}

/// Binds a [BillState] and the screen's [BillFormResources] to [BillForm],
/// forwarding every user action to [BillBloc].
///
/// This is the single place that maps bloc state and events onto the form's
/// parameters, so a change to either side only needs updating here.
class BillFormBinding extends StatelessWidget {
  const BillFormBinding({
    super.key,
    required this.state,
    required this.resources,
  });

  final BillState state;
  final BillFormResources resources;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BillBloc>();
    final r = resources;

    // `Name - Type` labels for the dropdown; the id is resolved back from the
    // picked label so the saved bill can carry the master reference too.
    final materialOptions = state.materialOptions
        .map((material) => material.displayValue)
        .toList();

    return BillForm(
      key: ValueKey(state.formResetRevision),
      billNumber: state.currentBillNumber,
      materialText: state.materialText,
      materialOptions: materialOptions,
      chargesText: state.chargesText,
      vehicleNumber: state.vehicleNumber,
      grossWeightController: r.grossWeightController,
      tareWeightController: r.tareWeightController,
      remarksController: r.remarksController,
      materialController: r.materialController,
      vehicleNumberController: r.vehicleNumberController,
      chargesController: r.chargesController,
      grossWeightKg: state.grossWeightKg,
      tareWeightKg: state.tareWeightKg,
      netWeightKg: state.netWeightKg,
      weightUnit: state.weightUnit,
      weightValidationError: state.weightValidationError,
      isReady:
          state.status == BillScreenStatus.loaded ||
          state.status == BillScreenStatus.saved ||
          state.status == BillScreenStatus.error,
      grossCapturedAt: state.grossCapturedAt,
      tareCapturedAt: state.tareCapturedAt,
      selectedType: state.selectedWeightType,
      onTypeChanged: (type) => bloc.add(WeightTypeSelected(type)),
      isSecondWeightMode: state.isSecondWeightMode,
      isFetchingPreviousWeight: state.isFetchingPreviousWeight,
      previousWeightType: state.previousWeightType,
      previousBillNumber: state.previousWeighment?.billNumber,
      previousWeightText: state.hasPreviousWeighment
          ? _previousWeightDisplayText(state)
          : null,
      previousCapturedAt: state.previousWeighment?.createdAt,
      previousWeightMessage: state.previousWeightMessage,
      onSecondWeightToggle: () => bloc.add(
        SecondWeightModeChanged(!state.isSecondWeightMode),
      ),
      vehicleFocusNode: r.vehicleFocusNode,
      typeFocusNode: r.typeFocusNode,
      materialFocusNode: r.materialFocusNode,
      chargesFocusNode: r.chargesFocusNode,
      remarksFocusNode: r.remarksFocusNode,
      grossWeightFocusNode: r.grossWeightFocusNode,
      tareWeightFocusNode: r.tareWeightFocusNode,
      onVehicleNumberChanged: (vehicleNumber) =>
          bloc.add(VehicleNumberChanged(vehicleNumber)),
      onMaterialChanged: (value) {
        int? materialId;
        for (final material in state.materialOptions) {
          if (material.displayValue == value) {
            materialId = material.id;
            break;
          }
        }
        bloc.add(MaterialChanged(value, materialId: materialId));
      },
      onChargesChanged: (v) => bloc.add(ChargesChanged(v)),
      onGrossWeightChanged: (v) => bloc.add(GrossWeightChanged(v)),
      onTareWeightChanged: (v) => bloc.add(TareWeightChanged(v)),
      onGrossWeightCommitted: (v) => bloc.add(GrossWeightCommitted(v)),
      onTareWeightCommitted: (v) => bloc.add(TareWeightCommitted(v)),
      onGrossCapturedAtChanged: (v) => bloc.add(GrossCapturedAtChanged(v)),
      onTareCapturedAtChanged: (v) => bloc.add(TareCapturedAtChanged(v)),
      onRemarksChanged: (v) => bloc.add(RemarksChanged(v)),
      onWeightUnitChanged: (v) => bloc.add(WeightUnitChanged(v)),
      vehicleNumberError: state.vehicleNumberError,
      weightError: state.weightError,
      chargesError: state.chargesError,
    );
  }
}

/// Formats the previous weighment's captured weight for the status banner,
/// converted into the form's current display unit (kg or ton).
///
/// Mirrors the bloc's own conversion when it populates the weight field, so
/// the banner and the locked field always agree.
String _previousWeightDisplayText(BillState state) {
  final previous = state.previousWeighment;
  if (previous == null) return '';
  final weightKg = state.previousWeightType == 'TARE'
      ? previous.tareWeightKg
      : previous.grossWeightKg;
  if (weightKg == null || !weightKg.isFinite) return '';
  final isTon = state.weightUnit.toLowerCase() == 'ton';
  final displayValue = isTon ? weightKg / 1000 : weightKg;
  final unit = isTon ? 'ton' : 'kg';
  final text = isTon
      ? displayValue.toStringAsFixed(3)
      : displayValue.toStringAsFixed(0);
  return '$text $unit';
}
