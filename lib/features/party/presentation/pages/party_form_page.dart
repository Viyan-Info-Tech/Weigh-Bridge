import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/party_bloc.dart';
import '../bloc/party_event.dart';
import '../bloc/party_state.dart';
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
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _addressController = TextEditingController();

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
    _cityController.dispose();
    _stateController.dispose();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormDialogTextField(label: 'Party Name', controller: _nameController, isRequired: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: FormDialogTextField(label: 'Contact Person', controller: _contactPersonController)),
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
              FormDialogTextField(label: 'GST Number', controller: _gstNumberController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: FormDialogTextField(label: 'City', controller: _cityController)),
                  const SizedBox(width: 16),
                  Expanded(child: FormDialogTextField(label: 'State', controller: _stateController)),
                ],
              ),
              const SizedBox(height: 16),
              FormDialogTextField(label: 'Address', controller: _addressController, maxLines: 2),
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
    );
  }

  void _populateForm(dynamic party) {
    _nameController.text = party.name;
    _contactPersonController.text = party.contactPerson ?? '';
    _mobileController.text = party.mobile ?? '';
    _emailController.text = party.email ?? '';
    _gstNumberController.text = party.gstNumber ?? '';
    _cityController.text = party.city ?? '';
    _stateController.text = party.state ?? '';
    _addressController.text = party.address ?? '';
  }

  void _saveParty() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Party name is required'), backgroundColor: Colors.red),
      );
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
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        state: _stateController.text.isNotEmpty ? _stateController.text : null,
      ));
    } else {
      context.read<PartyBloc>().add(CreatePartyRequested(
        name: _nameController.text,
        contactPerson: _contactPersonController.text.isNotEmpty ? _contactPersonController.text : null,
        mobile: _mobileController.text.isNotEmpty ? _mobileController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        gstNumber: _gstNumberController.text.isNotEmpty ? _gstNumberController.text : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        state: _stateController.text.isNotEmpty ? _stateController.text : null,
      ));
    }
  }
}
