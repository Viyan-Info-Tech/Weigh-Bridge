import 'package:flutter/material.dart';

import 'bill_form_field_shell.dart';

/// Read-only displays for the weighment form.
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

/// 2. NET WEIGHT Display (dedicated blue numeric display).
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
        color: const Color(0xFFF8FAFC),
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
              color: Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                netDisplay,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: hasCompleteWeight && netWeightKg > 0
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          Container(
            width: 54,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
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
