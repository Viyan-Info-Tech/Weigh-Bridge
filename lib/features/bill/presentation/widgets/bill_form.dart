import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart' show AppDatabase;
import '../../../../core/utils/text_formatters.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../material/domain/entities/material_item.dart' as domain;
import 'bill_form_field_shell.dart';
import 'bill_form_readonly_fields.dart';
import 'bill_form_row.dart';
import 'bill_form_type_selector.dart';
import 'bill_form_weight_row.dart';
import 'weighment_charge_dialog.dart';

/// Industrial 2-Column Weighment Ticket Form
/// Designed with premium tactile instrument aesthetics:
/// - Framed icon prefix badges with soft slate background
/// - Integrated blue search action buttons for codes
/// - Precision currency stepper for charges
/// - Clean proportional Weight, Date & Time pickers
/// - Balanced 2-column layout with subtle dividing rhythm
class BillForm extends StatefulWidget {
  final String billNumber;
  final List<Customer> customers;
  final List<domain.MaterialItem> materials;
  final Customer? selectedCustomer;
  final String vehicleNumber;
  final domain.MaterialItem? selectedMaterial;
  final String paymentMode;
  final bool isEditing;
  final String? editingFirstWeightType;
  final TextEditingController grossWeightController;
  final TextEditingController tareWeightController;
  final TextEditingController remarksController;
  final TextEditingController? vehicleChargeController;
  final TextEditingController? vehicleNumberController;
  final double grossWeightKg;
  final double tareWeightKg;
  final double netWeightKg;
  final double vehicleCharge;
  final double amount;
  final String weightUnit;
  final String? weightValidationError;
  final bool isReady;
  final DateTime? grossCapturedAt;
  final DateTime? tareCapturedAt;
  final String selectedType;
  final ValueChanged<String>? onTypeChanged;

  final FocusNode? customerFocusNode;
  final FocusNode? vehicleFocusNode;
  final FocusNode? typeFocusNode;
  final FocusNode? materialFocusNode;
  final FocusNode? materialCodeFocusNode;
  final FocusNode? customerCodeFocusNode;
  final FocusNode? mobileFocusNode;
  final FocusNode? remarksFocusNode;
  final FocusNode? grossWeightFocusNode;
  final FocusNode? tareWeightFocusNode;
  final FocusNode? vehicleChargeFocusNode;
  final FocusNode? paymentModeFocusNode;

  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<String> onVehicleNumberChanged;
  final ValueChanged<domain.MaterialItem> onMaterialChanged;
  final Future<Customer?> Function(String code)? onCustomerCodeSubmitted;
  final Future<domain.MaterialItem?> Function(String code)?
  onMaterialCodeSubmitted;
  final ValueChanged<String> onGrossWeightChanged;
  final ValueChanged<String> onTareWeightChanged;
  final ValueChanged<String>? onGrossWeightCommitted;
  final ValueChanged<String>? onTareWeightCommitted;
  final ValueChanged<DateTime?>? onGrossCapturedAtChanged;
  final ValueChanged<DateTime?>? onTareCapturedAtChanged;
  final ValueChanged<String> onRemarksChanged;
  final ValueChanged<String> onPaymentModeChanged;
  final ValueChanged<String>? onWeightUnitChanged;
  final ValueChanged<String> onVehicleChargeChanged;
  final VoidCallback onResetVehicleCharge;
  final ValueChanged<String>? onMobileNumberChanged;
  final Future<void> Function()? onAddCustomer;
  final Future<void> Function()? onAddMaterial;

  final String? vehicleNumberError;
  final String? materialError;
  final String? customerError;
  final String? chargesError;
  final String? weightError;
  final String? mobileError;

  const BillForm({
    super.key,
    required this.billNumber,
    required this.customers,
    required this.materials,
    this.selectedCustomer,
    this.vehicleNumber = '',
    this.selectedMaterial,
    required this.paymentMode,
    this.isEditing = false,
    this.editingFirstWeightType,
    required this.grossWeightController,
    required this.tareWeightController,
    required this.remarksController,
    this.vehicleChargeController,
    this.vehicleNumberController,
    this.grossWeightKg = 0,
    this.tareWeightKg = 0,
    required this.netWeightKg,
    required this.vehicleCharge,
    required this.amount,
    this.weightUnit = 'kg',
    this.weightValidationError,
    this.isReady = true,
    this.grossCapturedAt,
    this.tareCapturedAt,
    this.selectedType = 'Gross',
    this.onTypeChanged,
    this.customerFocusNode,
    this.vehicleFocusNode,
    this.typeFocusNode,
    this.materialFocusNode,
    this.materialCodeFocusNode,
    this.customerCodeFocusNode,
    this.mobileFocusNode,
    this.remarksFocusNode,
    this.grossWeightFocusNode,
    this.tareWeightFocusNode,
    this.vehicleChargeFocusNode,
    this.paymentModeFocusNode,
    required this.onCustomerChanged,
    required this.onVehicleNumberChanged,
    required this.onMaterialChanged,
    this.onCustomerCodeSubmitted,
    this.onMaterialCodeSubmitted,
    required this.onGrossWeightChanged,
    required this.onTareWeightChanged,
    this.onGrossWeightCommitted,
    this.onTareWeightCommitted,
    this.onGrossCapturedAtChanged,
    this.onTareCapturedAtChanged,
    required this.onRemarksChanged,
    required this.onPaymentModeChanged,
    this.onWeightUnitChanged,
    required this.onVehicleChargeChanged,
    required this.onResetVehicleCharge,
    this.onMobileNumberChanged,
    this.onAddCustomer,
    this.onAddMaterial,
    this.vehicleNumberError,
    this.materialError,
    this.customerError,
    this.chargesError,
    this.weightError,
    this.mobileError,
  });

  @override
  State<BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  late final TextEditingController _mobileController;
  late final TextEditingController _materialCodeController;
  late final TextEditingController _customerCodeController;
  final ScrollController _scrollController = ScrollController();

  String? _localMaterialError;
  String? _localCustomerError;

  String? _selectedType;
  DateTime? _grossDate;
  TimeOfDay? _grossTime;
  DateTime? _tareDate;
  TimeOfDay? _tareTime;

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
    _mobileController = TextEditingController(
      text: widget.selectedCustomer?.mobile ?? '',
    );
    _materialCodeController = TextEditingController(
      text:
          widget.selectedMaterial != null &&
              widget.selectedMaterial!.code.isNotEmpty
          ? widget.selectedMaterial!.code
          : '',
    );
    _customerCodeController = TextEditingController(
      text: widget.selectedCustomer != null
          ? widget.selectedCustomer!.customerCode
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant BillForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedMaterial != oldWidget.selectedMaterial) {
      if (widget.selectedMaterial != null) {
        _localMaterialError = null;
      }
      _materialCodeController.text =
          widget.selectedMaterial != null &&
              widget.selectedMaterial!.code.isNotEmpty
          ? widget.selectedMaterial!.code
          : '';
    }

    if (widget.selectedCustomer != oldWidget.selectedCustomer) {
      if (widget.selectedCustomer != null) {
        _localCustomerError = null;
      }
      _customerCodeController.text = widget.selectedCustomer != null
          ? widget.selectedCustomer!.customerCode
          : '';
      if (_mobileController.text.isEmpty &&
          widget.selectedCustomer?.mobile != null) {
        _mobileController.text = widget.selectedCustomer!.mobile!;
      }
    }

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
    _mobileController.dispose();
    _materialCodeController.dispose();
    _customerCodeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasBothWeights = widget.grossWeightKg > 0 && widget.tareWeightKg > 0;
    final isGrossEnabled =
        !widget.isEditing ||
        (hasBothWeights
            ? widget.editingFirstWeightType == 'GROSS'
            : widget.grossWeightKg <= 0);
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

  /// Left Column Field Rows
  Widget _buildLeftColumn(
    bool isGrossEnabled,
    bool isTareEnabled, {
    double labelWidth = 148.0,
    double fieldGap = 11.0,
  }) {
    return Column(
      children: [
        BillFormRow(
          label: 'TRUCK NO',
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
          label: 'MATERIAL CODE',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: _buildMaterialCodeField(),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'CUSTOMER CODE',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: _buildCustomerCodeField(),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'CHARGES (₹)',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: _buildChargesField(),
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
          label: 'MOBILE NO',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: _buildMobileNoField(),
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

  /// Right Column Field Rows
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
          label: 'SERIAL NO',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: BillFormSerialNoDisplay(billNumber: widget.billNumber),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'MATERIAL NAME',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: BillFormMaterialNameField(
            materials: widget.materials,
            selectedMaterial: widget.selectedMaterial,
            focusNode: widget.materialFocusNode,
            onChanged: widget.onMaterialChanged,
          ),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'CUSTOMER NAME',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: BillFormCustomerNameField(
            customers: widget.customers,
            selectedCustomer: widget.selectedCustomer,
            focusNode: widget.customerFocusNode,
            onChanged: widget.onCustomerChanged,
          ),
        ),
        SizedBox(height: fieldGap),
        BillFormRow(
          label: 'GROSS WEIGHT',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: BillFormWeightRow(
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
                isCaptured: widget.tareWeightKg > 0 && _tareDate != null,
                hasError: effectiveWeightError != null,
                focusNode: widget.tareWeightFocusNode,
                date: _tareDate,
                time: _tareTime,
                onSelectDate: _onSelectTareDate,
                onSelectTime: _onSelectTareTime,
                onWeightChanged: widget.onTareWeightChanged,
                onWeightCommitted: _commitTareWeight,
                onSubmittedNext: () =>
                    widget.vehicleChargeFocusNode?.requestFocus(),
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
              LengthLimitingTextInputFormatter(10),
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
          widget.materialCodeFocusNode?.requestFocus();
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

  /// 3. MATERIAL CODE
  Widget _buildMaterialCodeField() {
    final error = _localMaterialError ?? widget.materialError;
    final hasError = error != null;
    final isValid = widget.selectedMaterial != null && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BillFormFieldShell(
          prefixIcon: Icons.search_rounded,
          hasError: hasError,
          isValid: isValid,
          suffix: BillFormSearchButton(
            onTap: widget.onAddMaterial,
            tooltip: 'Search Material Code',
          ),
          child: TextField(
            key: const Key('bill_material_code_field'),
            controller: _materialCodeController,
            focusNode: widget.materialCodeFocusNode,
            onChanged: (val) {
              if (_localMaterialError != null) {
                setState(() => _localMaterialError = null);
              }
            },
            onSubmitted: _onMaterialCodeSubmitted,
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
              hintText: 'Select Material Code',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        _buildFieldError(error),
      ],
    );
  }

  Future<void> _onMaterialCodeSubmitted(String value) async {
    final code = value.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _localMaterialError = 'Material code is required.');
      return;
    }
    final match = widget.onMaterialCodeSubmitted != null
        ? await widget.onMaterialCodeSubmitted!(code)
        : widget.materials
              .where((material) => material.code.toUpperCase() == code)
              .firstOrNull;
    if (!mounted) return;
    if (match == null) {
      setState(() => _localMaterialError = 'Material code does not exist.');
      return;
    }
    setState(() => _localMaterialError = null);
    _materialCodeController.text = match.code;
    widget.onMaterialChanged(match);
    widget.customerCodeFocusNode?.requestFocus();
  }

  /// 4. CUSTOMER CODE
  Widget _buildCustomerCodeField() {
    final error = _localCustomerError ?? widget.customerError;
    final hasError = error != null;
    final isValid = widget.selectedCustomer != null && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BillFormFieldShell(
          prefixIcon: Icons.domain_rounded,
          hasError: hasError,
          isValid: isValid,
          suffix: BillFormSearchButton(
            onTap: widget.onAddCustomer,
            tooltip: 'Search Customer Code',
          ),
          child: TextField(
            key: const Key('bill_customer_code_field'),
            controller: _customerCodeController,
            focusNode: widget.customerCodeFocusNode,
            keyboardType: TextInputType.text,
            onChanged: (val) {
              if (_localCustomerError != null) {
                setState(() => _localCustomerError = null);
              }
            },
            onSubmitted: (value) async {
              final code = value.trim().toUpperCase();
              if (code.isEmpty) {
                setState(
                  () => _localCustomerError = 'Customer code is required.',
                );
                return;
              }
              final customer = widget.onCustomerCodeSubmitted != null
                  ? await widget.onCustomerCodeSubmitted!(code)
                  : widget.customers
                        .where(
                          (customer) =>
                              customer.customerCode.toUpperCase() == code,
                        )
                        .firstOrNull;
              if (!mounted) return;
              if (customer != null) {
                setState(() => _localCustomerError = null);
                widget.onCustomerChanged(customer);
                await _showChargeSelection();
              } else {
                setState(
                  () => _localCustomerError = 'Customer code does not exist.',
                );
              }
            },
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
              hintText: 'Type Customer Code',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        _buildFieldError(error),
      ],
    );
  }

  /// 5. CHARGES (₹)
  Widget _buildChargesField() {
    final hasError = widget.chargesError != null;
    final isValid = widget.vehicleCharge > 0 && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BillFormFieldShell(
          prefixText: '₹',
          hasError: hasError,
          isValid: isValid,
          suffix: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.arrow_drop_down,
              size: 22,
              color: Color(0xFF64748B),
            ),
          ),
          child: TextField(
            controller: widget.vehicleChargeController,
            focusNode: widget.vehicleChargeFocusNode,
            readOnly: true,
            onTap: _showChargeSelection,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              hintText: widget.vehicleCharge > 0 ? null : '0.00',
            ),
          ),
        ),
        _buildFieldError(widget.chargesError),
      ],
    );
  }

  Future<void> _showChargeSelection() async {
    try {
      final database = context.read<AppDatabase>();
      final amount = await showDialog<double>(
        context: context,
        builder: (_) => WeighmentChargeDialog(database: database),
      );
      if (amount == null) return;
      final value = amount.toStringAsFixed(2);
      widget.vehicleChargeController?.text = value;
      widget.onVehicleChargeChanged(value);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.remarksFocusNode?.requestFocus();
      });
    } catch (_) {
      // Allow running in environments where AppDatabase is not provided
    }
  }

  /// 6. CONTAINER NO
  Widget _buildContainerNoField() {
    return BillFormFieldShell(
      prefixIcon: Icons.view_in_ar_outlined,
      child: TextField(
        controller: widget.remarksController,
        focusNode: widget.remarksFocusNode,
        onChanged: widget.onRemarksChanged,
        onSubmitted: (_) => widget.mobileFocusNode?.requestFocus(),
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

  /// 7. MOBILE NO
  Widget _buildMobileNoField() {
    final hasError = widget.mobileError != null;
    final isValid = _mobileController.text.trim().length == 10 && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BillFormFieldShell(
          prefixIcon: Icons.phone_outlined,
          hasError: hasError,
          isValid: isValid,
          child: TextField(
            controller: _mobileController,
            focusNode: widget.mobileFocusNode,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: (val) {
              widget.onMobileNumberChanged?.call(val);
            },
            onSubmitted: (_) => widget.materialFocusNode?.requestFocus(),
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
              hintText: 'Mobile / Phone No',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        _buildFieldError(widget.mobileError),
      ],
    );
  }
}
