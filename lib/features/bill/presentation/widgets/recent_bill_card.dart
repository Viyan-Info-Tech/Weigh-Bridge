import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/weighment.dart';

/// A single weighment ticket rendered as a card inside the recent bills
/// panel.
///
/// The card is presentation only: the two actions are surfaced
/// through callbacks instead of dialogs.
class RecentBillCard extends StatelessWidget {
  const RecentBillCard({
    super.key,
    required this.bill,
    required this.weightUnit,
    required this.isCompact,
    this.onSelected,
    this.onPrintSlip,
  });

  final Weighment bill;
  final String weightUnit;
  final bool isCompact;
  final VoidCallback? onSelected;
  final VoidCallback? onPrintSlip;

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final vehicleNo = bill.vehicleNumber;
    final timeStr = DateFormat('hh:mm a').format(bill.createdAt);
    final dateStr = DateFormat('dd MMM').format(bill.createdAt);
    final timestampLabel = _isSameDay(bill.createdAt, DateTime.now())
        ? timeStr
        : '$dateStr, $timeStr';

    // --- Status badge ---
    const statusBadgeText = 'COMPLETED';
    const statusBadgeBg = Color(0xFFDCFCE7);
    const statusBadgeColor = Color(0xFF16A34A);

    final String grossDisplay;
    final String tareDisplay;
    final String netDisplay;

    final unit = weightUnit;
    final isTon = unit.toLowerCase() == 'ton' || unit.toLowerCase() == 'tonne';
    final decimals = isTon ? 3 : 0;
    double? toDisplay(double? kg) {
      if (kg == null) return null;
      return isTon ? kg / 1000 : kg;
    }

    grossDisplay = bill.grossWeightKg != null
        ? '${toDisplay(bill.grossWeightKg)!.toStringAsFixed(decimals)} $unit'
        : '—';
    tareDisplay = bill.tareWeightKg != null
        ? '${toDisplay(bill.tareWeightKg)!.toStringAsFixed(decimals)} $unit'
        : '—';
    netDisplay = bill.netWeightKg != null
        ? '${toDisplay(bill.netWeightKg)!.toStringAsFixed(decimals)} $unit'
        : '—';

    final cardContent = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(isCompact ? 10 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact cards wrap ticket metadata onto two short rows.
          if (isCompact) ...[
            Wrap(
              spacing: 6,
              runSpacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildTicketBadge(bill.billNumber),
                _buildStatusBadge(
                  statusBadgeText,
                  statusBadgeBg,
                  statusBadgeColor,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                timestampLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else
            // Row 1: Bill Number, Status Badge & Timestamp
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    bill.billNumber,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D3B82),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusBadgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusBadgeText,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusBadgeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    timestampLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),

          // Row 2: Vehicle Plate
          Row(
            children: [
              // Styled Vehicle Plate
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 14,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vehicleNo,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: Weight Values Breakdown Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildWeightCell('Gross Wt', grossDisplay),
                _buildVerticalLine(),
                _buildWeightCell('Tare Wt', tareDisplay),
                _buildVerticalLine(),
                _buildWeightCell(
                  'Net Weight',
                  netDisplay,
                  isBold: true,
                  textColor: const Color(0xFF0D3B82),
                ),
                if (bill.charges != null) ...[
                  _buildVerticalLine(),
                  _buildWeightCell(
                    'Charges',
                    formatCharges(bill.charges),
                    isBold: true,
                    textColor: const Color(0xFF0F172A),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Row 4: Slip print action
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                key: Key('print_slip_button_${bill.billNumber}'),
                icon: const Icon(Icons.print_outlined, size: 18),
                color: const Color(0xFF0D3B82),
                tooltip: 'View & Print Slip',
                visualDensity: VisualDensity.compact,
                onPressed: () => onPrintSlip?.call(),
              ),
            ],
          ),
        ],
      ),
    );

    if (onSelected != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onSelected,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  Widget _buildWeightCell(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: textColor ?? const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLine() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildTicketBadge(String billNumber) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      billNumber,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0D3B82),
      ),
    ),
  );

  Widget _buildStatusBadge(String text, Color background, Color foreground) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
      );
}
