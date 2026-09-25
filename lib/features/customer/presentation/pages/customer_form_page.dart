import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/form_dialog.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

class CustomerFormDialog extends StatefulWidget {
  final int? customerId;

  const CustomerFormDialog({super.key, this.customerId});

  static Future<void> show(BuildContext context, {int? customerId}) =>
      showDialog<void>(
        context: context,
        builder: (_) => CustomerFormDialog(customerId: customerId),
      );

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _populated = false;
  String? _codeErrorText;
  String? _nameErrorText;

  bool get isEditing => widget.customerId != null;

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
    _codeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<CustomerBloc, CustomerState>(
    listener: (context, state) {
      if (state.status == CustomerStatus.success) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
      } else if (state.status == CustomerStatus.error) {
        setState(() => _isLoading = false);
        final error = state.errorMessage ?? '';
        if (error.toLowerCase().contains('customer code "') &&
            error.toLowerCase().contains('already exists')) {
          setState(() {
            _codeErrorText =
                'Customer code "${_codeController.text.trim()}" already exists. Please enter a different code.';
          });
          _formKey.currentState?.validate();
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.isEmpty ? 'An error occurred' : error),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      final customer = state.selectedCustomer;
      if (customer != null && isEditing && !_populated) {
        _populated = true;
        _nameController.text = customer.name;
        _codeController.text = customer.customerCode;
        _phoneController.text = customer.mobile ?? '';
      }
    },
    child: FormDialogWrapper(
      title: isEditing ? 'Edit Customer' : 'Add Customer',
      subtitle: isEditing ? 'Update customer details' : 'Add a new customer',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FormDialogTextField(
              label: 'Customer Code',
              controller: _codeController,
              isRequired: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]')),
              ],
              validator: (value) {
                if (_codeErrorText != null) return _codeErrorText;
                final code = value?.trim() ?? '';
                if (code.isEmpty) {
                  return 'Customer code is required';
                }
                if (code.length > 30) {
                  return 'Customer code must be 30 characters or fewer';
                }
                return null;
              },
              onChanged: (_) {
                if (_codeErrorText != null) {
                  setState(() => _codeErrorText = null);
                  _formKey.currentState?.validate();
                }
              },
            ),
            const SizedBox(height: 16),
            FormDialogTextField(
              label: 'Customer Name',
              controller: _nameController,
              isRequired: true,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Customer name is required'
                  : _nameErrorText,
              onChanged: (_) {
                if (_nameErrorText != null) {
                  setState(() => _nameErrorText = null);
                  _formKey.currentState?.validate();
                }
              },
            ),
            const SizedBox(height: 16),
            FormDialogTextField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (phone.isNotEmpty && phone.length != 10) {
                  return 'Phone number must be exactly 10 digits';
                }
                return null;
              },
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
  );

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final name = _nameController.text.trim();
    final customerCode = _codeController.text.trim().toUpperCase();
    final phone = _phoneController.text.trim();
    try {
      final existing = await context.read<CustomerBloc>().findCustomerByCode(
        customerCode,
      );
      if (!mounted) return;
      if (existing != null && existing.id != widget.customerId) {
        setState(() {
          _isLoading = false;
          _codeErrorText =
              'Customer code "$customerCode" already exists. Please enter a different code.';
        });
        _formKey.currentState?.validate();
        return;
      }
      final duplicateName = await context
          .read<CustomerBloc>()
          .findCustomerByName(name);
      if (!mounted) return;
      if (duplicateName != null && duplicateName.id != widget.customerId) {
        setState(() {
          _isLoading = false;
          _nameErrorText = 'Customer name "$name" is already registered.';
        });
        _formKey.currentState?.validate();
        return;
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not check customer code: $error')),
      );
      return;
    }

    if (isEditing) {
      context.read<CustomerBloc>().add(
        UpdateCustomerRequested(
          id: widget.customerId!,
          name: name,
          customerCode: customerCode,
          mobile: phone.isEmpty ? null : phone,
        ),
      );
    } else {
      context.read<CustomerBloc>().add(
        CreateCustomerRequested(
          name: name,
          customerCode: customerCode,
          mobile: phone.isEmpty ? null : phone,
        ),
      );
    }
  }
}
