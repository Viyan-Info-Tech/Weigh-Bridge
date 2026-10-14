import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../bill/domain/entities/weighment.dart';
import '../../../bill/presentation/widgets/weighment_slip_dialog.dart';
import '../../domain/entities/weighment_report_item.dart';

class WeighmentDetailsDialog extends StatelessWidget {
  final WeighmentReportItem record;
  final String? weightUnit;

  const WeighmentDetailsDialog({
    super.key,
    required this.record,
    this.weightUnit,
  });

  static Future<void> show({
    required BuildContext context,
    required WeighmentReportItem record,
    String? weightUnit,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) =>
          WeighmentDetailsDialog(record: record, weightUnit: weightUnit),
    );
  }

  void _onPrintTicket(BuildContext context) {
    Navigator.of(context).pop();

    // Map to Weighment domain entity for WeighmentSlipDialog
    final billEntity = Weighment(
      id: record.id,
      billNumber: record.billNumber,
      vehicleNumber: record.vehicleNumber,
      grossWeightKg: record.grossWeightKg ?? record.firstWeightKg,
      tareWeightKg: record.tareWeightKg,
      netWeightKg: record.netWeightKg,
      weightUnit: weightUnit ?? record.weightUnit,
      remarks: record.remarks,
      firstWeightType: record.firstWeightType,
      secondWeightType: record.secondWeightType,
      createdAt: record.createdAt,
      updatedAt: record.createdAt,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => WeighmentSlipDialog(bill: billEntity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = record.isCompleted;
    final statusColor = isCompleted
        ? const Color(0xFF16A34A)
        : const Color(0xFFD97706);
    final statusBg = isCompleted
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEF3C7);
    final dateFormatted = DateFormat(
      'dd/MM/yyyy hh:mm a',
    ).format(record.createdAt);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 10,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weighment Details',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF64748B),
                  ),
                  splashRadius: 18,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bill number and Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.billNumber,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateFormatted,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      record.isCompleted ? 'COMPLETED' : 'INCOMPLETE',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Info
            _buildInfoGrid([_InfoRow('Vehicle', record.vehicleNumber)]),
            const SizedBox(height: 16),

            // Weights Section
            Builder(
              builder: (context) {
                final unit = weightUnit ?? record.weightUnit;
                final isTon =
                    unit.toLowerCase() == 'ton' ||
                    unit.toLowerCase() == 'tonne';
                final decimals = isTon ? 3 : 0;
                double? toDisplay(double? kg) {
                  if (kg == null) return null;
                  return isTon ? kg / 1000 : kg;
                }

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildWeightRow(
                        label: 'First Weight',
                        weight:
                            '${(toDisplay(record.firstWeightKg) ?? 0).toStringAsFixed(decimals)} $unit',
                        badge: record.firstWeightType,
                        badgeColor: Colors.blueGrey,
                      ),
                      const Divider(height: 14, color: Color(0xFFE2E8F0)),
                      _buildWeightRow(
                        label: 'Second Weight',
                        weight:
                            (record.secondWeightKg != null &&
                                record.secondWeightKg! > 0)
                            ? '${toDisplay(record.secondWeightKg!)!.toStringAsFixed(decimals)} $unit'
                            : '—',
                        badge:
                            (record.secondWeightKg != null &&
                                record.secondWeightKg! > 0)
                            ? (record.secondWeightType ?? '')
                            : '',
                        badgeColor: Colors.blueGrey,
                      ),
                      const Divider(height: 14, color: Color(0xFFE2E8F0)),
                      _buildSummaryWeightRow(
                        'Gross Weight',
                        record.grossWeightKg != null
                            ? '${toDisplay(record.grossWeightKg!)!.toStringAsFixed(decimals)} $unit'
                            : '—',
                      ),
                      const SizedBox(height: 4),
                      _buildSummaryWeightRow(
                        'Tare Weight',
                        record.tareWeightKg != null
                            ? '${toDisplay(record.tareWeightKg!)!.toStringAsFixed(decimals)} $unit'
                            : '—',
                      ),
                      const SizedBox(height: 4),
                      _buildSummaryWeightRow(
                        'Net Weight',
                        record.netWeightKg != null
                            ? '${toDisplay(record.netWeightKg!)!.toStringAsFixed(decimals)} $unit'
                            : '—',
                        isHighlight: true,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            if (record.remarks != null &&
                record.remarks!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Remarks: ${record.remarks!}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Actions: [Print Ticket] and [Close]
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF243B64),
                    side: const BorderSide(
                      color: Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Close',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _onPrintTicket(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF174A9C),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.print, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Print Ticket',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(List<_InfoRow> rows) {
    return Column(
      children: rows
          .map(
            (r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      r.label,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const Text(': ', style: TextStyle(color: Color(0xFF94A3B8))),
                  Expanded(
                    child: Text(
                      r.value,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildWeightRow({
    required String label,
    required String weight,
    required String badge,
    required Color badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        Row(
          children: [
            Text(
              weight,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            if (badge.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryWeightRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: isHighlight ? 13 : 12,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            color: isHighlight
                ? const Color(0xFF0F172A)
                : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: isHighlight ? 14 : 13,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
            color: isHighlight
                ? const Color(0xFF0284C7)
                : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  _InfoRow(this.label, this.value);
}
