import 'package:flutter/material.dart';

class BillFormChargesStepper extends StatelessWidget {
  const BillFormChargesStepper({
    super.key,
    required this.onChanged,
    required this.onIncrement,
    required this.onDecrement,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: onIncrement,
              child: const Center(
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 16,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ),
          Container(height: 1, color: const Color(0xFFE2E8F0)),
          Expanded(
            child: InkWell(
              onTap: onDecrement,
              child: const Center(
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
