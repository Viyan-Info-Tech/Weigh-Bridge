import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Accent palette for a weight display row.
///
/// Gross renders green, tare red and net blue so the three dedicated
/// displays on the weighment screen are instantly distinguishable while
/// keeping the same box + date/time-chip structure.
class WeightRowAccent {
  const WeightRowAccent({
    this.border = const Color(0xFFCBD5E1),
    this.background = const Color(0xFFF8FAFC),
    this.iconBackground = const Color(0xFFE2E8F0),
    this.iconColor = const Color(0xFF64748B),
    required this.textColor,
    this.unitBackground = const Color(0xFFF1F5F9),
    this.unitColor = const Color(0xFF334155),
  });

  final Color border;
  final Color background;
  final Color iconBackground;
  final Color iconColor;
  final Color textColor;
  final Color unitBackground;
  final Color unitColor;

  static const WeightRowAccent green = WeightRowAccent(
    textColor: Color(0xFF16A34A),
  );

  static const WeightRowAccent red = WeightRowAccent(
    textColor: Color(0xFFDC2626),
  );

  static const WeightRowAccent blue = WeightRowAccent(
    textColor: Color(0xFF0284C7),
  );
}

class BillFormWeightRow extends StatelessWidget {
  const BillFormWeightRow({
    super.key,
    required this.controller,
    required this.weightKg,
    required this.weightUnit,
    required this.enabled,
    required this.isCaptured,
    this.hasError = false,
    this.focusNode,
    required this.date,
    required this.time,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.onWeightChanged,
    this.onWeightCommitted,
    this.onSubmittedNext,
    this.accent = WeightRowAccent.green,
  });

  final TextEditingController controller;
  final double weightKg;
  final String weightUnit;
  final bool enabled;
  final bool isCaptured;
  final bool hasError;
  final FocusNode? focusNode;
  final DateTime? date;
  final TimeOfDay? time;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<TimeOfDay> onSelectTime;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String>? onWeightCommitted;
  final VoidCallback? onSubmittedNext;
  final WeightRowAccent accent;

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

    final dateStr = date != null
        ? DateFormat('dd/MM/yyyy').format(date!)
        : '--/--/----';
    final timeStr = time != null
        ? _formatTime(time!)
        : (date != null ? DateFormat('hh:mm a').format(date!) : '--:-- --');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Captured weight box with integrated unit badge
        _EditableWeightBox(
          controller: controller,
          displayWeight: displayWeight,
          unitLabel: isKg ? 'Kg' : 'Ton',
          enabled: enabled,
          isCaptured: isCaptured,
          hasError: hasError,
          focusNode: focusNode,
          onChanged: onWeightChanged,
          onCommitted: onWeightCommitted,
          onSubmittedNext: onSubmittedNext,
          accent: accent,
        ),

        const SizedBox(height: 7),

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
                tooltip: date != null
                    ? 'Captured Date: $dateStr (Click to change)'
                    : 'Not captured yet (Click to set)',
                isCaptured: isCaptured,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date ?? DateTime.now(),
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
                tooltip: time != null
                    ? 'Captured Time: $timeStr (Click to change)'
                    : 'Not captured yet (Click to set)',
                isCaptured: isCaptured,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: time ?? TimeOfDay.now(),
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

  static String _formatTime(TimeOfDay value) {
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildDateTimePickerChip({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String tooltip,
    required bool isCaptured,
    required VoidCallback onTap,
  }) {
    const borderColor = Color(0xFFCBD5E1);
    const bgColor = Color(0xFFF8FAFC);
    const iconColor = Color(0xFF475569);
    const textColor = Color(0xFF0F172A);

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: const Color(0xFFEFF6FF),
          child: Ink(
            height: 34,
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
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
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

class _EditableWeightBox extends StatelessWidget {
  const _EditableWeightBox({
    required this.controller,
    required this.displayWeight,
    required this.unitLabel,
    required this.enabled,
    required this.isCaptured,
    this.hasError = false,
    this.focusNode,
    required this.onChanged,
    this.onCommitted,
    this.onSubmittedNext,
    this.accent = WeightRowAccent.green,
  });

  final TextEditingController controller;
  final String displayWeight;
  final String unitLabel;
  final bool enabled;
  final bool isCaptured;
  final bool hasError;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCommitted;
  final VoidCallback? onSubmittedNext;
  final WeightRowAccent accent;

  FocusNode? get _focusNode => focusNode;

  @override
  Widget build(BuildContext context) {
    final widget = this;
    final activeColor = hasError
        ? const Color(0xFFDC2626)
        : const Color(0xFFCBD5E1);
    final backgroundColor = hasError
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFF8FAFC);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: activeColor,
                width: widget.hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 46,
                  decoration: BoxDecoration(
                    color: widget.hasError
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFE2E8F0),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(5),
                    ),
                    border: Border(right: BorderSide(color: activeColor)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.scale_rounded,
                    size: 20,
                    color: widget.hasError
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF64748B),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      enabled: true,
                      readOnly: true,
                      showCursor: false,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: widget.displayWeight,
                        hintStyle: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              (widget.isCaptured ||
                                  (widget.displayWeight != '0' &&
                                      widget.displayWeight != '0.000'))
                              ? widget.accent.textColor
                              : const Color(0xFF0F172A),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.accent.textColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 54,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(5),
                    ),
                    border: Border(left: BorderSide(color: activeColor)),
                  ),
                  child: Text(
                    widget.unitLabel,
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
          ),
        ),
      ),
    );
  }
}
