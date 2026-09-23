import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/text_formatters.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../material/domain/entities/material_item.dart' as domain;
import 'bill_form_charges_stepper.dart';
import 'bill_form_field_shell.dart';
import 'bill_form_row.dart';
import 'bill_form_type_selector.dart';
import 'bill_form_weight_row.dart';

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
  final ValueChanged<String> onRemarksChanged;
  final ValueChanged<String> onPaymentModeChanged;
  final ValueChanged<String>? onWeightUnitChanged;
  final ValueChanged<String> onVehicleChargeChanged;
  final VoidCallback onResetVehicleCharge;
  final Future<void> Function()? onAddCustomer;
  final Future<void> Function()? onAddMaterial;

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
    required this.onRemarksChanged,
    required this.onPaymentModeChanged,
    this.onWeightUnitChanged,
    required this.onVehicleChargeChanged,
    required this.onResetVehicleCharge,
    this.onAddCustomer,
    this.onAddMaterial,
  });

  @override
  State<BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  late final TextEditingController _mobileController;
  late final TextEditingController _materialCodeController;
  late final TextEditingController _customerCodeController;

  String? _selectedType;
  DateTime _grossDate = DateTime.now();
  TimeOfDay _grossTime = TimeOfDay.now();
  DateTime _tareDate = DateTime.now();
  TimeOfDay _tareTime = TimeOfDay.now();

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
      _materialCodeController.text =
          widget.selectedMaterial != null &&
              widget.selectedMaterial!.code.isNotEmpty
          ? widget.selectedMaterial!.code
          : '';
    }

    if (widget.selectedCustomer != oldWidget.selectedCustomer) {
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

    if (widget.grossCapturedAt != oldWidget.grossCapturedAt &&
        widget.grossCapturedAt != null) {
      _grossDate = widget.grossCapturedAt!;
      _grossTime = TimeOfDay.fromDateTime(widget.grossCapturedAt!);
    }
    if (widget.tareCapturedAt != oldWidget.tareCapturedAt &&
        widget.tareCapturedAt != null) {
      _tareDate = widget.tareCapturedAt!;
      _tareTime = TimeOfDay.fromDateTime(widget.tareCapturedAt!);
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _materialCodeController.dispose();
    _customerCodeController.dispose();
    super.dispose();
  }

  void _stepCharge(double delta) {
    final current =
        double.tryParse(widget.vehicleChargeController?.text ?? '') ??
        widget.vehicleCharge;
    final updated = (current + delta).clamp(0.0, 999999.0);
    final strVal = updated % 1 == 0
        ? updated.toStringAsFixed(0)
        : updated.toStringAsFixed(2);
    widget.vehicleChargeController?.text = strVal;
    widget.onVehicleChargeChanged(strVal);
  }

  @override
  Widget build(BuildContext context) {
    final isGrossEnabled =
        !widget.isEditing || widget.editingFirstWeightType == 'GROSS';
    final isTareEnabled =
        !widget.isEditing || widget.editingFirstWeightType == 'TARE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
          final narrow = constraints.maxWidth < 760;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (narrow) ...[
                _buildLeftColumn(isGrossEnabled, isTareEnabled),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 14),
                _buildRightColumn(isGrossEnabled, isTareEnabled),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildLeftColumn(isGrossEnabled, isTareEnabled),
                    ),
                    const SizedBox(width: 18),
                    Container(
                      width: 1,
                      height: 320,
                      color: const Color(0xFFF1F5F9),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _buildRightColumn(isGrossEnabled, isTareEnabled),
                    ),
                  ],
                ),

              if (widget.weightValidationError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
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
                        size: 16,
                        color: Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.weightValidationError!,
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
          );
        },
      ),
    );
  }

  /// Left Column Field Rows
  Widget _buildLeftColumn(bool isGrossEnabled, bool isTareEnabled) {
    const labelWidth = 135.0;

    return Column(
      children: [
        BillFormRow(
          label: 'TRUCK NO',
          labelWidth: labelWidth,
          child: _buildTruckNoField(),
        ),
        const SizedBox(height: 9),
        BillFormRow(
          label: 'TYPE',
          labelWidth: labelWidth,
          child: _buildTypeSelector(),
        ),
        const SizedBox(height: 9),
        BillFormRow(
          label: 'MATERIAL CODE',
          labelWidth: labelWidth,
          child: _buildMaterialCodeField(),
        ),
        const SizedBox(height: 9),
        BillFormRow(
          label: 'CUSTOMER CODE',
          labelWidth: labelWidth,
          child: _buildCustomerCodeField(),
        ),
        const SizedBox(height: 9),
        BillFormRow(
          label: 'CHARGES (₹)',
          labelWidth: labelWidth,
          child: _buildChargesField(),
        ),
        const SizedBox(height: 9),
        BillFormRow(
          label: 'CONTAINER NO',
          labelWidth: labelWidth,
          child: _buildContainerNoField(),
        ),
        const SizedBox(height: 9),
        BillFormRow(
          label: 'MOBILE NO',
          labelWidth: labelWidth,
          child: _buildMobileNoField(),
        ),
      ],
    );
  }

  /// Right Column Field Rows
  Widget _buildRightColumn(bool isGrossEnabled, bool isTareEnabled) {
    const labelWidth = 135.0;

    return Column(
      children: [
        BillFormRow(
          label: 'SERIAL NO',
          labelWidth: labelWidth,
          child: _buildSerialNoDisplay(),
        ),
        const SizedBox(height: 9),
        BillFormRow(
          label: 'MATERIAL NAME',
          labelWidth: labelWidth,
          child: _buildMaterialNameField(),
        ),
        const SizedBox(height: 9),
        BillFormRow(
          label: 'CUSTOMER NAME',
          labelWidth: labelWidth,
          child: _buildCustomerNameField(),
        ),
        const SizedBox(height: 9),
        BillFormRow(
          label: 'GROSS WEIGHT',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: BillFormWeightRow(
            controller: widget.grossWeightController,
            weightKg: widget.grossWeightKg,
            weightUnit: widget.weightUnit,
            enabled: isGrossEnabled,
            isCaptured: widget.grossWeightKg > 0,
            focusNode: widget.grossWeightFocusNode,
            date: _grossDate,
            time: _grossTime,
            onSelectDate: (d) => setState(() => _grossDate = d),
            onSelectTime: (t) => setState(() => _grossTime = t),
            onWeightChanged: widget.onGrossWeightChanged,
          ),
        ),
        const SizedBox(height: 9),
        BillFormRow(
          label: 'TARE WEIGHT',
          labelWidth: labelWidth,
          crossAxisAlignment: CrossAxisAlignment.start,
          child: BillFormWeightRow(
            controller: widget.tareWeightController,
            weightKg: widget.tareWeightKg,
            weightUnit: widget.weightUnit,
            enabled: isTareEnabled,
            isCaptured: widget.tareWeightKg > 0,
            focusNode: widget.tareWeightFocusNode,
            date: _tareDate,
            time: _tareTime,
            onSelectDate: (d) => setState(() => _tareDate = d),
            onSelectTime: (t) => setState(() => _tareTime = t),
            onWeightChanged: widget.onTareWeightChanged,
          ),
        ),
        const SizedBox(height: 9),
        BillFormRow(
          label: 'NETT WEIGHT',
          labelWidth: labelWidth,
          child: _buildNettWeightDisplay(),
        ),
      ],
    );
  }

  // --- Left Column Field Builders ---

  /// 1. TRUCK NO
  Widget _buildTruckNoField() {
    return BillFormFieldShell(
      prefixIcon: Icons.local_shipping_outlined,
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
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          hintText: 'Enter Vehicle Number',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        onChanged: widget.onVehicleNumberChanged,
        onSubmitted: (_) => widget.typeFocusNode?.requestFocus(),
      ),
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
          const SizedBox(height: 4),
          const Text(
            'F1 captures live weight into the selected type',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. MATERIAL CODE
  Widget _buildMaterialCodeField() {
    return BillFormFieldShell(
      prefixIcon: Icons.search_rounded,
      suffix: BillFormSearchButton(
        onTap: widget.onAddMaterial,
        tooltip: 'Search Material Code',
      ),
      child: TextField(
        key: const Key('bill_material_code_field'),
        controller: _materialCodeController,
        focusNode: widget.materialCodeFocusNode,
        onSubmitted: _onMaterialCodeSubmitted,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          hintText: 'Select Material Code',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Future<void> _onMaterialCodeSubmitted(String value) async {
    final code = value.trim().toUpperCase();
    final match = widget.onMaterialCodeSubmitted != null
        ? await widget.onMaterialCodeSubmitted!(code)
        : widget.materials
              .where((material) => material.code.toUpperCase() == code)
              .firstOrNull;
    if (!mounted) return;
    if (match == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Material code not found')));
      return;
    }
    _materialCodeController.text = match.code;
    widget.onMaterialChanged(match);
    widget.customerCodeFocusNode?.requestFocus();
  }

  /// 4. CUSTOMER CODE
  Widget _buildCustomerCodeField() {
    return BillFormFieldShell(
      prefixIcon: Icons.domain_rounded,
      suffix: BillFormSearchButton(
        onTap: widget.onAddCustomer,
        tooltip: 'Search Customer Code',
      ),
      child: TextField(
        key: const Key('bill_customer_code_field'),
        controller: _customerCodeController,
        focusNode: widget.customerCodeFocusNode,
        keyboardType: TextInputType.text,
        onSubmitted: (value) async {
          final code = value.trim().toUpperCase();
          final customer = widget.onCustomerCodeSubmitted != null
              ? await widget.onCustomerCodeSubmitted!(code)
              : widget.customers
                    .where(
                      (customer) => customer.customerCode.toUpperCase() == code,
                    )
                    .firstOrNull;
          if (!mounted) return;
          if (customer != null) {
            widget.onCustomerChanged(customer);
            widget.vehicleChargeFocusNode?.requestFocus();
          } else {
            _customerCodeController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Customer code not found')),
            );
          }
        },
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          hintText: 'Type Customer Code',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 5. CHARGES (₹)
  Widget _buildChargesField() {
    return BillFormFieldShell(
      prefixText: '₹',
      suffix: BillFormChargesStepper(
        onChanged: widget.onVehicleChargeChanged,
        onIncrement: () => _stepCharge(50.0),
        onDecrement: () => _stepCharge(-50.0),
      ),
      child: TextField(
        controller: widget.vehicleChargeController,
        focusNode: widget.vehicleChargeFocusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: widget.onVehicleChargeChanged,
        onSubmitted: (_) => widget.remarksFocusNode?.requestFocus(),
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          hintText: '0.00',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF94A3B8),
            fontSize: 13,
          ),
        ),
      ),
    );
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
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          hintText: 'Container / Trailer No',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 7. MOBILE NO
  Widget _buildMobileNoField() {
    return BillFormFieldShell(
      prefixIcon: Icons.phone_outlined,
      child: TextField(
        controller: _mobileController,
        focusNode: widget.mobileFocusNode,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        onSubmitted: (_) => widget.materialFocusNode?.requestFocus(),
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          hintText: 'Mobile / Phone No',
          hintStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // --- Right Column Field Builders ---

  /// 1. SERIAL NO
  Widget _buildSerialNoDisplay() {
    return BillFormFieldShell(
      prefixText: '#',
      backgroundColor: const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          widget.billNumber,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// 2. MATERIAL NAME
  Widget _buildMaterialNameField() {
    return BillFormFieldShell(
      prefixIcon: Icons.inventory_2_outlined,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<domain.MaterialItem>(
          value: widget.selectedMaterial,
          focusNode: widget.materialFocusNode,
          isExpanded: true,
          hint: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Select Material Name',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
          ),
          items: widget.materials.map((m) {
            return DropdownMenuItem<domain.MaterialItem>(
              value: m,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  m.name,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (m) {
            if (m != null) widget.onMaterialChanged(m);
          },
        ),
      ),
    );
  }

  /// 3. CUSTOMER NAME
  Widget _buildCustomerNameField() {
    // Drift can return fresh Customer instances after a reload. Use the stable
    // primary key for dropdown values, and collapse any repeated IDs so each
    // selectable value occurs exactly once.
    final customersById = <int, Customer>{};
    for (final customer in widget.customers) {
      customersById[customer.id] = customer;
    }
    final customers = customersById.values.toList(growable: false);
    final selectedCustomerId =
        customersById.containsKey(widget.selectedCustomer?.id)
        ? widget.selectedCustomer!.id
        : null;

    return BillFormFieldShell(
      prefixIcon: Icons.person_outline_rounded,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedCustomerId,
          focusNode: widget.customerFocusNode,
          isExpanded: true,
          hint: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Select Customer Name',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
          ),
          items: customers.map((c) {
            return DropdownMenuItem<int>(
              value: c.id,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  c.name,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (customerId) {
            if (customerId == null) return;
            final customer = customersById[customerId];
            if (customer != null) widget.onCustomerChanged(customer);
          },
        ),
      ),
    );
  }

  /// 6. NETT WEIGHT Display
  Widget _buildNettWeightDisplay() {
    final isKg = widget.weightUnit.toLowerCase() == 'kg';
    final String netDisplay = isKg
        ? (widget.netWeightKg > 0 ? widget.netWeightKg.toStringAsFixed(0) : '0')
        : (widget.netWeightKg > 0
              ? (widget.netWeightKg / 1000).toStringAsFixed(3)
              : '0.000');

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
              border: Border(
                right: BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.scale_rounded,
              size: 16.5,
              color: Color(0xFF475569),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                netDisplay,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          Container(
            width: 48,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(5)),
              border: Border(
                left: BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
              ),
            ),
            child: Text(
              isKg ? 'Kg' : 'Ton',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
