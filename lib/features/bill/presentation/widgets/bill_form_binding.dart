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
    required this.descriptionController,
    required this.vehicleNumberController,
    required this.vehicleFocusNode,
    required this.typeFocusNode,
    required this.materialFocusNode,
    required this.descriptionFocusNode,
    required this.remarksFocusNode,
    required this.grossWeightFocusNode,
    required this.tareWeightFocusNode,
  });

  final TextEditingController grossWeightController;
  final TextEditingController tareWeightController;
  final TextEditingController remarksController;
  final TextEditingController materialController;
  final TextEditingController descriptionController;
  final TextEditingController vehicleNumberController;

  final FocusNode vehicleFocusNode;
  final FocusNode typeFocusNode;
  final FocusNode materialFocusNode;
  final FocusNode descriptionFocusNode;
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

    return BillForm(
      key: ValueKey(state.formResetRevision),
      billNumber: state.currentBillNumber,
      materialText: state.materialText,
      descriptionText: state.descriptionText,
      vehicleNumber: state.vehicleNumber,
      grossWeightController: r.grossWeightController,
      tareWeightController: r.tareWeightController,
      remarksController: r.remarksController,
      materialController: r.materialController,
      descriptionController: r.descriptionController,
      vehicleNumberController: r.vehicleNumberController,
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
      vehicleFocusNode: r.vehicleFocusNode,
      typeFocusNode: r.typeFocusNode,
      materialFocusNode: r.materialFocusNode,
      descriptionFocusNode: r.descriptionFocusNode,
      remarksFocusNode: r.remarksFocusNode,
      grossWeightFocusNode: r.grossWeightFocusNode,
      tareWeightFocusNode: r.tareWeightFocusNode,
      onVehicleNumberChanged: (vehicleNumber) =>
          bloc.add(VehicleNumberChanged(vehicleNumber)),
      onMaterialChanged: (v) => bloc.add(MaterialChanged(v)),
      onDescriptionChanged: (v) => bloc.add(DescriptionChanged(v)),
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
    );
  }
}
