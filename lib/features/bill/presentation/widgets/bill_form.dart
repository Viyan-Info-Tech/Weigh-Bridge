import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/text_formatters.dart';
import 'bill_form_field_shell.dart';
import 'bill_form_readonly_fields.dart';
import 'bill_form_row.dart';
import 'bill_form_type_selector.dart';
import 'bill_form_weight_row.dart';

/// Industrial 2-Column Weighment Ticket Form
/// Designed with premium tactile instrument aesthetics:
/// - Framed icon prefix badges with soft slate background
/// - Clean proportional Weight, Date & Time pickers
/// - Balanced 2-column layout with subtle dividing rhythm
class BillForm extends StatefulWidget {
  final String billNumber;
  final String materialText;
  final String descriptionText;
  final String vehicleNumber;
  final TextEditingController grossWeightController;
  final TextEditingController tareWeightController;
  final TextEditingController remarksController;
  final TextEditingController materialController;
  final TextEditingController descriptionController;
  final TextEditingController? vehicleNumberController;
  final double grossWeightKg;
  final double tareWeightKg;
  final double netWeightKg;
  final String weightUnit;
  final String? weightValidationError;
  final bool isReady;
  final DateTime? grossCapturedAt;
  final DateTime? tareCapturedAt;
  final String selectedType;
  final ValueChanged<String>? onTypeChanged;

  final FocusNode? vehicleFocusNode;
  final FocusNode? typeFocusNode;
  final FocusNode? materialFocusNode;
  final FocusNode? descriptionFocusNode;
  final FocusNode? remarksFocusNode;
  final FocusNode? grossWeightFocusNode;
  final FocusNode? tareWeightFocusNode;

  final ValueChanged<String> onVehicleNumberChanged;
  final ValueChanged<String> onMaterialChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onGrossWeightChanged;
  final ValueChanged<String> onTareWeightChanged;
  final ValueChanged<String>? onGrossWeightCommitted;
  final ValueChanged<String>? onTareWeightCommitted;
  final ValueChanged<DateTime?>? onGrossCapturedAtChanged;
  final ValueChanged<DateTime?>? onTareCapturedAtChanged;
  final ValueChanged<String> onRemarksChanged;
  final ValueChanged<String>? onWeightUnitChanged;

  final String? vehicleNumberError;
  final String? weightError;

  const BillForm({
    super.key,
    required this.billNumber,
    this.materialText = '',
    this.descriptionText = '',
    this.vehicleNumber = '',
    required this.grossWeightController,
    required this.tareWeightController,
    required this.remarksController,
    required this.materialController,
    required this.descriptionController,
    this.vehicleNumberController,
    this.grossWeightKg = 0,
    this.tareWeightKg = 0,
    required this.netWeightKg,
    this.weightUnit = 'kg',
    this.weightValidationError,
    this.isReady = true,
    this.grossCapturedAt,
    this.tareCapturedAt,
    this.selectedType = 'Gross',
    this.onTypeChanged,
    this.vehicleFocusNode,
    this.typeFocusNode,
    this.materialFocusNode,
    this.descriptionFocusNode,
    this.remarksFocusNode,
    this.grossWeightFocusNode,
    this.tareWeightFocusNode,
    required this.onVehicleNumberChanged,
    required this.onMaterialChanged,
    required this.onDescriptionChanged,
    required this.onGrossWeightChanged,
    required this.onTareWeightChanged,
    this.onGrossWeightCommitted,
    this.onTareWeightCommitted,
    this.onGrossCapturedAtChanged,
    this.onTareCapturedAtChanged,
    required this.onRemarksChanged,
    this.onWeightUnitChanged,
    this.vehicleNumberError,
    this.weightError,
  });

  @override
  State<BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  final ScrollController _scrollController = ScrollController();

  String? _selectedType;
  DateTime? _grossDate;
  TimeOfDay? _grossTime;
  DateTime? _tareDate;
  TimeOfDay? _tareTime;

  /// Moves focus to the next field in the current keyboard order.
  void _focusAfterTypeStep() {
    widget.materialFocusNode?.requestFocus();
  }

  Widget _buildFieldError(String? error) {
    if (error == null || error.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    if (widget.grossCapturedAt != null) {
      _grossDate = widget.grossCapturedAt!;
      _grossTime = TimeOfDay.fromDateTime(widget.grossCapturedAt!);
    }
    if (widget.tareCapturedAt != null) {
      _tareDate = widget.tareCapturedAt!;
      _tareTime = TimeOfDay.fromDateTime(widget.tareCapturedAt!);
    }
  }

  @override
  void didUpdateWidget(covariant BillForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedType != oldWidget.selectedType) {
      _selectedType = widget.selectedType;
    }

    if (widget.grossCapturedAt != oldWidget.grossCapturedAt) {
      if (widget.grossCapturedAt != null) {
        _grossDate = widget.grossCapturedAt!;
        _grossTime = TimeOfDay.fromDateTime(widget.grossCapturedAt!);
      } else {
        _grossDate = null;
        _grossTime = null;
      }
    }
    if (widget.tareCapturedAt != oldWidget.tareCapturedAt) {
      if (widget.tareCapturedAt != null) {
        _tareDate = widget.tareCapturedAt!;
        _tareTime = TimeOfDay.fromDateTime(widget.tareCapturedAt!);
      } else {
        _tareDate = null;
        _tareTime = null;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Both weights stay editable: this form always represents a new bill, so
    // there is no previously captured weight that must be locked.
    const isGrossEnabled = true;
    const isTareEnabled = true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isSingleColumn = width < 760;
          final fieldGap = constraints.maxHeight < 600 ? 7.0 : 11.0;
          final labelWidth = isSingleColumn
              ? 120.0
              : (width < 950 ? 124.0 : 148.0);

          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: width >= 900,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: isSingleColumn
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLeftColumn(
                          isGrossEnabled,
                          isTareEnabled,
                          labelWidth: labelWidth,
                          fieldGap: fieldGap,
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 16),
                        _buildRightColumn(
                          isGrossEnabled,
                          isTareEnabled,
                          labelWidth: labelWidth,
                          fieldGap: fieldGap,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 20),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Color(0xFFF1F5F9),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: _buildLeftColumn(
                              isGrossEnabled,
                              isTareEnabled,
                              labelWidth: labelWidth,
                              fieldGap: fieldGap,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildRightColumn(
                            isGrossEnabled,
                            isTareEnabled,
                            labelWidth: labelWidth,
                            fieldGap: fieldGap,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  /// Left Column Field Rows (weighment details).
  Widget _buildLeftColumn(
    bool isGrossEnabled,
    bool isTareEnabled, {
    double labelWidth = 148.0,
    double fieldGap = 11.0,
  }) {
    return Column(
      children: [
        BillFormRow(
          label: 'SERIAL NO',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: BillFormSerialNoDisplay(billNumber: widget.billNumber),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'VEHICLE NO',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: _buildTruckNoField(),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'TYPE',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: _buildTypeSelector(),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'MATERIAL',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: _buildMaterialField(),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'DESCRIPTION',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: _buildDescriptionField(),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'CONTAINER NO',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: _buildContainerNoField(),
        ),
      ],
    );
  }

  void _onGrossWeightChanged(String text) {
    widget.onGrossWeightChanged(text);
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) {
      if (_grossDate == null || _grossTime == null) {
        final now = widget.grossCapturedAt ?? DateTime.now();
        setState(() {
          _grossDate ??= now;
          _grossTime ??= TimeOfDay.fromDateTime(now);
        });
        final combined = DateTime(
          _grossDate!.year,
          _grossDate!.month,
          _grossDate!.day,
          _grossTime!.hour,
          _grossTime!.minute,
        );
        widget.onGrossCapturedAtChanged?.call(combined);
      }
    } else {
      if (_grossDate != null || _grossTime != null) {
        setState(() {
          _grossDate = null;
          _grossTime = null;
        });
        widget.onGrossCapturedAtChanged?.call(null);
      }
    }
  }

  void _onTareWeightChanged(String text) {
    widget.onTareWeightChanged(text);
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) {
      if (_tareDate == null || _tareTime == null) {
        final now = widget.tareCapturedAt ?? DateTime.now();
        setState(() {
          _tareDate ??= now;
          _tareTime ??= TimeOfDay.fromDateTime(now);
        });
        final combined = DateTime(
          _tareDate!.year,
          _tareDate!.month,
          _tareDate!.day,
          _tareTime!.hour,
          _tareTime!.minute,
        );
        widget.onTareCapturedAtChanged?.call(combined);
      }
    } else {
      if (_tareDate != null || _tareTime != null) {
        setState(() {
          _tareDate = null;
          _tareTime = null;
        });
        widget.onTareCapturedAtChanged?.call(null);
      }
    }
  }

  void _commitGrossWeight(String text) {
    widget.onGrossWeightCommitted?.call(text);
    final weight = double.tryParse(text);
    if (weight == null || weight <= 0) {
      if (text.trim().isEmpty || weight == 0) {
        setState(() {
          _grossDate = null;
          _grossTime = null;
        });
        widget.onGrossCapturedAtChanged?.call(null);
      }
      return;
    }
    if (_grossDate == null || _grossTime == null) {
      final now = widget.grossCapturedAt ?? DateTime.now();
      setState(() {
        _grossDate ??= now;
        _grossTime ??= TimeOfDay.fromDateTime(now);
      });
      final combined = DateTime(
        _grossDate!.year,
        _grossDate!.month,
        _grossDate!.day,
        _grossTime!.hour,
        _grossTime!.minute,
      );
      widget.onGrossCapturedAtChanged?.call(combined);
    }
  }

  void _commitTareWeight(String text) {
    widget.onTareWeightCommitted?.call(text);
    final weight = double.tryParse(text);
    if (weight == null || weight <= 0) {
      if (text.trim().isEmpty || weight == 0) {
        setState(() {
          _tareDate = null;
          _tareTime = null;
        });
        widget.onTareCapturedAtChanged?.call(null);
      }
      return;
    }
    if (_tareDate == null || _tareTime == null) {
      final now = widget.tareCapturedAt ?? DateTime.now();
      setState(() {
        _tareDate ??= now;
        _tareTime ??= TimeOfDay.fromDateTime(now);
      });
      final combined = DateTime(
        _tareDate!.year,
        _tareDate!.month,
        _tareDate!.day,
        _tareTime!.hour,
        _tareTime!.minute,
      );
      widget.onTareCapturedAtChanged?.call(combined);
    }
  }

  void _onSelectGrossDate(DateTime picked) {
    setState(() => _grossDate = picked);
    final t = _grossTime ?? TimeOfDay.now();
    setState(() => _grossTime = t);
    final dt = DateTime(
      picked.year,
      picked.month,
      picked.day,
      t.hour,
      t.minute,
    );
    widget.onGrossCapturedAtChanged?.call(dt);
  }

  void _onSelectGrossTime(TimeOfDay picked) {
    final d = _grossDate ?? DateTime.now();
    setState(() {
      _grossDate = d;
      _grossTime = picked;
    });
    final dt = DateTime(d.year, d.month, d.day, picked.hour, picked.minute);
    widget.onGrossCapturedAtChanged?.call(dt);
  }

  void _onSelectTareDate(DateTime picked) {
    setState(() => _tareDate = picked);
    final t = _tareTime ?? TimeOfDay.now();
    setState(() => _tareTime = t);
    final dt = DateTime(
      picked.year,
      picked.month,
      picked.day,
      t.hour,
      t.minute,
    );
    widget.onTareCapturedAtChanged?.call(dt);
  }

  void _onSelectTareTime(TimeOfDay picked) {
    final d = _tareDate ?? DateTime.now();
    setState(() {
      _tareDate = d;
      _tareTime = picked;
    });
    final dt = DateTime(d.year, d.month, d.day, picked.hour, picked.minute);
    widget.onTareCapturedAtChanged?.call(dt);
  }

  /// Right Column: three dedicated weight displays (Gross green,
  /// Tare red, Net blue), each with its date/time controls below.
  Widget _buildRightColumn(
    bool isGrossEnabled,
    bool isTareEnabled, {
    double labelWidth = 148.0,
    double fieldGap = 11.0,
  }) {
    final effectiveWeightError =
        widget.weightError ?? widget.weightValidationError;

    return Column(
      children: [
        BillFormRow(
          label: 'GROSS WEIGHT',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: BillFormWeightRow(
            controller: widget.grossWeightController,
            weightKg: widget.grossWeightKg,
            weightUnit: widget.weightUnit,
            enabled: isGrossEnabled,
            isCaptured:
                (widget.grossWeightKg > 0 ||
                    widget.grossWeightController.text.trim().isNotEmpty) &&
                _grossDate != null,
            hasError: effectiveWeightError != null,
            focusNode: widget.grossWeightFocusNode,
            date: _grossDate,
            time: _grossTime,
            onSelectDate: _onSelectGrossDate,
            onSelectTime: _onSelectGrossTime,
            onWeightChanged: _onGrossWeightChanged,
            onWeightCommitted: _commitGrossWeight,
            onSubmittedNext: () => widget.tareWeightFocusNode?.requestFocus(),
            accent: WeightRowAccent.green,
          ),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'TARE WEIGHT',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              BillFormWeightRow(
                controller: widget.tareWeightController,
                weightKg: widget.tareWeightKg,
                weightUnit: widget.weightUnit,
                enabled: isTareEnabled,
                isCaptured:
                    (widget.tareWeightKg > 0 ||
                        widget.tareWeightController.text.trim().isNotEmpty) &&
                    _tareDate != null,
                hasError: effectiveWeightError != null,
                focusNode: widget.tareWeightFocusNode,
                date: _tareDate,
                time: _tareTime,
                onSelectDate: _onSelectTareDate,
                onSelectTime: _onSelectTareTime,
                onWeightChanged: _onTareWeightChanged,
                onWeightCommitted: _commitTareWeight,
                accent: WeightRowAccent.red,
              ),
              if (effectiveWeightError != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 15,
                        color: Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          effectiveWeightError,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'NET WEIGHT',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: BillFormNetWeightDisplay(
            grossWeightKg: widget.grossWeightKg,
            tareWeightKg: widget.tareWeightKg,
            netWeightKg: widget.netWeightKg,
            weightUnit: widget.weightUnit,
          ),
        ),
      ],
    );
  }

  // --- Left Column Field Builders ---

  /// 1. TRUCK NO
  Widget _buildTruckNoField() {
    final hasError = widget.vehicleNumberError != null;
    final isValid = widget.vehicleNumber.trim().isNotEmpty && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BillFormFieldShell(
          prefixIcon: Icons.local_shipping_outlined,
          hasError: hasError,
          isValid: isValid,
          child: TextField(
            key: const Key('bill_vehicle_number_field'),
            controller: widget.vehicleNumberController,
            focusNode: widget.vehicleFocusNode,
            inputFormatters: [UpperCaseTextFormatter()],
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              hintText: 'Enter Vehicle Number',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            onChanged: widget.onVehicleNumberChanged,
            onSubmitted: (_) => widget.typeFocusNode?.requestFocus(),
          ),
        ),
        _buildFieldError(widget.vehicleNumberError),
      ],
    );
  }

  /// 2. TYPE Selector (● GROSS   ○ TARE)
  Widget _buildTypeSelector() {
    return Focus(
      focusNode: widget.typeFocusNode,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          _focusAfterTypeStep();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
            event.logicalKey == LogicalKeyboardKey.arrowRight) {
          final current = (_selectedType ?? widget.selectedType).toLowerCase();
          final next = current == 'gross' ? 'Tare' : 'Gross';
          setState(() => _selectedType = next);
          widget.onTypeChanged?.call(next);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BillFormTypeSelector(
            selectedType: _selectedType ?? widget.selectedType,
            onChanged: (type) {
              setState(() => _selectedType = type);
              widget.onTypeChanged?.call(type);
            },
          ),
          const SizedBox(height: 5),
          const Text(
            'F1 captures live weight into the selected type',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11.5,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. MATERIAL (free-text input, e.g. Sand, Stone, Gravel).
  Widget _buildMaterialField() {
    return BillFormFieldShell(
      prefixIcon: Icons.inventory_2_outlined,
      child: TextField(
        key: const Key('bill_material_field'),
        controller: widget.materialController,
        focusNode: widget.materialFocusNode,
        onChanged: widget.onMaterialChanged,
        onSubmitted: (_) => widget.descriptionFocusNode?.requestFocus(),
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: 'Enter Material Name',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF94A3B8),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 4. DESCRIPTION (free-text input).
  Widget _buildDescriptionField() {
    return BillFormFieldShell(
      prefixIcon: Icons.description_outlined,
      child: TextField(
        key: const Key('bill_description_field'),
        controller: widget.descriptionController,
        focusNode: widget.descriptionFocusNode,
        onChanged: widget.onDescriptionChanged,
        onSubmitted: (_) => widget.remarksFocusNode?.requestFocus(),
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: 'Enter Description',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF94A3B8),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 5. CONTAINER NO
  Widget _buildContainerNoField() {
    return BillFormFieldShell(
      prefixIcon: Icons.view_in_ar_outlined,
      child: TextField(
        controller: widget.remarksController,
        focusNode: widget.remarksFocusNode,
        onChanged: widget.onRemarksChanged,
        onSubmitted: (_) => widget.grossWeightFocusNode?.requestFocus(),
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: 'Container / Trailer No',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF94A3B8),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
