import 'package:flutter/material.dart';

class FieldVisibilitySection extends StatelessWidget {
  const FieldVisibilitySection({
    super.key,
    required this.showSerialNumber,
    required this.showVehicleNumber,
    required this.showGrossWeight,
    required this.showTareWeight,
    required this.showNetWeight,
    required this.showRemarks,
    required this.showFooterNote,
    required this.isEditing,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onToggle,
  });

  final bool showSerialNumber;
  final bool showVehicleNumber;
  final bool showGrossWeight;
  final bool showTareWeight;
  final bool showNetWeight;
  final bool showRemarks;
  final bool showFooterNote;
  final bool isEditing;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final Function(String field, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'FIELD VISIBILITY TOGGLES',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildToggleChip(
                'Serial Number',
                showSerialNumber,
                (v) => onToggle('serialNumber', v),
              ),
              _buildToggleChip(
                'Vehicle Number',
                showVehicleNumber,
                (v) => onToggle('vehicleNumber', v),
              ),
              _buildToggleChip(
                'Gross Weight',
                showGrossWeight,
                (v) => onToggle('grossWeight', v),
              ),
              _buildToggleChip(
                'Tare Weight',
                showTareWeight,
                (v) => onToggle('tareWeight', v),
              ),
              _buildToggleChip(
                'Net Weight',
                showNetWeight,
                (v) => onToggle('netWeight', v),
              ),
              _buildToggleChip(
                'Remarks',
                showRemarks,
                (v) => onToggle('remarks', v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleChip(
    String label,
    bool isSelected,
    ValueChanged<bool> onChanged,
  ) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? const Color(0xFF0D3B82) : const Color(0xFF475569),
      ),
      selectedColor: const Color(0xFF0D3B82).withValues(alpha: 0.12),
      checkmarkColor: const Color(0xFF0D3B82),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF0D3B82) : const Color(0xFFCBD5E1),
        width: isSelected ? 1.5 : 1.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      onSelected: isEditing ? onChanged : null,
    );
  }
}
