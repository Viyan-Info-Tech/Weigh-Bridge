import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillFormWeightRow extends StatelessWidget {
  const BillFormWeightRow({
    super.key,
    required this.controller,
    required this.weightKg,
    required this.weightUnit,
    required this.enabled,
    required this.isCaptured,
    required this.date,
    required this.time,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  final TextEditingController controller;
  final double weightKg;
  final String weightUnit;
  final bool enabled;
  final bool isCaptured;
  final DateTime date;
  final TimeOfDay time;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<TimeOfDay> onSelectTime;

  @override
  Widget build(BuildContext context) {
    final isKg = weightUnit.toLowerCase() == 'kg';
    final String displayWeight;
    if (controller.text.isNotEmpty) {
      displayWeight = controller.text;
    } else if (weightKg > 0) {
      displayWeight = isKg
          ? NumberFormat('#,##0').format(weightKg)
          : NumberFormat('#,##0.000').format(weightKg / 1000);
    } else {
      displayWeight = isKg ? '0' : '0.000';
    }

    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final timeStr = '$hour:$minute $period';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Captured weight box with integrated unit badge
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: isCaptured
                ? const Color(0xFFF0FDF4)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isCaptured
                  ? const Color(0xFF86EFAC)
                  : const Color(0xFFCBD5E1),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Scale Icon Prefix
              Container(
                width: 36,
                height: 38,
                decoration: BoxDecoration(
                  color: isCaptured
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFE2E8F0),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(5),
                  ),
                  border: Border(
                    right: BorderSide(
                      color: isCaptured
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFCBD5E1),
                      width: 1.0,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.scale_rounded,
                  size: 16.5,
                  color: isCaptured
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF475569),
                ),
              ),

              // Weight Value
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    displayWeight,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isCaptured
                          ? const Color(0xFF15803D)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),

              // Unit Badge (Kg / Ton)
              Container(
                width: 48,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCaptured
                      ? const Color(0xFFDCFCE7).withValues(alpha: 0.6)
                      : const Color(0xFFF1F5F9),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(5),
                  ),
                  border: Border(
                    left: BorderSide(
                      color: isCaptured
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFCBD5E1),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Text(
                  isKg ? 'Kg' : 'Ton',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isCaptured
                        ? const Color(0xFF166534)
                        : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // 2. Down: Captured Date and Time Pickers
        Row(
          children: [
            // Date Picker Chip
            Expanded(
              flex: 6,
              child: _buildDateTimePickerChip(
                context: context,
                icon: Icons.calendar_month_outlined,
                value: dateStr,
                tooltip: 'Captured Date: $dateStr (Click to change)',
                isCaptured: isCaptured,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) onSelectDate(picked);
                },
              ),
            ),

            const SizedBox(width: 8),

            // Time Picker Chip
            Expanded(
              flex: 5,
              child: _buildDateTimePickerChip(
                context: context,
                icon: Icons.access_time_rounded,
                value: timeStr,
                tooltip: 'Captured Time: $timeStr (Click to change)',
                isCaptured: isCaptured,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (picked != null) onSelectTime(picked);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimePickerChip({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String tooltip,
    required bool isCaptured,
    required VoidCallback onTap,
  }) {
    final borderColor =
        isCaptured ? const Color(0xFFBBF7D0) : const Color(0xFFCBD5E1);
    final bgColor =
        isCaptured ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC);
    final iconColor =
        isCaptured ? const Color(0xFF16A34A) : const Color(0xFF475569);
    final textColor =
        isCaptured ? const Color(0xFF15803D) : const Color(0xFF0F172A);

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: isCaptured
              ? const Color(0xFFDCFCE7).withValues(alpha: 0.5)
              : const Color(0xFFEFF6FF),
          child: Ink(
            height: 30,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: iconColor,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
