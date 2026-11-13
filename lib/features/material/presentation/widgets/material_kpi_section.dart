import 'package:flutter/material.dart';

import '../../domain/entities/material_item.dart';

/// KPI summary cards for the materials screen.
class MaterialKpiSection extends StatelessWidget {
  const MaterialKpiSection({super.key, required this.materials});

  final List<MaterialItem> materials;

  @override
  Widget build(BuildContext context) {
    final total = materials.length;
    final active = materials.where((m) => m.isActive).length;
    final loadCount = materials
        .where((m) => m.vehicleType.toLowerCase() == 'load')
        .length;
    final emptyCount = materials
        .where((m) => m.vehicleType.toLowerCase() == 'empty')
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = ((constraints.maxWidth - 36) / 4).clamp(160.0, 320.0);
        return Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'TOTAL MATERIALS',
                count: total,
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFF0F9FF),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'ACTIVE STATUS',
                count: active,
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'LOAD TYPE',
                count: loadCount,
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildMetricCard(
                title: 'EMPTY TYPE',
                count: emptyCount,
                icon: Icons.rv_hookup_outlined,
                color: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
