import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/report_summary.dart';

class ReportSummaryBar extends StatelessWidget {
  const ReportSummaryBar({
    super.key,
    required this.summary,
    required this.weightUnit,
  });

  final ReportSummary summary;
  final String weightUnit;

  @override
  Widget build(BuildContext context) {
    final isTon = weightUnit.toLowerCase() == 'ton';
    String formatWeight(double kg) =>
        '${NumberFormat(isTon ? '#,##0.000' : '#,##0').format(isTon ? kg / 1000 : kg)} ${isTon ? 'ton' : 'kg'}';
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Total Weighments',
                value: '${summary.totalBills}',
                subtitle: 'Total weighments',
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xFF0284C7),
                bgColor: const Color(0xFFF0F9FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Gross',
                value: formatWeight(summary.totalGrossWeightKg),
                subtitle: 'Gross weight total',
                icon: Icons.scale_outlined,
                iconColor: const Color(0xFF475569),
                bgColor: const Color(0xFFF1F5F9),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Net Weight',
                value: formatWeight(summary.totalNetWeightKg),
                subtitle: 'Net weight total',
                icon: Icons.line_weight_rounded,
                iconColor: const Color(0xFF16A34A),
                bgColor: const Color(0xFFDCFCE7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Total Charges',
                value: summary.totalChargesText,
                subtitle: 'Charges total',
                icon: Icons.currency_rupee_outlined,
                iconColor: const Color(0xFFB45309),
                bgColor: const Color(0xFFFFFBEB),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
