import 'package:flutter/material.dart';

import '../../../customer/domain/entities/customer.dart';
import '../../../material/domain/entities/material_item.dart' as domain;
import 'bill_form_field_shell.dart';

/// Read-only displays for the right column of [BillForm].
///
/// These fields only render values owned by the form, so they take plain
/// inputs and hold no state of their own.

/// 1. SERIAL NO
class BillFormSerialNoDisplay extends StatelessWidget {
  const BillFormSerialNoDisplay({super.key, required this.billNumber});

  final String billNumber;

  @override
  Widget build(BuildContext context) {
    return BillFormFieldShell(
      prefixText: '#',
      backgroundColor: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          billNumber,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

/// 2. MATERIAL NAME
class BillFormMaterialNameField extends StatelessWidget {
  const BillFormMaterialNameField({
    super.key,
    required this.materials,
    required this.selectedMaterial,
    required this.onChanged,
    this.focusNode,
  });

  final List<domain.MaterialItem> materials;
  final domain.MaterialItem? selectedMaterial;
  final FocusNode? focusNode;
  final ValueChanged<domain.MaterialItem> onChanged;

  @override
  Widget build(BuildContext context) {
    return BillFormFieldShell(
      prefixIcon: Icons.inventory_2_outlined,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<domain.MaterialItem>(
          value: selectedMaterial,
          focusNode: focusNode,
          isExpanded: true,
          hint: const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              'Select Material Name',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: Color(0xFF64748B),
            ),
          ),
          items: materials.map((m) {
            return DropdownMenuItem<domain.MaterialItem>(
              value: m,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  m.name,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (m) {
            if (m != null) onChanged(m);
          },
        ),
      ),
    );
  }
}

/// 3. CUSTOMER NAME
class BillFormCustomerNameField extends StatelessWidget {
  const BillFormCustomerNameField({
    super.key,
    required this.customers,
    required this.onChanged,
    this.selectedCustomer,
    this.focusNode,
  });

  final List<Customer> customers;
  final Customer? selectedCustomer;
  final FocusNode? focusNode;
  final ValueChanged<Customer> onChanged;

  @override
  Widget build(BuildContext context) {
    // Drift can return fresh Customer instances after a reload. Use the stable
    // primary key for dropdown values, and collapse any repeated IDs so each
    // selectable value occurs exactly once.
    final customersById = <int, Customer>{};
    for (final customer in customers) {
      customersById[customer.id] = customer;
    }
    final uniqueCustomers = customersById.values.toList(growable: false);
    final selectedCustomerId = customersById.containsKey(selectedCustomer?.id)
        ? selectedCustomer!.id
        : null;

    return BillFormFieldShell(
      prefixIcon: Icons.person_outline_rounded,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedCustomerId,
          focusNode: focusNode,
          isExpanded: true,
          hint: const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              'Select Customer Name',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: Color(0xFF64748B),
            ),
          ),
          items: uniqueCustomers.map((c) {
            return DropdownMenuItem<int>(
              value: c.id,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  c.name,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (customerId) {
            if (customerId == null) return;
            final customer = customersById[customerId];
            if (customer != null) onChanged(customer);
          },
        ),
      ),
    );
  }
}

/// 6. NET WEIGHT Display
class BillFormNetWeightDisplay extends StatelessWidget {
  const BillFormNetWeightDisplay({
    super.key,
    required this.grossWeightKg,
    required this.tareWeightKg,
    required this.netWeightKg,
    required this.weightUnit,
  });

  final double grossWeightKg;
  final double tareWeightKg;
  final double netWeightKg;
  final String weightUnit;

  @override
  Widget build(BuildContext context) {
    final isKg = weightUnit.toLowerCase() == 'kg';
    final hasCompleteWeight = grossWeightKg > 0 && tareWeightKg > 0;
    final String netDisplay = !hasCompleteWeight || netWeightKg <= 0
        ? '--'
        : isKg
        ? netWeightKg.toStringAsFixed(0)
        : (netWeightKg > 0 ? (netWeightKg / 1000).toStringAsFixed(3) : '--');

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
              border: Border(
                right: BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.scale_rounded,
              size: 20,
              color: Color(0xFF475569),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                netDisplay,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          Container(
            width: 54,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
              border: Border(
                left: BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              ),
            ),
            child: Text(
              isKg ? 'Kg' : 'Ton',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
