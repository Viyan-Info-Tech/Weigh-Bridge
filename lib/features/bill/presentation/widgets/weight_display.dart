import 'package:flutter/material.dart';

class WeightDisplay extends StatelessWidget {
  final double netWeightTon;
  final double firstWeight;
  final double secondWeight;
  final VoidCallback? onZeroScale;
  final VoidCallback? onTareScale;

  const WeightDisplay({
    super.key,
    required this.netWeightTon,
    required this.firstWeight,
    required this.secondWeight,
    this.onZeroScale,
    this.onTareScale,
  });

  @override
  Widget build(BuildContext context) {
    final netKg = netWeightTon * 1000;
    final isPositive = netKg >= 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark terminal style
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Status Bar: Indicator Name & Status Lights
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'LIVE SCALE 01',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildStatusPill('STABLE', const Color(0xFF22C55E)),
              const SizedBox(width: 8),
              _buildStatusPill('ZERO', const Color(0xFF38BDF8)),
              const SizedBox(width: 8),
              _buildStatusPill('NET WT', const Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 14),

          // Main Digital Weight Readout
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${isPositive ? '' : '-'}${netKg.abs().toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF38BDF8), // Glowing cyan
                  letterSpacing: 2,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'KG',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${netWeightTon.toStringAsFixed(3)} TON',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFF1E293B)),
          const SizedBox(height: 12),

          // 3 Metric Breakdown Chips: First Wt, Second Wt, Net Wt
          Row(
            children: [
              Expanded(
                child: _buildWeightSubBlock(
                  '1ST WEIGHT',
                  firstWeight,
                  const Color(0xFF94A3B8),
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFF1E293B)),
              Expanded(
                child: _buildWeightSubBlock(
                  '2ND WEIGHT',
                  secondWeight,
                  const Color(0xFF94A3B8),
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFF1E293B)),
              Expanded(
                child: _buildWeightSubBlock(
                  'NET WEIGHT',
                  netKg,
                  const Color(0xFF38BDF8),
                  isHighlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildWeightSubBlock(String label, double value, Color valueColor,
      {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${value.toStringAsFixed(0)} kg',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
