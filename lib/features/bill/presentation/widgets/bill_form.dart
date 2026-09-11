import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';

import '../../domain/entities/party.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/material.dart' as domain;

class BillForm extends StatelessWidget {
  final String billNumber;
  final List<Party> parties;
  final List<Vehicle> vehicles;
  final List<domain.Material> materials;
  final Party? selectedParty;
  final Vehicle? selectedVehicle;
  final domain.Material? selectedMaterial;
  final String entryType;
  final String paymentMode;
  final String firstWeightText;
  final String secondWeightText;
  final String rateText;
  final double netWeightKg;
  final double amount;
  final String remarksText;

  final ValueChanged<Party> onPartyChanged;
  final ValueChanged<Vehicle> onVehicleChanged;
  final ValueChanged<domain.Material> onMaterialChanged;
  final ValueChanged<String> onFirstWeightChanged;
  final ValueChanged<String> onSecondWeightChanged;
  final ValueChanged<String> onRateChanged;
  final ValueChanged<String> onRemarksChanged;
  final ValueChanged<String> onEntryTypeChanged;
  final ValueChanged<String> onPaymentModeChanged;

  const BillForm({
    super.key,
    required this.billNumber,
    required this.parties,
    required this.vehicles,
    required this.materials,
    this.selectedParty,
    this.selectedVehicle,
    this.selectedMaterial,
    required this.entryType,
    required this.paymentMode,
    required this.firstWeightText,
    required this.secondWeightText,
    required this.rateText,
    required this.netWeightKg,
    required this.amount,
    required this.remarksText,
    required this.onPartyChanged,
    required this.onVehicleChanged,
    required this.onMaterialChanged,
    required this.onFirstWeightChanged,
    required this.onSecondWeightChanged,
    required this.onRateChanged,
    required this.onRemarksChanged,
    required this.onEntryTypeChanged,
    required this.onPaymentModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Bill No | Entry Type | Payment Mode
          Row(
            children: [
              _buildBillNumberBadge(),
              const SizedBox(width: 16),
              Expanded(child: _buildEntryTypeDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildPaymentModeDropdown()),
            ],
          ),
          const SizedBox(height: 20),

          // Row 2: Party Name | Vehicle Number
          Row(
            children: [
              Expanded(child: _buildPartyDropdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildVehicleDropdown()),
            ],
          ),
          const SizedBox(height: 16),

          // Row 3: Material | Remarks
          Row(
            children: [
              Expanded(child: _buildMaterialDropdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildRemarksField()),
            ],
          ),
          const SizedBox(height: 20),

          // Row 4: First Weight | Second Weight (PROMINENT)
          Row(
            children: [
              Expanded(child: _buildProminentWeightField('First Weight (kg) *', firstWeightText, onFirstWeightChanged)),
              const SizedBox(width: 16),
              Expanded(child: _buildProminentWeightField('Second Weight (kg) *', secondWeightText, onSecondWeightChanged)),
            ],
          ),
          const SizedBox(height: 16),

          // Row 5: Net Weight (Auto) | Rate
          Row(
            children: [
              Expanded(child: _buildAutoField('Net Weight (kg)', '${netWeightKg.toStringAsFixed(0)} kg')),
              const SizedBox(width: 16),
              Expanded(child: _buildWeightField('Rate (₹/ton)', rateText, onRateChanged)),
            ],
          ),
          const SizedBox(height: 16),

          // Row 6: Amount (Auto)
          Row(
            children: [
              Expanded(child: _buildAutoField('Amount (₹)', '₹${amount.toStringAsFixed(2)}')),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillNumberBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF0D3B82).withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        billNumber,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D3B82),
        ),
      ),
    );
  }

  Widget _buildPartyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Party Name *',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<Party>(
          initialValue: selectedParty,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Select party',
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
          items: parties.map((p) {
            return DropdownMenuItem(value: p, child: Text(p.name, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13)));
          }).toList(),
          onChanged: (v) {
            if (v != null) onPartyChanged(v);
          },
        ),
      ],
    );
  }

  Widget _buildVehicleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Number *',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<Vehicle>(
          initialValue: selectedVehicle,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Select vehicle',
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
          items: vehicles.map((v) {
            final label = v.vehicleType != null && v.vehicleType!.isNotEmpty
                ? '${v.vehicleNumber} - ${v.vehicleType}'
                : v.vehicleNumber;
            return DropdownMenuItem(value: v, child: Text(label, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13)));
          }).toList(),
          onChanged: (v) {
            if (v != null) onVehicleChanged(v);
          },
        ),
      ],
    );
  }

  Widget _buildMaterialDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material *',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<domain.Material>(
          initialValue: selectedMaterial,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Select material',
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
          items: materials.map((m) {
            return DropdownMenuItem(value: m, child: Text(m.name, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13)));
          }).toList(),
          onChanged: (v) {
            if (v != null) onMaterialChanged(v);
          },
        ),
      ],
    );
  }

  Widget _buildEntryTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entry Type *',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: entryType,
          isExpanded: true,
          decoration: InputDecoration(
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
          items: const [
            DropdownMenuItem(value: 'Inbound', child: Text('Inbound (Purchase)', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DropdownMenuItem(value: 'Outbound', child: Text('Outbound (Sale)', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
          ],
          onChanged: (v) {
            if (v != null) onEntryTypeChanged(v);
          },
        ),
      ],
    );
  }

  Widget _buildPaymentModeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Mode',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: paymentMode,
          isExpanded: true,
          decoration: InputDecoration(
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
          items: const [
            DropdownMenuItem(value: 'Cash', child: Text('Cash', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DropdownMenuItem(value: 'Credit', child: Text('Credit', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DropdownMenuItem(value: 'UPI', child: Text('UPI', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
            DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13))),
          ],
          onChanged: (v) {
            if (v != null) onPaymentModeChanged(v);
          },
        ),
      ],
    );
  }

  Widget _buildProminentWeightField(String label, String value, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: ValueKey('$label-$value'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
          ],
          initialValue: value.isNotEmpty ? value : null,
          onChanged: onChanged,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '0.000',
            hintStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              color: Colors.grey.shade300,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D3B82), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightField(String label, String value, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: ValueKey('$label-$value'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
          ],
          initialValue: value.isNotEmpty ? value : null,
          onChanged: onChanged,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: '0.000',
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
        ),
      ],
    );
  }

  Widget _buildAutoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'Auto',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16A34A),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remarks',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: ValueKey('remarks-$remarksText'),
          initialValue: remarksText.isNotEmpty ? remarksText : null,
          onChanged: onRemarksChanged,
          maxLines: 1,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: 'Optional remarks',
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
        ),
      ],
    );
  }
}
