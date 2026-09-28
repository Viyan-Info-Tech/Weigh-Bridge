import 'package:flutter/material.dart';

class BillFormTypeSelector extends StatelessWidget {
  const BillFormTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final String selectedType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isGross = selectedType.toLowerCase() == 'gross';

    return Row(
      children: [
        Expanded(
          child: _TypeOption(
            label: 'GROSS',
            isSelected: isGross,
            onTap: () => onChanged('Gross'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TypeOption(
            label: 'TARE',
            isSelected: !isGross,
            onTap: () => onChanged('Tare'),
          ),
        ),
      ],
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 46,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEFF6FF)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFCBD5E1),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0D53FC)
                        : const Color(0xFF94A3B8),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8.5,
                          height: 8.5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0D53FC),
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14.5,
                  fontWeight: isSelected
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF0D53FC)
                      : const Color(0xFF334155),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
