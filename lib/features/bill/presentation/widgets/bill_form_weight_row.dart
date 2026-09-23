import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BillFormWeightRow extends StatelessWidget {
  const BillFormWeightRow({
    super.key,
    required this.controller,
    required this.weightKg,
    required this.weightUnit,
    required this.enabled,
    required this.isCaptured,
    this.focusNode,
    required this.date,
    required this.time,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.onWeightChanged,
  });

  final TextEditingController controller;
  final double weightKg;
  final String weightUnit;
  final bool enabled;
  final bool isCaptured;
  final FocusNode? focusNode;
  final DateTime date;
  final TimeOfDay time;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<TimeOfDay> onSelectTime;
  final ValueChanged<String> onWeightChanged;

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
        _EditableWeightBox(
          controller: controller,
          displayWeight: displayWeight,
          unitLabel: isKg ? 'Kg' : 'Ton',
          enabled: enabled,
          isCaptured: isCaptured,
          focusNode: focusNode,
          onChanged: onWeightChanged,
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
    final borderColor = isCaptured
        ? const Color(0xFFBBF7D0)
        : const Color(0xFFCBD5E1);
    final bgColor = isCaptured
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFF8FAFC);
    final iconColor = isCaptured
        ? const Color(0xFF16A34A)
        : const Color(0xFF475569);
    final textColor = isCaptured
        ? const Color(0xFF15803D)
        : const Color(0xFF0F172A);

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
                  Icon(icon, size: 14, color: iconColor),
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

class _EditableWeightBox extends StatefulWidget {
  const _EditableWeightBox({
    required this.controller,
    required this.displayWeight,
    required this.unitLabel,
    required this.enabled,
    required this.isCaptured,
    this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String displayWeight;
  final String unitLabel;
  final bool enabled;
  final bool isCaptured;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;

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
    if (_focusNode.hasFocus && widget.enabled && !_editing) {
      setState(() => _editing = true);
      _selectAllText();
    } else if (!_focusNode.hasFocus) {
      _finishEditing();
    }
  }

  void _beginEditing() {
    if (!widget.enabled || _editing) return;
    setState(() => _editing = true);
    _focusNode.requestFocus();
    _selectAllText();
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

  void _finishEditing() {
    if (_editing) setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _editing
        ? const Color(0xFF3B82F6)
        : widget.isCaptured
        ? const Color(0xFF86EFAC)
        : const Color(0xFFCBD5E1);
    final backgroundColor = _editing
        ? const Color(0xFFEFF6FF)
        : widget.isCaptured
        ? const Color(0xFFF0FDF4)
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
              height: 38,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: activeColor,
                  width: _editing ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _editing
                          ? const Color(0xFFDBEAFE)
                          : widget.isCaptured
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFE2E8F0),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(5),
                      ),
                      border: Border(right: BorderSide(color: activeColor)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _editing ? Icons.edit_rounded : Icons.scale_rounded,
                      size: 16.5,
                      color: _editing
                          ? const Color(0xFF2563EB)
                          : widget.isCaptured
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF475569),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _editing
                          ? TextField(
                              controller: widget.controller,
                              focusNode: _focusNode,
                              enabled: widget.enabled,
                              readOnly: !_editing,
                              showCursor: _editing,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,3}$'),
                                ),
                              ],
                              onChanged: widget.onChanged,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            )
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.displayWeight,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: widget.isCaptured
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.isCaptured
                          ? const Color(0xFFDCFCE7).withValues(alpha: 0.6)
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
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: widget.isCaptured
                            ? const Color(0xFF166534)
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
