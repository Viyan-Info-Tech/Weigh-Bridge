import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/text_formatters.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';
import '../../../vehicle_type/presentation/bloc/vehicle_type_bloc.dart';
import '../../../vehicle_type/presentation/bloc/vehicle_type_state.dart';
import '../../../../core/presentation/widgets/form_dialog.dart';

class VehicleFormDialog extends StatefulWidget {
  final int? vehicleId;

  const VehicleFormDialog({super.key, this.vehicleId});

  @override
  State<VehicleFormDialog> createState() => _VehicleFormDialogState();

  static Future<void> show(BuildContext context, {int? vehicleId}) {
    return showDialog(
      context: context,
      builder: (_) => VehicleFormDialog(vehicleId: vehicleId),
    );
  }
}

class _VehicleFormDialogState extends State<VehicleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();

  int? _selectedVehicleTypeId;
  bool get isEditing => widget.vehicleId != null;
  bool _isLoading = false;
  bool _vehicleTypeHasError = false;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      context.read<VehicleBloc>().add(LoadVehicleById(widget.vehicleId!));
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
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
              content: Text(
                state.successMessage ?? 'Vehicle saved successfully',
              ),
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
        subtitle: isEditing
            ? 'Update vehicle details'
            : 'Add vehicle details to your master',
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormDialogTextField(
                  label: 'Vehicle Number',
                  controller: _vehicleNumberController,
                  isRequired: true,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    VehicleNumberFormatter(),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: validateVehicleNumber,
                ),
                const SizedBox(height: 16),
                _buildVehicleTypeDropdown(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FormDialogTextField(
                        label: 'Driver Name',
                        controller: _driverNameController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FormDialogTextField(
                        label: 'Driver Phone',
                        controller: _driverPhoneController,
                        inputFormatters: [PhoneNumberFormatter()],
                      ),
                    ),
                  ],
                ),
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
      ),
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Vehicle Type',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              '*',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        BlocBuilder<VehicleTypeBloc, VehicleTypeState>(
          builder: (context, vtState) {
            final vehicleTypes = vtState.vehicleTypes;
            return InputDecorator(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _vehicleTypeHasError
                        ? Colors.red.shade400
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _vehicleTypeHasError
                        ? Colors.red.shade400
                        : Colors.grey.shade300,
                  ),
                ),
                errorText: _vehicleTypeHasError
                    ? 'Vehicle type is required'
                    : null,
                isDense: true,
              ),
              child: DropdownButton<int>(
                value: _selectedVehicleTypeId,
                isExpanded: true,
                underline: const SizedBox(),
                hint: Text(
                  'Select vehicle type',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
                items: vehicleTypes.map((vt) {
                  return DropdownMenuItem<int>(
                    value: vt.id,
                    child: Text(
                      vt.name,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() {
                  _selectedVehicleTypeId = v;
                  _vehicleTypeHasError = false;
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  void _populateForm(dynamic vehicle) {
    _vehicleNumberController.text = vehicle.vehicleNumber;
    _driverNameController.text = vehicle.driverName ?? '';
    _driverPhoneController.text = vehicle.driverPhone ?? '';
    setState(() {
      _selectedVehicleTypeId = vehicle.vehicleTypeId;
    });
  }

  void _saveVehicle() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (_selectedVehicleTypeId == null) {
      setState(() => _vehicleTypeHasError = true);
    } else {
      setState(() => _vehicleTypeHasError = false);
    }
    if (!isFormValid || _selectedVehicleTypeId == null) return;

    setState(() => _isLoading = true);

    if (isEditing) {
      context.read<VehicleBloc>().add(
        UpdateVehicleRequested(
          id: widget.vehicleId!,
          vehicleNumber: _vehicleNumberController.text,
          vehicleTypeId: _selectedVehicleTypeId!,
          driverName: _driverNameController.text.isNotEmpty
              ? _driverNameController.text
              : null,
          driverPhone: _driverPhoneController.text.isNotEmpty
              ? _driverPhoneController.text
              : null,
        ),
      );
    } else {
      context.read<VehicleBloc>().add(
        CreateVehicleRequested(
          vehicleNumber: _vehicleNumberController.text,
          vehicleTypeId: _selectedVehicleTypeId!,
          driverName: _driverNameController.text.isNotEmpty
              ? _driverNameController.text
              : null,
          driverPhone: _driverPhoneController.text.isNotEmpty
              ? _driverPhoneController.text
              : null,
        ),
      );
    }
  }
}
