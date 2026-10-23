import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/text_formatters.dart';
import 'bill_form_field_shell.dart';
import 'bill_form_readonly_fields.dart';
import 'bill_form_row.dart';
import 'bill_form_type_selector.dart';
import 'bill_form_weight_row.dart';
import 'searchable_dropdown.dart';
import 'second_weight_controls.dart';

/// Industrial 2-Column Weighment Ticket Form
/// Designed with premium tactile instrument aesthetics:
/// - Framed icon prefix badges with soft slate background
/// - Clean proportional Weight, Date & Time pickers
/// - Balanced 2-column layout with subtle dividing rhythm
class BillForm extends StatefulWidget {
  final String billNumber;
  final String materialText;

  /// `Name - Type` options loaded from the materials master, e.g.
  /// `Auto - Empty`. Empty means the legacy free-text field is shown.
  final List<String> materialOptions;
  final String vehicleNumber;
  final TextEditingController grossWeightController;
  final TextEditingController tareWeightController;
  final TextEditingController remarksController;
  final TextEditingController materialController;
  final TextEditingController? vehicleNumberController;

  /// Controller for the optional Charges amount. Optional so existing
  /// call sites and tests that don't exercise charges still compile.
  final TextEditingController? chargesController;
  final String chargesText;
  final String? chargesError;
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

  /// True while the form is in SECOND WEIGHT mode: the GROSS/TARE selector
  /// is hidden and the previous weighment of the entered vehicle is loaded
  /// into the matching weight field (locked) for the operator to pair with
  /// the weight captured now.
  final bool isSecondWeightMode;

  /// True while the previous-weighment lookup for the entered vehicle is in
  /// flight, so the toggle can show a busy indicator.
  final bool isFetchingPreviousWeight;

  /// Weight type ('GROSS'/'TARE') populated from the previous weighment in
  /// SECOND WEIGHT mode, or null when no bill is matched. That field is
  /// locked; the opposite field is where the current weight is captured.
  final String? previousWeightType;

  /// Bill number of the matched previous weighment for the status banner.
  final String? previousBillNumber;

  /// Display text of the previous weight (already converted to the form's
  /// unit) for the status banner.
  final String? previousWeightText;

  /// Capture timestamp of the previous weighment for the status banner.
  final DateTime? previousCapturedAt;

  /// Operator-facing note when no eligible previous weighment exists (or the
  /// matched one has invalid data); shown in the status banner.
  final String? previousWeightMessage;

  /// Toggles the SECOND WEIGHT workflow on the weighment form.
  final VoidCallback? onSecondWeightToggle;

  final FocusNode? vehicleFocusNode;
  final FocusNode? typeFocusNode;
  final FocusNode? materialFocusNode;
  final FocusNode? chargesFocusNode;
  final FocusNode? remarksFocusNode;
  final FocusNode? grossWeightFocusNode;
  final FocusNode? tareWeightFocusNode;

  final ValueChanged<String> onVehicleNumberChanged;
  final ValueChanged<String> onMaterialChanged;
  final ValueChanged<String>? onChargesChanged;
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
    this.materialOptions = const [],
    this.chargesText = '',
    this.vehicleNumber = '',
    required this.grossWeightController,
    required this.tareWeightController,
    required this.remarksController,
    required this.materialController,
    this.vehicleNumberController,
    this.chargesController,
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
    this.isSecondWeightMode = false,
    this.isFetchingPreviousWeight = false,
    this.previousWeightType,
    this.previousBillNumber,
    this.previousWeightText,
    this.previousCapturedAt,
    this.previousWeightMessage,
    this.onSecondWeightToggle,
    this.vehicleFocusNode,
    this.typeFocusNode,
    this.materialFocusNode,
    this.chargesFocusNode,
    this.remarksFocusNode,
    this.grossWeightFocusNode,
    this.tareWeightFocusNode,
    required this.onVehicleNumberChanged,
    required this.onMaterialChanged,
    this.onChargesChanged,
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
    this.chargesError,
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

  bool _materialFocused = false;

  void _handleMaterialFocusChange() {
    final focused = widget.materialFocusNode?.hasFocus ?? false;
    if (focused != _materialFocused) {
      setState(() => _materialFocused = focused);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    widget.materialFocusNode?.addListener(_handleMaterialFocusChange);
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

    if (widget.materialFocusNode != oldWidget.materialFocusNode) {
      oldWidget.materialFocusNode?.removeListener(_handleMaterialFocusChange);
      widget.materialFocusNode?.addListener(_handleMaterialFocusChange);
      _materialFocused = widget.materialFocusNode?.hasFocus ?? false;
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
    widget.materialFocusNode?.removeListener(_handleMaterialFocusChange);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Both weights stay editable on a normal bill: this form always
    // represents a new weighment. In SECOND WEIGHT mode the field that holds
    // the retrieved previous weight is locked — it is history and must not
    // be overwritten — while the opposite field stays editable for the weight
    // captured now.
    final previousType = widget.isSecondWeightMode
        ? widget.previousWeightType
        : null;
    final isGrossEnabled = previousType != 'GROSS';
    final isTareEnabled = previousType != 'TARE';

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
          label: 'CONTAINER NO',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: _buildContainerNoField(),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'CHARGES',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: _buildChargesField(),
        ),
      ],
    );
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
            key: const Key('gross_weight_row'),
            controller: widget.grossWeightController,
            weightKg: widget.grossWeightKg,
            weightUnit: widget.weightUnit,
            enabled: isGrossEnabled,
            isCaptured: widget.grossWeightKg > 0 && _grossDate != null,
            hasError: effectiveWeightError != null,
            focusNode: widget.grossWeightFocusNode,
            date: _grossDate,
            time: _grossTime,
            onSelectDate: _onSelectGrossDate,
            onSelectTime: _onSelectGrossTime,
            onWeightChanged: widget.onGrossWeightChanged,
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
                key: const Key('tare_weight_row'),
                controller: widget.tareWeightController,
                weightKg: widget.tareWeightKg,
                weightUnit: widget.weightUnit,
                enabled: isTareEnabled,
                isCaptured: widget.tareWeightKg > 0 && _tareDate != null,
                hasError: effectiveWeightError != null,
                focusNode: widget.tareWeightFocusNode,
                date: _tareDate,
                time: _tareTime,
                onSelectDate: _onSelectTareDate,
                onSelectTime: _onSelectTareTime,
                onWeightChanged: widget.onTareWeightChanged,
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              UpperCaseTextFormatter(),
            ],
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
            onSubmitted: (_) {
              if (widget.isSecondWeightMode) {
                // The TYPE selector is hidden in this mode, so the next step
                // is the weight capture: focus the field that will hold the
                // current weight, or MATERIAL while no previous weighment is
                // matched yet.
                final captureFocus = widget.previousWeightType == 'GROSS'
                    ? widget.tareWeightFocusNode
                    : widget.previousWeightType == 'TARE'
                    ? widget.grossWeightFocusNode
                    : null;
                (captureFocus ?? widget.materialFocusNode)?.requestFocus();
              } else {
                widget.typeFocusNode?.requestFocus();
              }
            },
          ),
        ),
        _buildFieldError(widget.vehicleNumberError),
      ],
    );
  }

  /// 2. TYPE Selector (● GROSS   ○ TARE) + separate SECOND WEIGHT toggle.
  ///
  /// Normal mode shows the GROSS/TARE selector with the SECOND WEIGHT button
  /// beside it. When SECOND WEIGHT mode is active the selector is hidden
  /// entirely and the row shows the active toggle plus the lookup status
  /// banner, keeping the same row footprint.
  Widget _buildTypeSelector() {
    if (widget.isSecondWeightMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SecondWeightToggle(
            isActive: true,
            isBusy: widget.isFetchingPreviousWeight,
            onTap: () => widget.onSecondWeightToggle?.call(),
          ),
          const SizedBox(height: 5),
          SecondWeightStatusBanner(
            isFetching: widget.isFetchingPreviousWeight,
            vehicleNumber: widget.vehicleNumber,
            previousBillNumber: widget.previousBillNumber,
            previousWeightType: widget.previousWeightType,
            previousWeightText: widget.previousWeightText,
            previousCapturedAt: widget.previousCapturedAt,
            message: widget.previousWeightMessage,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Focus(
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
              final current = (_selectedType ?? widget.selectedType)
                  .toLowerCase();
              final next = current == 'gross' ? 'Tare' : 'Gross';
              setState(() => _selectedType = next);
              widget.onTypeChanged?.call(next);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: BillFormTypeSelector(
            selectedType: _selectedType ?? widget.selectedType,
            onChanged: (type) {
              setState(() => _selectedType = type);
              widget.onTypeChanged?.call(type);
            },
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Expanded(
              child: Text(
                'F1 captures live weight into the selected type',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SecondWeightToggle(
              isActive: false,
              onTap: () => widget.onSecondWeightToggle?.call(),
            ),
          ],
        ),
      ],
    );
  }

  /// 3. MATERIAL (database-backed dropdown of `Name - Type` options).
  ///
  /// The field is selection-only (`enableSearch: false`): the operator picks a
  /// saved material and can never type an arbitrary name. When no materials
  /// exist yet, the popup explains where to add them. Legacy free-text values
  /// already saved on a weighment still display here via [BillForm.materialText].
  Widget _buildMaterialField() {
    return BillFormFieldShell(
      prefixIcon: Icons.inventory_2_outlined,
      isFocused: _materialFocused,
      child: SearchableDropdown<String>(
        key: const Key('bill_material_field'),
        label: 'MATERIAL',
        showLabel: false,
        borderless: true,
        enableSearch: false,
        emptyItemsMessage:
            'No materials available. Add a material in Material Management.',
        items: widget.materialOptions,
        selectedItem: widget.materialText.isEmpty ? null : widget.materialText,
        itemLabel: (value) => value,
        focusNode: widget.materialFocusNode,
        nextFocusNode: widget.remarksFocusNode,
        hintText: 'Select Material',
        onChanged: widget.onMaterialChanged,
      ),
    );
  }

  /// 4. CONTAINER NO
  Widget _buildContainerNoField() {
    return BillFormFieldShell(
      prefixIcon: Icons.view_in_ar_outlined,
      child: TextField(
        controller: widget.remarksController,
        focusNode: widget.remarksFocusNode,
        onChanged: widget.onRemarksChanged,
        onSubmitted: (_) => widget.chargesFocusNode != null
            ? widget.chargesFocusNode!.requestFocus()
            : widget.grossWeightFocusNode?.requestFocus(),
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

  /// 5. CHARGES (optional, manually entered amount in rupees).
  ///
  /// The field is deliberately free of any auto-calculation: the operator
  /// types the exact amount to bill. Empty means no charge. Input is
  /// restricted to digits with at most two decimals by
  /// [DecimalTextFormatter]; save-time validation is the final gate.
  Widget _buildChargesField() {
    final hasError = widget.chargesError != null;
    final isValid = widget.chargesText.trim().isNotEmpty && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BillFormFieldShell(
          prefixIcon: Icons.currency_rupee_outlined,
          hasError: hasError,
          isValid: isValid,
          child: TextField(
            key: const Key('bill_charges_field'),
            controller: widget.chargesController,
            focusNode: widget.chargesFocusNode,
            onChanged: widget.onChargesChanged,
            onSubmitted: (_) => widget.grossWeightFocusNode?.requestFocus(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              DecimalTextFormatter(),
            ],
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              hintText: 'Enter Charges',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        _buildFieldError(widget.chargesError),
      ],
    );
  }
}
