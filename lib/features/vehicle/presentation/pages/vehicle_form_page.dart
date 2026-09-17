import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/text_formatters.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';
import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import '../../../vehicle_type/presentation/bloc/vehicle_type_bloc.dart';
import '../../../vehicle_type/presentation/bloc/vehicle_type_event.dart';
import '../../../vehicle_type/presentation/bloc/vehicle_type_state.dart';
import '../../../bill/presentation/widgets/quick_add_vehicle_type_dialog.dart';
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
  final GlobalKey _typeDropdownKey = GlobalKey();
  VehicleType? _newlyCreatedType;
  bool get isEditing => widget.vehicleId != null;
  bool _isLoading = false;
  bool _vehicleTypeHasError = false;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      context.read<VehicleBloc>().add(LoadVehicleById(widget.vehicleId!));
    }
    final vtState = context.read<VehicleTypeBloc>().state;
    if (vtState.vehicleTypes.isEmpty) {
      context.read<VehicleTypeBloc>().add(const LoadVehicleTypes());
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
            final selectedType = vehicleTypes.cast<VehicleType?>().firstWhere(
              (vt) => vt?.id == _selectedVehicleTypeId,
              orElse: () => _newlyCreatedType?.id == _selectedVehicleTypeId
                  ? _newlyCreatedType
                  : null,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  key: _typeDropdownKey,
                  onTap: _isLoading ? null : () => _showTypeMenu(vehicleTypes),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF0D3B82),
                          width: 1.5,
                        ),
                      ),
                      suffixIcon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      isDense: true,
                    ),
                    child: selectedType != null
                        ? Text(
                            selectedType.name,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F172A),
                            ),
                          )
                        : Text(
                            'Select vehicle type',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                ),
                if (_vehicleTypeHasError) ...[
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Vehicle type is required',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11.5,
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  void _showTypeMenu(List<VehicleType> vehicleTypes) async {
    if (_isLoading) return;

    final renderBox =
        _typeDropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final menuWidth = size.width;

    final allTypes = [
      ...vehicleTypes,
      if (_newlyCreatedType != null &&
          !vehicleTypes.any((vt) => vt.id == _newlyCreatedType!.id))
        _newlyCreatedType!,
    ];

    final items = <PopupMenuEntry<String>>[];

    for (final vt in allTypes) {
      items.add(
        PopupMenuItem<String>(
          value: 'type_${vt.id}',
          height: 38,
          child: SizedBox(
            width: menuWidth - 32,
            child: Row(
              children: [
                if (_selectedVehicleTypeId == vt.id)
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Color(0xFF0D3B82),
                  )
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vt.name,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    items.add(const PopupMenuDivider(height: 1));

    items.add(
      PopupMenuItem<String>(
        value: '__add_type__',
        height: 38,
        child: SizedBox(
          width: menuWidth - 32,
          child: const Row(
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: 16,
                color: Color(0xFF0D3B82),
              ),
              SizedBox(width: 8),
              Text(
                'Add Vehicle Type',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D3B82),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(
          renderBox.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: _typeDropdownKey.currentContext!,
      position: position,
      constraints: BoxConstraints(
        minWidth: renderBox.size.width,
        maxWidth: math.max(renderBox.size.width, 280),
        maxHeight: 350,
      ),
      items: items,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    if (result == '__add_type__') {
      if (mounted) {
        final vtBloc = context.read<VehicleTypeBloc>();
        final createdType = await QuickAddVehicleTypeDialog.show(
          context,
          onSave: (name, emptyPrice, loadPrice) async {
            return vtBloc.createVehicleType(name, emptyPrice, loadPrice);
          },
        );
        if (createdType != null && mounted) {
          setState(() {
            _newlyCreatedType = createdType;
            _selectedVehicleTypeId = createdType.id;
            _vehicleTypeHasError = false;
          });
        }
      }
    } else if (result != null && result.startsWith('type_')) {
      final id = int.tryParse(result.substring(5));
      if (id != null) {
        setState(() {
          _selectedVehicleTypeId = id;
          _vehicleTypeHasError = false;
        });
      }
    }
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
