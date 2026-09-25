import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();

  int? _editingCustomerId;
  bool _saving = false;
  String? _codeErrorText;
  String? _nameErrorText;

  bool get _isEditing => _editingCustomerId != null;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const LoadCustomers());
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startEdit(Customer customer) {
    setState(() {
      _editingCustomerId = customer.id;
      _codeController.text = customer.customerCode;
      _nameController.text = customer.name;
      _phoneController.text = customer.mobile ?? '';
      _codeErrorText = null;
      _nameErrorText = null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingCustomerId = null;
      _codeController.clear();
      _nameController.clear();
      _phoneController.clear();
      _codeErrorText = null;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    final code = _codeController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    setState(() => _saving = true);
    try {
      final existing = await context.read<CustomerBloc>().findCustomerByCode(
        code,
      );
      if (!mounted) return;
      if (existing != null && existing.id != _editingCustomerId) {
        setState(() {
          _saving = false;
          _codeErrorText =
              'Customer code "$code" already exists. Please enter a different code.';
        });
        _formKey.currentState?.validate();
        return;
      }
      final duplicateName = await context
          .read<CustomerBloc>()
          .findCustomerByName(name);
      if (!mounted) return;
      if (duplicateName != null && duplicateName.id != _editingCustomerId) {
        setState(() {
          _saving = false;
          _nameErrorText = 'Customer name "$name" is already registered.';
        });
        _formKey.currentState?.validate();
        return;
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not check customer code: $error')),
      );
      return;
    }

    if (_isEditing) {
      context.read<CustomerBloc>().add(
        UpdateCustomerRequested(
          id: _editingCustomerId!,
          customerCode: code,
          name: name,
          mobile: phone.isEmpty ? null : phone,
        ),
      );
    } else {
      context.read<CustomerBloc>().add(
        CreateCustomerRequested(
          customerCode: code,
          name: name,
          mobile: phone.isEmpty ? null : phone,
        ),
      );
    }
  }

  void _confirmDelete(Customer customer) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete customer?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${customer.name}" (${customer.customerCode})?\nThis action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Color(0xFF475569),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () {
              context.read<CustomerBloc>().add(
                DeleteCustomerRequested(customer.id),
              );
              if (_editingCustomerId == customer.id) _cancelEdit();
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (!_saving) return;
        if (state.status == CustomerStatus.success) {
          setState(() => _saving = false);
          _cancelEdit();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Customer saved'),
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } else if (state.status == CustomerStatus.error) {
          setState(() => _saving = false);
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
              content: Text(error.isEmpty ? 'Could not save customer' : error),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Card: ADD / EDIT CUSTOMER
                      SizedBox(width: 320, child: _buildAddCustomerCard()),
                      const SizedBox(width: 16),
                      // Right Card: CUSTOMERS LIST
                      Expanded(child: _buildCustomersCard()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Master',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Manage customers',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCustomerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'EDIT CUSTOMER' : 'ADD CUSTOMER',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                    letterSpacing: 0.5,
                  ),
                ),
                if (_isEditing)
                  InkWell(
                    onTap: _cancelEdit,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // 1. Customer Code *
            _buildFieldLabel('Customer Code', isRequired: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]')),
              ],
              validator: (v) {
                if (_codeErrorText != null) return _codeErrorText;
                final s = v?.trim() ?? '';
                if (s.isEmpty) return 'Customer code is required';
                if (s.length > 30) return 'Max 30 characters';
                return null;
              },
              onChanged: (_) {
                if (_codeErrorText != null) {
                  setState(() => _codeErrorText = null);
                  _formKey.currentState?.validate();
                }
              },
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 14),

            // 2. Customer Name *
            _buildFieldLabel('Customer Name', isRequired: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return 'Customer name is required';
                return _nameErrorText;
              },
              onChanged: (_) {
                if (_nameErrorText != null) {
                  setState(() => _nameErrorText = null);
                  _formKey.currentState?.validate();
                }
              },
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 14),

            // 3. Phone Number
            _buildFieldLabel('Phone Number', isRequired: false),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isNotEmpty && s.length != 10) {
                  return 'Enter a valid 10-digit number';
                }
                return null;
              },
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: _inputDecoration(),
            ),

            const Spacer(),

            // Save Customer Button pinned at bottom
            SizedBox(
              width: double.infinity,
              height: 42,
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveCustomer,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded, size: 18),
                label: Text(
                  _saving
                      ? 'Saving...'
                      : _isEditing
                      ? 'Update Customer'
                      : 'Save Customer',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF174A8B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomersCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CUSTOMERS',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF334155),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(
                width: 240,
                height: 36,
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      context.read<CustomerBloc>().add(SearchCustomers(v)),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search customers',
                    hintStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF174A8B),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state.status == CustomerStatus.loading &&
                    state.customers.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                if (state.customers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No customers found',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: state.customers.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, i) {
                    final customer = state.customers[i];
                    final isSelected = _editingCustomerId == customer.id;

                    return InkWell(
                      onTap: () => _startEdit(customer),
                      borderRadius: BorderRadius.circular(6),
                      hoverColor: const Color(0xFFF8FAFC),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEFF6FF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    customer.name,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (customer.customerCode.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${customer.customerCode})',
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                  if (customer.mobile?.isNotEmpty == true) ...[
                                    const SizedBox(width: 12),
                                    Text(
                                      customer.mobile!,
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 11.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 17,
                                    color: Color(0xFF64748B),
                                  ),
                                  tooltip: 'Edit',
                                  splashRadius: 18,
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _startEdit(customer),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 17,
                                    color: Color(0xFFDC2626),
                                  ),
                                  tooltip: 'Delete',
                                  splashRadius: 18,
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _confirmDelete(customer),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {required bool isRequired}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF174A8B), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
    );
  }
}
