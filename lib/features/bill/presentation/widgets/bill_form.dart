import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/text_formatters.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../material/domain/entities/material_item.dart' as domain;

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
  final FocusNode? materialFocusNode;
  final FocusNode? remarksFocusNode;
  final FocusNode? grossWeightFocusNode;
  final FocusNode? tareWeightFocusNode;
  final FocusNode? vehicleChargeFocusNode;
  final FocusNode? paymentModeFocusNode;

  final ValueChanged<Customer> onCustomerChanged;
  final ValueChanged<String> onVehicleNumberChanged;
  final ValueChanged<domain.MaterialItem> onMaterialChanged;
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
    this.materialFocusNode,
    this.remarksFocusNode,
    this.grossWeightFocusNode,
    this.tareWeightFocusNode,
    this.vehicleChargeFocusNode,
    this.paymentModeFocusNode,
    required this.onCustomerChanged,
    required this.onVehicleNumberChanged,
    required this.onMaterialChanged,
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
          ? 'C-${widget.selectedCustomer!.id.toString().padLeft(3, '0')}'
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
          ? 'C-${widget.selectedCustomer!.id.toString().padLeft(3, '0')}'
          : '';
      if (_mobileController.text.isEmpty &&
          widget.selectedCustomer?.mobile != null) {
        _mobileController.text = widget.selectedCustomer!.mobile!;
      }
    }

    if (widget.selectedType != oldWidget.selectedType) {
      _selectedType = widget.selectedType;
    }
    if (widget.grossCapturedAt != null &&
        widget.grossCapturedAt != oldWidget.grossCapturedAt) {
      _grossDate = widget.grossCapturedAt!;
      _grossTime = TimeOfDay.fromDateTime(widget.grossCapturedAt!);
    }
    if (widget.tareCapturedAt != null &&
        widget.tareCapturedAt != oldWidget.tareCapturedAt) {
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
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 980;

              if (isNarrow) {
                return Column(
                  children: [
                    _buildLeftColumn(isGrossEnabled, isTareEnabled),
                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 14),
                    _buildRightColumn(isGrossEnabled, isTareEnabled),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: TRUCK NO, TYPE, CODES, CHARGES, CONTAINER, MOBILE
                  Expanded(
                    flex: 1,
                    child: _buildLeftColumn(isGrossEnabled, isTareEnabled),
                  ),

                  const SizedBox(width: 24),

                  // Elegant Vertical Separator
                  Container(
                    width: 1,
                    height: 335,
                    color: const Color(0xFFF1F5F9),
                  ),

                  const SizedBox(width: 24),

                  // Right Column: SERIAL NO, NAMES, GROSS, TARE, NETT WEIGHT
                  Expanded(
                    flex: 1,
                    child: _buildRightColumn(isGrossEnabled, isTareEnabled),
                  ),
                ],
              );
            },
          ),

          if (widget.weightValidationError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      ),
    );
  }

  /// Left Column Field Rows
  Widget _buildLeftColumn(bool isGrossEnabled, bool isTareEnabled) {
    const labelWidth = 142.0;

    return Column(
      children: [
        _buildRow(
          label: 'TRUCK NO',
          labelWidth: labelWidth,
          child: _buildTruckNoField(),
        ),
        const SizedBox(height: 9),
        _buildRow(
          label: 'TYPE',
          labelWidth: labelWidth,
          child: _buildTypeSelector(),
        ),
        const SizedBox(height: 9),
        _buildRow(
          label: 'MATERIAL CODE',
          labelWidth: labelWidth,
          child: _buildMaterialCodeField(),
        ),
        const SizedBox(height: 9),
        _buildRow(
          label: 'CUSTOMER CODE',
          labelWidth: labelWidth,
          child: _buildCustomerCodeField(),
        ),
        const SizedBox(height: 9),
        _buildRow(
          label: 'CHARGES (₹)',
          labelWidth: labelWidth,
          child: _buildChargesField(),
        ),
        const SizedBox(height: 9),
        _buildRow(
          label: 'CONTAINER NO',
          labelWidth: labelWidth,
          child: _buildContainerNoField(),
        ),
        const SizedBox(height: 9),
        _buildRow(
          label: 'MOBILE NO',
          labelWidth: labelWidth,
          child: _buildMobileNoField(),
        ),
      ],
    );
  }

  /// Right Column Field Rows
  Widget _buildRightColumn(bool isGrossEnabled, bool isTareEnabled) {
    const labelWidth = 142.0;

    return Column(
      children: [
        _buildRow(
          label: 'SERIAL NO',
          labelWidth: labelWidth,
          child: _buildSerialNoDisplay(),
        ),
        const SizedBox(height: 9),
        _buildRow(
          label: 'MATERIAL NAME',
          labelWidth: labelWidth,
          child: _buildMaterialNameField(),
        ),
        const SizedBox(height: 9),
        _buildRow(
          label: 'CUSTOMER NAME',
          labelWidth: labelWidth,
          child: _buildCustomerNameField(),
        ),
        const SizedBox(height: 9),
        _buildRow(
          label: 'GROSS WEIGHT',
          labelWidth: labelWidth,
          child: _buildWeightRowWithDateTime(
            controller: widget.grossWeightController,
            weightKg: widget.grossWeightKg,
            enabled: isGrossEnabled,
            date: _grossDate,
            time: _grossTime,
            onSelectDate: (d) => setState(() => _grossDate = d),
            onSelectTime: (t) => setState(() => _grossTime = t),
            isCaptured: widget.grossWeightKg > 0,
          ),
        ),
        const SizedBox(height: 9),
        _buildRow(
          label: 'TARE WEIGHT',
          labelWidth: labelWidth,
          child: _buildWeightRowWithDateTime(
            controller: widget.tareWeightController,
            weightKg: widget.tareWeightKg,
            enabled: isTareEnabled,
            date: _tareDate,
            time: _tareTime,
            onSelectDate: (d) => setState(() => _tareDate = d),
            onSelectTime: (t) => setState(() => _tareTime = t),
            isCaptured: widget.tareWeightKg > 0,
          ),
        ),
        const SizedBox(height: 9),
        _buildRow(
          label: 'NETT WEIGHT',
          labelWidth: labelWidth,
          child: _buildNettWeightDisplay(),
        ),
      ],
    );
  }

  Widget _buildRow({
    required String label,
    required double labelWidth,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: 0.4,
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  // --- Left Column Field Builders ---

  /// 1. TRUCK NO
  Widget _buildTruckNoField() {
    return _buildFieldShell(
      prefixIcon: Icons.local_shipping_outlined,
      child: TextField(
        key: const Key('bill_vehicle_number_field'),
        controller: widget.vehicleNumberController,
        focusNode: widget.vehicleFocusNode,
        inputFormatters: [VehicleNumberFormatter()],
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
      ),
    );
  }

  /// 2. TYPE Selector (● GROSS   ○ TARE)
  Widget _buildTypeSelector() {
    final currentType = (_selectedType ?? widget.selectedType).toLowerCase();
    final isGross = currentType == 'gross';

    return Row(
      children: [
        Expanded(
          child: _buildTypeOption(
            label: 'GROSS',
            isSelected: isGross,
            onTap: () {
              setState(() => _selectedType = 'Gross');
              widget.onTypeChanged?.call('Gross');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTypeOption(
            label: 'TARE',
            isSelected: !isGross,
            onTap: () {
              setState(() => _selectedType = 'Tare');
              widget.onTypeChanged?.call('Tare');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 38,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEFF6FF)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFCBD5E1),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0D53FC)
                        : const Color(0xFF94A3B8),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0D53FC),
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF0D53FC)
                      : const Color(0xFF334155),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3. MATERIAL CODE
  Widget _buildMaterialCodeField() {
    return _buildFieldShell(
      prefixIcon: Icons.search_rounded,
      suffix: _buildSearchButton(widget.onAddMaterial, 'Search Material Code'),
      child: TextField(
        controller: _materialCodeController,
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

  /// 4. CUSTOMER CODE
  Widget _buildCustomerCodeField() {
    return _buildFieldShell(
      prefixIcon: Icons.domain_rounded,
      suffix: _buildSearchButton(widget.onAddCustomer, 'Search Customer Code'),
      child: TextField(
        controller: _customerCodeController,
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
          hintText: 'Select Customer Code',
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
    return _buildFieldShell(
      prefixText: '₹',
      suffix: Container(
        width: 28,
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _stepCharge(50.0),
                child: const Center(
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 16,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ),
            Container(height: 1, color: const Color(0xFFE2E8F0)),
            Expanded(
              child: InkWell(
                onTap: () => _stepCharge(-50.0),
                child: const Center(
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      child: TextField(
        controller: widget.vehicleChargeController,
        focusNode: widget.vehicleChargeFocusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: widget.onVehicleChargeChanged,
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
    return _buildFieldShell(
      prefixIcon: Icons.view_in_ar_outlined,
      child: TextField(
        controller: widget.remarksController,
        focusNode: widget.remarksFocusNode,
        onChanged: widget.onRemarksChanged,
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
    return _buildFieldShell(
      prefixIcon: Icons.phone_outlined,
      child: TextField(
        controller: _mobileController,
        keyboardType: TextInputType.phone,
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
    return _buildFieldShell(
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
    return _buildFieldShell(
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
    return _buildFieldShell(
      prefixIcon: Icons.person_outline_rounded,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Customer>(
          value: widget.selectedCustomer,
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
          items: widget.customers.map((c) {
            return DropdownMenuItem<Customer>(
              value: c,
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
          onChanged: (c) {
            if (c != null) widget.onCustomerChanged(c);
          },
        ),
      ),
    );
  }

  /// 4 & 5. GROSS / TARE WEIGHT Row with Read-Only Captured Box, Unit, Date & Time pickers
  Widget _buildWeightRowWithDateTime({
    required TextEditingController controller,
    required double weightKg,
    required bool enabled,
    required DateTime date,
    required TimeOfDay time,
    required ValueChanged<DateTime> onSelectDate,
    required ValueChanged<TimeOfDay> onSelectTime,
    bool isCaptured = false,
  }) {
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final timeStr = '$hour:$minute $period';

    final isKg = widget.weightUnit.toLowerCase() == 'kg';
    final String displayWeight;
    if (controller.text.isNotEmpty) {
      displayWeight = controller.text;
    } else if (weightKg > 0) {
      displayWeight = isKg
          ? weightKg.toStringAsFixed(0)
          : (weightKg / 1000).toStringAsFixed(3);
    } else {
      displayWeight = isKg ? '0' : '0.000';
    }

    return Row(
      children: [
        // Read-only captured weight box
        Expanded(
          flex: 6,
          child: Container(
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
                Container(
                  width: 34,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isCaptured
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFE2E8F0),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(5),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.scale_rounded,
                    size: 16,
                    color: isCaptured
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF475569),
                  ),
                ),
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
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Unit label (Kg)
        Text(
          widget.weightUnit.toLowerCase() == 'kg' ? 'Kg' : 'Ton',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),

        const SizedBox(width: 12),

        // Date Label
        const Text(
          'Date',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(width: 6),

        // Date Picker Box
        Expanded(
          flex: 5,
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) onSelectDate(picked);
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5),
                      ),
                      border: Border(
                        right: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      size: 15,
                      color: Color(0xFF475569),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        dateStr,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Time Label
        const Text(
          'Time',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(width: 6),

        // Time Picker Box
        Expanded(
          flex: 4,
          child: InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (picked != null) onSelectTime(picked);
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(5),
                      ),
                      border: Border(
                        right: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.access_time_rounded,
                      size: 15,
                      color: Color(0xFF475569),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        timeStr,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

    return Row(
      children: [
        // Net Value Container
        Expanded(
          flex: 6,
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(5),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.scale_rounded,
                    size: 16,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  netDisplay,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Unit label (Kg)
        Text(
          isKg ? 'Kg' : 'Ton',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),

        const Spacer(flex: 9),
      ],
    );
  }

  // --- Shared Field Decoration Helpers ---

  Widget _buildFieldShell({
    IconData? prefixIcon,
    String? prefixText,
    Widget? suffix,
    Color backgroundColor = Colors.white,
    required Widget child,
  }) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefixIcon != null || prefixText != null)
            Container(
              width: 36,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
                border: Border(
                  right: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                ),
              ),
              alignment: Alignment.center,
              child: prefixIcon != null
                  ? Icon(prefixIcon, size: 17, color: const Color(0xFF475569))
                  : Text(
                      prefixText!,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF475569),
                      ),
                    ),
            ),
          Expanded(child: child),
          ?suffix,
        ],
      ),
    );
  }

  Widget _buildSearchButton(Future<void> Function()? onTap, String tooltip) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
          ),
          child: const Icon(
            Icons.search_rounded,
            size: 16,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }
}
