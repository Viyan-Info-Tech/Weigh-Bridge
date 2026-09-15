import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/party_bloc.dart';
import '../bloc/party_event.dart';
import '../bloc/party_state.dart';
import '../../../../core/constants/indian_locations.dart';
import '../../../../core/presentation/widgets/form_dialog.dart';
import '../../../../core/utils/text_formatters.dart';

class PartyFormDialog extends StatefulWidget {
  final int? partyId;

  const PartyFormDialog({super.key, this.partyId});

  @override
  State<PartyFormDialog> createState() => _PartyFormDialogState();

  static Future<void> show(BuildContext context, {int? partyId}) {
    return showDialog(
      context: context,
      builder: (_) => PartyFormDialog(partyId: partyId),
    );
  }
}

class _PartyFormDialogState extends State<PartyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedState;
  String? _selectedCity;

  bool get isEditing => widget.partyId != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      context.read<PartyBloc>().add(LoadPartyDetail(widget.partyId!));
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
    return BlocListener<PartyBloc, PartyState>(
      listener: (context, state) {
        if (state.status == PartyStatus.success) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Party saved successfully'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
          Navigator.pop(context);
        }
        if (state.status == PartyStatus.error) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
        if (state.selectedParty != null && isEditing) {
          _populateForm(state.selectedParty!);
        }
      },
      child: FormDialogWrapper(
        title: isEditing ? 'Edit Party' : 'Add Party',
        subtitle: isEditing ? 'Update party details' : 'Add a new party to your records',
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormDialogTextField(
                  label: 'Party Name',
                  controller: _nameController,
                  isRequired: true,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Party name is required' : null,
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
                  Expanded(child: FormDialogTextField(
                    label: 'Phone Number',
                    controller: _mobileController,
                    inputFormatters: [PhoneNumberFormatter()],
                  )),
                ],
              ),
              const SizedBox(height: 16),
              FormDialogTextField(label: 'Email', controller: _emailController),
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
                  Expanded(child: _buildStateDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCityDropdown()),
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
                  submitLabel: isEditing ? 'Update Party' : 'Save Party',
                  isLoading: _isLoading,
                  onSubmit: _saveParty,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _populateForm(dynamic party) {
    _nameController.text = party.name;
    _contactPersonController.text = party.contactPerson ?? '';
    _mobileController.text = party.mobile ?? '';
    _emailController.text = party.email ?? '';
    _gstNumberController.text = party.gstNumber ?? '';
    _selectedState = party.state != null && party.state!.isNotEmpty ? party.state : null;
    _selectedCity = party.city != null && party.city!.isNotEmpty ? party.city : null;
    _addressController.text = party.address ?? '';
  }

  void _saveParty() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    if (isEditing) {
      context.read<PartyBloc>().add(UpdatePartyRequested(
        id: widget.partyId!,
        name: _nameController.text,
        contactPerson: _contactPersonController.text.isNotEmpty ? _contactPersonController.text : null,
        mobile: _mobileController.text.isNotEmpty ? _mobileController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        gstNumber: _gstNumberController.text.isNotEmpty ? _gstNumberController.text : null,
        city: _selectedCity,
        state: _selectedState,
      ));
    } else {
      context.read<PartyBloc>().add(CreatePartyRequested(
        name: _nameController.text,
        contactPerson: _contactPersonController.text.isNotEmpty ? _contactPersonController.text : null,
        mobile: _mobileController.text.isNotEmpty ? _mobileController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        gstNumber: _gstNumberController.text.isNotEmpty ? _gstNumberController.text : null,
        city: _selectedCity,
        state: _selectedState,
      ));
    }
  }

  Widget _buildStateDropdown() {
    final states = indianStates;
    final allStates = (_selectedState != null && !states.contains(_selectedState))
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            hintText: _selectedState == null ? 'Select State first' : 'Select City',
            hintStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
