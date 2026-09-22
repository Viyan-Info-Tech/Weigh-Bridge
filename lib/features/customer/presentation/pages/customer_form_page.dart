import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../../../core/constants/indian_locations.dart';
import '../../../../core/presentation/widgets/form_dialog.dart';
import '../../../../core/utils/text_formatters.dart';

class CustomerFormDialog extends StatefulWidget {
  final int? customerId;

  const CustomerFormDialog({super.key, this.customerId});

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();

  static Future<void> show(BuildContext context, {int? customerId}) {
    return showDialog(
      context: context,
      builder: (_) => CustomerFormDialog(customerId: customerId),
    );
  }
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedState;
  String? _selectedCity;

  bool get isEditing => widget.customerId != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      context.read<CustomerBloc>().add(LoadCustomerDetail(widget.customerId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _gstNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state.status == CustomerStatus.success) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.successMessage ?? 'Customer saved successfully',
              ),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
          Navigator.pop(context);
        }
        if (state.status == CustomerStatus.error) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
        if (state.selectedCustomer != null && isEditing) {
          _populateForm(state.selectedCustomer!);
        }
      },
      child: FormDialogWrapper(
        title: isEditing ? 'Edit Customer' : 'Add Customer',
        subtitle: isEditing
            ? 'Update customer details'
            : 'Add a new customer to your records',
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormDialogTextField(
                  label: 'Customer Name',
                  controller: _nameController,
                  isRequired: true,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Customer name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FormDialogTextField(
                        label: 'Contact person name',
                        controller: _contactPersonController,
                        isRequired: true,
                        keyboardType: TextInputType.name,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z ]'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }

                          if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
                            return 'Name can contain letters only';
                          }

                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FormDialogTextField(
                        label: 'Phone Number',
                        controller: _mobileController,
                        inputFormatters: [PhoneNumberFormatter()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FormDialogTextField(
                  label: 'Email',
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                FormDialogTextField(
                  label: 'GST Number',
                  controller: _gstNumberController,
                  inputFormatters: [GSTNumberFormatter()],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null; // GST is optional
                    }

                    final gst = value.trim().toUpperCase();

                    if (gst.length != 15) {
                      return 'GST number must be 15 characters';
                    }

                    if (!RegExp(
                      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
                    ).hasMatch(gst)) {
                      return 'Enter a valid GST number';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCityDropdown()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStateDropdown()),
                  ],
                ),
                const SizedBox(height: 16),
                FormDialogTextField(
                  label: 'Address',
                  controller: _addressController,
                  hintText: 'Enter address',
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 24),
                FormDialogActions(
                  submitLabel: isEditing ? 'Update Customer' : 'Save Customer',
                  isLoading: _isLoading,
                  onSubmit: _saveCustomer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _populateForm(dynamic customer) {
    _nameController.text = customer.name;
    _contactPersonController.text = customer.contactPerson ?? '';
    _mobileController.text = customer.mobile ?? '';
    _emailController.text = customer.email ?? '';
    _gstNumberController.text = customer.gstNumber ?? '';
    _selectedState = customer.state != null && customer.state!.isNotEmpty
        ? customer.state
        : null;
    _selectedCity = customer.city != null && customer.city!.isNotEmpty
        ? customer.city
        : null;
    _addressController.text = customer.address ?? '';
  }

  void _saveCustomer() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    if (isEditing) {
      context.read<CustomerBloc>().add(
        UpdateCustomerRequested(
          id: widget.customerId!,
          name: _nameController.text,
          contactPerson: _contactPersonController.text.isNotEmpty
              ? _contactPersonController.text
              : null,
          mobile: _mobileController.text.isNotEmpty
              ? _mobileController.text
              : null,
          email: _emailController.text.isNotEmpty
              ? _emailController.text
              : null,
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : null,
          gstNumber: _gstNumberController.text.isNotEmpty
              ? _gstNumberController.text
              : null,
          city: _selectedCity,
          state: _selectedState,
        ),
      );
    } else {
      context.read<CustomerBloc>().add(
        CreateCustomerRequested(
          name: _nameController.text,
          contactPerson: _contactPersonController.text.isNotEmpty
              ? _contactPersonController.text
              : null,
          mobile: _mobileController.text.isNotEmpty
              ? _mobileController.text
              : null,
          email: _emailController.text.isNotEmpty
              ? _emailController.text
              : null,
          address: _addressController.text.isNotEmpty
              ? _addressController.text
              : null,
          gstNumber: _gstNumberController.text.isNotEmpty
              ? _gstNumberController.text
              : null,
          city: _selectedCity,
          state: _selectedState,
        ),
      );
    }
  }

  Widget _buildStateDropdown() {
    final states = indianStates;
    final allStates =
        (_selectedState != null && !states.contains(_selectedState))
        ? [_selectedState!, ...states]
        : states;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'State',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey('state_$_selectedState'),
          initialValue: _selectedState,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Select State',
            hintStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D3B82)),
            ),
            isDense: true,
          ),
          items: allStates.map((state) {
            return DropdownMenuItem<String>(
              value: state,
              child: Text(
                state,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedState = val;
              _selectedCity = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    final cities = getCitiesForState(_selectedState);
    final allCities = (_selectedCity != null && !cities.contains(_selectedCity))
        ? [_selectedCity!, ...cities]
        : cities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey('city_${_selectedState}_$_selectedCity'),
          initialValue: _selectedCity,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: _selectedState == null
                ? 'Select State first'
                : 'Select City',
            hintStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D3B82)),
            ),
            isDense: true,
          ),
          items: allCities.map((city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(
                city,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: _selectedState == null
              ? null
              : (val) {
                  setState(() {
                    _selectedCity = val;
                  });
                },
        ),
      ],
    );
  }
}
