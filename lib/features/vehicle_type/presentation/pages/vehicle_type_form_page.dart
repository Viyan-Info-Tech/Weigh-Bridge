import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/vehicle_type_bloc.dart';
import '../bloc/vehicle_type_event.dart';
import '../bloc/vehicle_type_state.dart';
import '../../../../core/presentation/widgets/form_dialog.dart';

class VehicleTypeFormDialog extends StatefulWidget {
  final dynamic vehicleType;

  const VehicleTypeFormDialog({super.key, this.vehicleType});

  @override
  State<VehicleTypeFormDialog> createState() => _VehicleTypeFormDialogState();

  static Future<void> show(BuildContext context, {dynamic vehicleType}) {
    return showDialog(
      context: context,
      builder: (_) => VehicleTypeFormDialog(vehicleType: vehicleType),
    );
  }
}

class _VehicleTypeFormDialogState extends State<VehicleTypeFormDialog> {
  final _nameController = TextEditingController();
  final _emptyPriceController = TextEditingController();
  final _loadPriceController = TextEditingController();

  bool get isEditing => widget.vehicleType != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateForm(widget.vehicleType);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emptyPriceController.dispose();
    _loadPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleTypeBloc, VehicleTypeState>(
      listener: (context, state) {
        if (state.status == VehicleTypeStatus.success) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.successMessage ?? 'Vehicle type saved successfully',
              ),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
          Navigator.pop(context);
        }
        if (state.status == VehicleTypeStatus.error) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      child: FormDialogWrapper(
        title: isEditing ? 'Edit Vehicle Type' : 'Add Vehicle Type',
        subtitle: isEditing
            ? 'Update vehicle type details'
            : 'Add a new vehicle type to your master',
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormDialogTextField(
                label: 'Name',
                controller: _nameController,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormDialogTextField(
                      label: 'Empty Price',
                      controller: _emptyPriceController,
                      isNumeric: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FormDialogTextField(
                      label: 'Load Price',
                      controller: _loadPriceController,
                      isNumeric: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FormDialogActions(
                submitLabel: isEditing
                    ? 'Update Vehicle Type'
                    : 'Save Vehicle Type',
                isLoading: _isLoading,
                onSubmit: _saveVehicleType,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _populateForm(dynamic vehicleType) {
    _nameController.text = vehicleType.name;
    _emptyPriceController.text = vehicleType.emptyPrice.toString();
    _loadPriceController.text = vehicleType.loadPrice.toString();
  }

  void _saveVehicleType() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final emptyPrice = double.tryParse(_emptyPriceController.text) ?? 0;
    final loadPrice = double.tryParse(_loadPriceController.text) ?? 0;

    setState(() => _isLoading = true);

    if (isEditing) {
      context.read<VehicleTypeBloc>().add(
        UpdateVehicleTypeRequested(
          id: widget.vehicleType.id,
          name: _nameController.text,
          emptyPrice: emptyPrice,
          loadPrice: loadPrice,
        ),
      );
    } else {
      context.read<VehicleTypeBloc>().add(
        CreateVehicleTypeRequested(
          name: _nameController.text,
          emptyPrice: emptyPrice,
          loadPrice: loadPrice,
        ),
      );
    }
  }
}
