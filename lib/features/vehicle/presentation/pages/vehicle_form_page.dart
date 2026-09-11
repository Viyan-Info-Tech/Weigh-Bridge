import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';
import '../../../party/presentation/bloc/party_bloc.dart';
import '../../../party/presentation/bloc/party_event.dart';
import '../../../party/presentation/bloc/party_state.dart';
import '../../../../core/presentation/widgets/form_dialog.dart';

class VehicleFormDialog extends StatefulWidget {
  final int? vehicleId;
  final int? partyId;

  const VehicleFormDialog({super.key, this.vehicleId, this.partyId});

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();

  static Future<void> show(BuildContext context, {int? vehicleId, int? partyId}) {
    return showDialog(
      context: context,
      builder: (_) => VehicleFormDialog(vehicleId: vehicleId, partyId: partyId),
    );
  }
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  final _vehicleNumberController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _tareWeightController = TextEditingController();

  int? _selectedPartyId;
  bool get isEditing => widget.vehicleId != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<PartyBloc>().add(const LoadParties());
    if (isEditing) {
      context.read<VehicleBloc>().add(LoadVehicleById(widget.vehicleId!));
    }
    if (widget.partyId != null) {
      _selectedPartyId = widget.partyId;
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _vehicleTypeController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _tareWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleBloc, VehicleState>(
      listener: (context, state) {
        if (state.status == VehicleStatus.success) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Vehicle saved successfully'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
          Navigator.pop(context);
        }
        if (state.status == VehicleStatus.error) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
        if (state.selectedVehicle != null && isEditing) {
          _populateForm(state.selectedVehicle!);
        }
      },
      child: FormDialogWrapper(
        title: isEditing ? 'Edit Vehicle' : 'Add Vehicle',
        subtitle: isEditing ? 'Update vehicle details' : 'Add vehicle details to your master',
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: FormDialogTextField(label: 'Vehicle Number', controller: _vehicleNumberController, isRequired: true)),
                  const SizedBox(width: 16),
                  Expanded(child: FormDialogTextField(label: 'Vehicle Type', controller: _vehicleTypeController, isRequired: true)),
                ],
              ),
              const SizedBox(height: 16),
              _buildPartyDropdown(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: FormDialogTextField(label: 'Driver Name', controller: _driverNameController)),
                  const SizedBox(width: 16),
                  Expanded(child: FormDialogTextField(label: 'Driver Phone', controller: _driverPhoneController)),
                ],
              ),
              const SizedBox(height: 16),
              FormDialogTextField(label: 'Tare Weight (kg)', controller: _tareWeightController, isNumeric: true),
              const SizedBox(height: 24),
              FormDialogActions(
                submitLabel: isEditing ? 'Update Vehicle' : 'Save Vehicle',
                isLoading: _isLoading,
                onSubmit: _saveVehicle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Party', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
            const SizedBox(width: 2),
            Text('*', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red.shade400)),
          ],
        ),
        const SizedBox(height: 6),
        BlocBuilder<PartyBloc, PartyState>(
          builder: (context, partyState) {
            final parties = partyState.parties;
            return DropdownButton<int>(
              value: _selectedPartyId,
              isExpanded: true,
              underline: const SizedBox(),
              hint: Text('Select party', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: Colors.grey.shade400)),
              items: parties.map((p) {
                return DropdownMenuItem<int>(
                  value: p.id,
                  child: Text(p.name, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13)),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedPartyId = v),
            );
          },
        ),
      ],
    );
  }

  void _populateForm(dynamic vehicle) {
    _vehicleNumberController.text = vehicle.vehicleNumber;
    _vehicleTypeController.text = vehicle.vehicleType ?? '';
    _driverNameController.text = vehicle.driverName ?? '';
    _driverPhoneController.text = vehicle.driverPhone ?? '';
    _tareWeightController.text = vehicle.tareWeight?.toString() ?? '';
    setState(() {
      _selectedPartyId = vehicle.partyId;
    });
  }

  void _saveVehicle() {
    if (_vehicleNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle number is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_vehicleTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle type is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedPartyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Party is required'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final tareWeight = double.tryParse(_tareWeightController.text);

    if (isEditing) {
      context.read<VehicleBloc>().add(UpdateVehicleRequested(
        id: widget.vehicleId!,
        vehicleNumber: _vehicleNumberController.text,
        partyId: _selectedPartyId!,
        vehicleType: _vehicleTypeController.text,
        driverName: _driverNameController.text.isNotEmpty ? _driverNameController.text : null,
        driverPhone: _driverPhoneController.text.isNotEmpty ? _driverPhoneController.text : null,
        tareWeight: tareWeight,
      ));
    } else {
      context.read<VehicleBloc>().add(CreateVehicleRequested(
        vehicleNumber: _vehicleNumberController.text,
        partyId: _selectedPartyId!,
        vehicleType: _vehicleTypeController.text,
        driverName: _driverNameController.text.isNotEmpty ? _driverNameController.text : null,
        driverPhone: _driverPhoneController.text.isNotEmpty ? _driverPhoneController.text : null,
        tareWeight: tareWeight,
      ));
    }
  }
}
