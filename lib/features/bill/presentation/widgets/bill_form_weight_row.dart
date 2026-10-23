import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Accent palette for a weight display row.
///
/// Gross renders green, tare red and net blue so the three dedicated
/// displays on the weighment screen are instantly distinguishable while
/// keeping the same box + date/time-chip structure.
class WeightRowAccent {
  const WeightRowAccent({
    required this.border,
    required this.background,
    required this.iconBackground,
    required this.iconColor,
    required this.textColor,
    required this.unitBackground,
    required this.unitColor,
  });

  final Color border;
  final Color background;
  final Color iconBackground;
  final Color iconColor;
  final Color textColor;
  final Color unitBackground;
  final Color unitColor;

  static const WeightRowAccent green = WeightRowAccent(
    border: Color(0xFF86EFAC),
    background: Color(0xFFF0FDF4),
    iconBackground: Color(0xFFDCFCE7),
    iconColor: Color(0xFF16A34A),
    textColor: Color(0xFF15803D),
    unitBackground: Color(0xFFDCFCE7),
    unitColor: Color(0xFF166534),
  );

  static const WeightRowAccent red = WeightRowAccent(
    border: Color(0xFFFCA5A5),
    background: Color(0xFFFEF2F2),
    iconBackground: Color(0xFFFEE2E2),
    iconColor: Color(0xFFDC2626),
    textColor: Color(0xFFB91C1C),
    unitBackground: Color(0xFFFEE2E2),
    unitColor: Color(0xFF991B1B),
  );

  static const WeightRowAccent blue = WeightRowAccent(
    border: Color(0xFF93C5FD),
    background: Color(0xFFEFF6FF),
    iconBackground: Color(0xFFDBEAFE),
    iconColor: Color(0xFF0284C7),
    textColor: Color(0xFF0C4A6E),
    unitBackground: Color(0xFFDBEAFE),
    unitColor: Color(0xFF0C4A6E),
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
    final timeStr = date != null
        ? DateFormat('HH:mm:ss').format(date!)
        : (time != null ? _formatTime(time!) : '--:--:--');

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
                    // Railway-style clock: the picker dialog itself never
                    // shows AM/PM, matching the 24-hour chips around it.
                    builder: (context, child) => MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    ),
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
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildDateTimePickerChip({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String tooltip,
    required bool isCaptured,
    required VoidCallback onTap,
  }) {
    final borderColor = isCaptured ? accent.border : const Color(0xFFCBD5E1);
    final bgColor = isCaptured ? accent.background : const Color(0xFFF8FAFC);
    final iconColor = isCaptured ? accent.iconColor : const Color(0xFF475569);
    final textColor = isCaptured ? accent.textColor : const Color(0xFF0F172A);

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: isCaptured
              ? accent.iconBackground.withValues(alpha: 0.5)
              : const Color(0xFFEFF6FF),
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
                      style: TextStyle(
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

class _EditableWeightBox extends StatefulWidget {
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

  @override
  State<_EditableWeightBox> createState() => _EditableWeightBoxState();
}

class _EditableWeightBoxState extends State<_EditableWeightBox> {
  final _internalFocusNode = FocusNode(debugLabel: 'manualWeightFocusNode');
  bool _editing = false;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _EditableWeightBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldFocusNode = oldWidget.focusNode ?? _internalFocusNode;
    final newFocusNode = widget.focusNode ?? _internalFocusNode;
    if (oldFocusNode != newFocusNode) {
      oldFocusNode.removeListener(_handleFocusChange);
      newFocusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && widget.enabled) {
      if (!_editing) {
        if (widget.controller.text.isEmpty &&
            widget.displayWeight != '0' &&
            widget.displayWeight != '0.000') {
          // Write text and select-all selection in ONE assignment: the plain
          // `.text=` setter would leave the selection invalid (offset -1) in
          // the just-focused field, which is the state that crashes vertical
          // caret movement (Down/Up arrow) inside EditableText.
          final text = widget.displayWeight.replaceAll(',', '');
          widget.controller.value = TextEditingValue(
            text: text,
            selection: TextSelection(baseOffset: 0, extentOffset: text.length),
          );
        }
        setState(() => _editing = true);
        _selectAllText();
      }
    } else if (!_focusNode.hasFocus) {
      if (_editing) {
        _commitAndFinishEditing();
      }
    }
  }

  void _beginEditing() {
    if (!widget.enabled) return;
    _focusNode.requestFocus();
  }

  void _selectAllText() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.controller.text.length,
        );
      }
    });
  }

  void _commitAndFinishEditing() {
    if (_editing) setState(() => _editing = false);
    widget.onCommitted?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.hasError
        ? const Color(0xFFDC2626)
        : _editing
        ? const Color(0xFF3B82F6)
        : widget.isCaptured
        ? widget.accent.border
        : const Color(0xFFCBD5E1);
    final backgroundColor = widget.hasError
        ? const Color(0xFFFEF2F2)
        : _editing
        ? const Color(0xFFEFF6FF)
        : widget.isCaptured
        ? widget.accent.background
        : const Color(0xFFF8FAFC);

    return Tooltip(
      message: widget.enabled
          ? 'Click to edit weight manually'
          : 'This weight is locked while editing this ticket',
      child: MouseRegion(
        cursor: widget.enabled ? SystemMouseCursors.text : MouseCursor.defer,
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: _editing ? null : _beginEditing,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: activeColor,
                  width: (widget.hasError || _editing) ? 1.5 : 1,
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
                          : _editing
                          ? const Color(0xFFDBEAFE)
                          : widget.isCaptured
                          ? widget.accent.iconBackground
                          : const Color(0xFFE2E8F0),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(5),
                      ),
                      border: Border(right: BorderSide(color: activeColor)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _editing ? Icons.edit_rounded : Icons.scale_rounded,
                      size: 20,
                      color: widget.hasError
                          ? const Color(0xFFDC2626)
                          : _editing
                          ? const Color(0xFF2563EB)
                          : widget.isCaptured
                          ? widget.accent.iconColor
                          : const Color(0xFF64748B),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        readOnly: !_editing,
                        showCursor: _editing,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,3}$'),
                          ),
                        ],
                        textInputAction: TextInputAction.next,
                        onChanged: widget.onChanged,
                        onSubmitted: (value) {
                          _commitAndFinishEditing();
                          widget.onSubmittedNext?.call();
                        },
                        decoration: InputDecoration(
                          hintText: widget.displayWeight,
                          hintStyle: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: widget.isCaptured
                                ? widget.accent.textColor
                                : const Color(0xFF0F172A),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: widget.isCaptured
                              ? widget.accent.textColor
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.isCaptured
                          ? widget.accent.unitBackground.withValues(alpha: 0.6)
                          : const Color(0xFFF1F5F9),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(5),
                      ),
                      border: Border(left: BorderSide(color: activeColor)),
                    ),
                    child: Text(
                      widget.unitLabel,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: widget.isCaptured
                            ? widget.accent.unitColor
                            : const Color(0xFF334155),
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
