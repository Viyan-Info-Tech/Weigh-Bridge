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
    required this.vehicleNumberController,
    required this.customerFocusNode,
    required this.vehicleFocusNode,
    required this.typeFocusNode,
    required this.materialFocusNode,
    required this.materialCodeFocusNode,
    required this.customerCodeFocusNode,
    required this.mobileFocusNode,
    required this.remarksFocusNode,
    required this.grossWeightFocusNode,
    required this.tareWeightFocusNode,
  });

  final TextEditingController grossWeightController;
  final TextEditingController tareWeightController;
  final TextEditingController remarksController;
  final TextEditingController vehicleNumberController;

  final FocusNode customerFocusNode;
  final FocusNode vehicleFocusNode;
  final FocusNode typeFocusNode;
  final FocusNode materialFocusNode;
  final FocusNode materialCodeFocusNode;
  final FocusNode customerCodeFocusNode;
  final FocusNode mobileFocusNode;
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
      mobileNumber: state.mobileNumber,
      customers: state.customers,
      materials: state.materials,
      selectedCustomer: state.selectedCustomer,
      vehicleNumber: state.vehicleNumber,
      selectedMaterial: state.selectedMaterial,
      grossWeightController: r.grossWeightController,
      tareWeightController: r.tareWeightController,
      remarksController: r.remarksController,
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
      customerFocusNode: r.customerFocusNode,
      vehicleFocusNode: r.vehicleFocusNode,
      typeFocusNode: r.typeFocusNode,
      materialFocusNode: r.materialFocusNode,
      materialCodeFocusNode: r.materialCodeFocusNode,
      customerCodeFocusNode: r.customerCodeFocusNode,
      mobileFocusNode: r.mobileFocusNode,
      remarksFocusNode: r.remarksFocusNode,
      grossWeightFocusNode: r.grossWeightFocusNode,
      tareWeightFocusNode: r.tareWeightFocusNode,
      onCustomerChanged: (customer) => bloc.add(CustomerSelected(customer)),
      onCustomerCodeSubmitted: (code) => bloc.findCustomerByCode(code),
      onVehicleNumberChanged: (vehicleNumber) =>
          bloc.add(VehicleNumberChanged(vehicleNumber)),
      onMaterialChanged: (material) => bloc.add(MaterialSelected(material)),
      onMaterialCodeSubmitted: (code) => bloc.findMaterialByCode(code),
      onGrossWeightChanged: (v) => bloc.add(GrossWeightChanged(v)),
      onTareWeightChanged: (v) => bloc.add(TareWeightChanged(v)),
      onGrossWeightCommitted: (v) => bloc.add(GrossWeightCommitted(v)),
      onTareWeightCommitted: (v) => bloc.add(TareWeightCommitted(v)),
      onGrossCapturedAtChanged: (v) => bloc.add(GrossCapturedAtChanged(v)),
      onTareCapturedAtChanged: (v) => bloc.add(TareCapturedAtChanged(v)),
      onRemarksChanged: (v) => bloc.add(RemarksChanged(v)),
      onWeightUnitChanged: (v) => bloc.add(WeightUnitChanged(v)),
      onMobileNumberChanged: (v) => bloc.add(MobileNumberChanged(v)),
      vehicleNumberError: state.vehicleNumberError,
      materialError: state.materialError,
      customerError: state.customerError,
      weightError: state.weightError,
      mobileError: state.mobileError,
    );
  }
}
