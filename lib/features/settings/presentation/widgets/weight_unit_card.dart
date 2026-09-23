import 'package:flutter/material.dart';

import 'settings_form_field.dart';

class WeightUnitCard extends StatelessWidget {
  const WeightUnitCard({
    super.key,
    required this.weightUnit,
    required this.isEditing,
    required this.onWeightUnitChanged,
  });

  final String weightUnit;
  final bool isEditing;
  final ValueChanged<String> onWeightUnitChanged;

  @override
  Widget build(BuildContext context) {
    return CardWrapper(
      icon: Icons.scale_rounded,
      iconBg: const Color(0xFFEFF6FF),
      iconColor: const Color(0xFF2563EB),
      title: 'Weight Unit',
      subtitle:
          'Select the primary unit for scale measurements across the application',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackTiles = constraints.maxWidth < 420;
          final kgTile = _buildUnitRadioTile(
            title: 'Kilogram (kg)',
            subtitle: 'Display and print weights in kilograms',
            value: 'kg',
          );
          final tonTile = _buildUnitRadioTile(
            title: 'Tonne (ton)',
            subtitle: 'Display and print weights in tonnes',
            value: 'ton',
          );

          if (stackTiles) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [kgTile, const SizedBox(height: 12), tonTile],
            );
          }

          return Row(
            children: [
              Expanded(child: kgTile),
              const SizedBox(width: 12),
              Expanded(child: tonTile),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUnitRadioTile({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = weightUnit == value;
    return InkWell(
      onTap: isEditing ? () => onWeightUnitChanged(value) : null,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D3B82).withValues(alpha: 0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D3B82)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0D3B82)
                      : const Color(0xFF94A3B8),
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
