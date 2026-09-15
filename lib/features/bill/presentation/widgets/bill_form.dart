import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';

import '../../../party/domain/entities/party.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import '../../../material/domain/entities/material_item.dart' as domain;
import 'searchable_dropdown.dart';

class BillForm extends StatefulWidget {
  final String billNumber;
  final List<Party> parties;
  final List<Vehicle> vehicles;
  final List<domain.MaterialItem> materials;
  final Party? selectedParty;
  final Vehicle? selectedVehicle;
  final VehicleType? selectedVehicleType;
  final domain.MaterialItem? selectedMaterial;
  final String paymentMode;
  final bool isEditing;
  final String? editingFirstWeightType;
  final TextEditingController grossWeightController;
  final TextEditingController tareWeightController;
  final TextEditingController remarksController;
  final TextEditingController? vehicleChargeController;
  final double netWeightKg;
  final double vehicleCharge;
  final double defaultVehicleCharge;
  final bool isVehicleChargeManuallyEdited;
  final double amount;
  final String weightUnit;
  final String? weightValidationError;
  final bool isReady;

  final FocusNode? partyFocusNode;
  final FocusNode? vehicleFocusNode;
  final FocusNode? materialFocusNode;
  final FocusNode? remarksFocusNode;
  final FocusNode? grossWeightFocusNode;
  final FocusNode? tareWeightFocusNode;
  final FocusNode? vehicleChargeFocusNode;
  final FocusNode? paymentModeFocusNode;

  final ValueChanged<Party> onPartyChanged;
  final ValueChanged<Vehicle> onVehicleChanged;
  final ValueChanged<domain.MaterialItem> onMaterialChanged;
  final ValueChanged<String> onGrossWeightChanged;
  final ValueChanged<String> onTareWeightChanged;
  final ValueChanged<String> onRemarksChanged;
  final ValueChanged<String> onPaymentModeChanged;
  final ValueChanged<String>? onWeightUnitChanged;
  final ValueChanged<String> onVehicleChargeChanged;
  final VoidCallback onResetVehicleCharge;
  final Future<void> Function()? onAddParty;
  final VoidCallback? onAddVehicle;
  final Future<void> Function()? onAddMaterial;

  const BillForm({
    super.key,
    required this.billNumber,
    required this.parties,
    required this.vehicles,
    required this.materials,
    this.selectedParty,
    this.selectedVehicle,
    this.selectedVehicleType,
    this.selectedMaterial,
    required this.paymentMode,
    this.isEditing = false,
    this.editingFirstWeightType,
    required this.grossWeightController,
    required this.tareWeightController,
    required this.remarksController,
    this.vehicleChargeController,
    required this.netWeightKg,
    required this.vehicleCharge,
    this.defaultVehicleCharge = 0,
    this.isVehicleChargeManuallyEdited = false,
    required this.amount,
    this.weightUnit = 'kg',
    this.weightValidationError,
    this.isReady = true,
    this.partyFocusNode,
    this.vehicleFocusNode,
    this.materialFocusNode,
    this.remarksFocusNode,
    this.grossWeightFocusNode,
    this.tareWeightFocusNode,
    this.vehicleChargeFocusNode,
    this.paymentModeFocusNode,
    required this.onPartyChanged,
    required this.onVehicleChanged,
    required this.onMaterialChanged,
    required this.onGrossWeightChanged,
    required this.onTareWeightChanged,
    required this.onRemarksChanged,
    required this.onPaymentModeChanged,
    this.onWeightUnitChanged,
    required this.onVehicleChargeChanged,
    required this.onResetVehicleCharge,
    this.onAddParty,
    this.onAddVehicle,
    this.onAddMaterial,
  });

  @override
  State<BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  TextEditingController? _internalVehicleChargeController;

  TextEditingController get _effectiveVehicleChargeController =>
      widget.vehicleChargeController ??
      (_internalVehicleChargeController ??= TextEditingController(
        text: _formatCharge(widget.vehicleCharge),
      ));

  static String _formatCharge(double charge) {
    if (charge <= 0) return '';
    return charge % 1 == 0
        ? charge.toStringAsFixed(0)
        : charge.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    if (widget.vehicleChargeController != null &&
        widget.vehicleChargeController!.text.isEmpty &&
        widget.vehicleCharge > 0) {
      widget.vehicleChargeController!.text = _formatCharge(
        widget.vehicleCharge,
      );
    }
  }

  @override
  void didUpdateWidget(covariant BillForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.vehicleChargeController != oldWidget.vehicleChargeController) {
      _internalVehicleChargeController?.dispose();
      _internalVehicleChargeController = null;
    }

    final controller = _effectiveVehicleChargeController;

    // In auto mode, or when bill number changes, sync controller text from state.
    // While user is manually editing (isVehicleChargeManuallyEdited == true and same bill),
    // do NOT touch the controller so focus and cursor remain intact.
    if (!widget.isVehicleChargeManuallyEdited ||
        widget.billNumber != oldWidget.billNumber) {
      final text = _formatCharge(widget.vehicleCharge);
      if (controller.text != text) {
        controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    _internalVehicleChargeController?.dispose();
    super.dispose();
  }

  bool get isEditing => widget.isEditing;
  List<Party> get parties => widget.parties;
  Party? get selectedParty => widget.selectedParty;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final formWidth = constraints.maxWidth;
        final isCompact = formWidth < 480;
        final isWeightCompact = formWidth < 440;
        final isHeaderCompact = formWidth < 400;

        final bool isGrossEnabled =
            widget.isReady &&
            (!widget.isEditing ||
                widget.editingFirstWeightType?.toUpperCase() == 'TARE');
        final bool isTareEnabled =
            widget.isReady &&
            (!widget.isEditing ||
                widget.editingFirstWeightType?.toUpperCase() == 'GROSS');
        final isKg = widget.weightUnit.toLowerCase() == 'kg';
        final netWeightDisplay =
            widget.weightValidationError != null || widget.netWeightKg <= 0
            ? '—'
            : (isKg
                  ? '${widget.netWeightKg.toStringAsFixed(0)} kg'
                  : '${(widget.netWeightKg / 1000).toStringAsFixed(3)} ton');

        return Container(
          padding: EdgeInsets.all(formWidth < 500 ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Bill Number Badge + Payment Mode + Weight Unit
              if (isHeaderCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBillNumberBadge(),
                    const SizedBox(height: 12),
                    _buildPaymentModeDropdown(),
                    const SizedBox(height: 12),
                    _buildWeightUnitDropdown(),
                  ],
                )
              else
                Row(
                  children: [
                    _buildBillNumberBadge(),
                    const SizedBox(width: 16),
                    Expanded(child: _buildPaymentModeDropdown()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildWeightUnitDropdown()),
                  ],
                ),
              const SizedBox(height: 20),

              // Row 2: Party & Vehicle
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPartyDropdown(),
                    const SizedBox(height: 14),
                    _buildVehicleDropdown(),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: _buildPartyDropdown()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildVehicleDropdown()),
                  ],
                ),
              const SizedBox(height: 16),

              // Row 3: Vehicle Type & Material
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildVehicleTypeDisplay(),
                    const SizedBox(height: 14),
                    _buildMaterialDropdown(),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(child: _buildVehicleTypeDisplay()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMaterialDropdown()),
                  ],
                ),
              const SizedBox(height: 16),

              // Row 4: Remarks
              _buildRemarksField(isGrossEnabled, isTareEnabled),
              const SizedBox(height: 20),

              // Row 5: Gross & Tare Weight
              if (isWeightCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProminentWeightField(
                      'Gross Weight (${widget.weightUnit}) *',
                      widget.grossWeightController,
                      widget.onGrossWeightChanged,
                      enabled: isGrossEnabled,
                      focusNode: widget.grossWeightFocusNode,
                      nextFocusNode: isTareEnabled
                          ? widget.tareWeightFocusNode
                          : widget.vehicleChargeFocusNode,
                    ),
                    const SizedBox(height: 14),
                    _buildProminentWeightField(
                      'Tare Weight (${widget.weightUnit}) *',
                      widget.tareWeightController,
                      widget.onTareWeightChanged,
                      enabled: isTareEnabled,
                      focusNode: widget.tareWeightFocusNode,
                      nextFocusNode: widget.vehicleChargeFocusNode,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildProminentWeightField(
                        'Gross Weight (${widget.weightUnit}) *',
                        widget.grossWeightController,
                        widget.onGrossWeightChanged,
                        enabled: isGrossEnabled,
                        focusNode: widget.grossWeightFocusNode,
                        nextFocusNode: isTareEnabled
                            ? widget.tareWeightFocusNode
                            : widget.vehicleChargeFocusNode,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProminentWeightField(
                        'Tare Weight (${widget.weightUnit}) *',
                        widget.tareWeightController,
                        widget.onTareWeightChanged,
                        enabled: isTareEnabled,
                        focusNode: widget.tareWeightFocusNode,
                        nextFocusNode: widget.vehicleChargeFocusNode,
                      ),
                    ),
                  ],
                ),
              if (widget.weightValidationError != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.weightValidationError!,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Row 6: Net Weight & Vehicle Charge
              if (isWeightCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAutoField(
                      'Net Weight (${widget.weightUnit})',
                      netWeightDisplay,
                    ),
                    const SizedBox(height: 14),
                    _buildVehicleChargeField(),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildAutoField(
                        'Net Weight (${widget.weightUnit})',
                        netWeightDisplay,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildVehicleChargeField()),
                  ],
                ),
              const SizedBox(height: 16),

              // Row 7: Amount
              if (isCompact)
                _buildAutoField(
                  'Amount (₹)',
                  '₹${widget.amount.toStringAsFixed(2)}',
                  showBadge: false,
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildAutoField(
                        'Amount (₹)',
                        '₹${widget.amount.toStringAsFixed(2)}',
                        showBadge: false,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBillNumberBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF0D3B82).withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        'Bill #${widget.billNumber}',
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0D3B82),
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildPaymentModeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Mode',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey('payment_${widget.paymentMode}'),
          focusNode: widget.paymentModeFocusNode,
          initialValue: widget.paymentMode,
          isExpanded: true,
          isDense: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF0D3B82),
                width: 2.0,
              ),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Cash',
              child: Text('Cash', overflow: TextOverflow.ellipsis),
            ),
            DropdownMenuItem(
              value: 'Credit',
              child: Text('Credit', overflow: TextOverflow.ellipsis),
            ),
            DropdownMenuItem(
              value: 'UPI',
              child: Text('UPI', overflow: TextOverflow.ellipsis),
            ),
          ],
          onChanged: (value) {
            if (value != null) widget.onPaymentModeChanged(value);
          },
        ),
      ],
    );
  }

  Widget _buildWeightUnitDropdown() {
    final isLocked = widget.isEditing || !widget.isReady;
    final currentUnit = widget.weightUnit.toLowerCase() == 'ton' ? 'ton' : 'kg';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Weight Unit',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            if (isLocked) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: Colors.grey.shade500,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Focus(
          canRequestFocus: false,
          skipTraversal: true,
          child: DropdownButtonFormField<String>(
            key: ValueKey('weight_unit_${currentUnit}_$isLocked'),
            focusNode: FocusNode(canRequestFocus: false, skipTraversal: true),
            initialValue: currentUnit,
            isExpanded: true,
            isDense: true,
            decoration: InputDecoration(
              fillColor: isLocked ? const Color(0xFFF8FAFC) : Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0D3B82)),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'kg',
                child: Text('Kilogram (kg)', overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem(
                value: 'ton',
                child: Text('Tonne (ton)', overflow: TextOverflow.ellipsis),
              ),
            ],
            onChanged: isLocked
                ? null
                : (value) {
                    if (value != null && widget.onWeightUnitChanged != null) {
                      widget.onWeightUnitChanged!(value);
                    }
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildPartyDropdown() {
    return SearchableDropdown<Party>(
      label: 'Party Name',
      isRequired: true,
      items: widget.parties,
      selectedItem: widget.selectedParty,
      itemLabel: (p) => p.name,
      hintText: 'Select or type party...',
      addNewLabel: 'Add Party',
      onAddNew: widget.onAddParty != null ? () => widget.onAddParty!() : null,
      enabled: !widget.isEditing,
      focusNode: widget.partyFocusNode,
      nextFocusNode: widget.vehicleFocusNode,
      onChanged: widget.onPartyChanged,
    );
  }

  Widget _buildVehicleDropdown() {
    return SearchableDropdown<Vehicle>(
      label: 'Vehicle Number',
      isRequired: true,
      items: widget.vehicles,
      selectedItem: widget.selectedVehicle,
      itemLabel: (v) => v.vehicleNumber,
      hintText: 'Select or type vehicle...',
      addNewLabel: 'Add Vehicle',
      onAddNew: widget.onAddVehicle != null
          ? () => widget.onAddVehicle!()
          : null,
      enabled: !widget.isEditing,
      focusNode: widget.vehicleFocusNode,
      nextFocusNode: widget.materialFocusNode,
      onChanged: widget.onVehicleChanged,
    );
  }

  Widget _buildVehicleTypeDisplay() {
    final typeName = widget.selectedVehicleType?.name ?? '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Type',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Tooltip(
            message: typeName,
            waitDuration: const Duration(milliseconds: 500),
            child: Text(
              typeName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: widget.selectedVehicleType != null
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: widget.selectedVehicleType != null
                    ? const Color(0xFF0F172A)
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialDropdown() {
    return SearchableDropdown<domain.MaterialItem>(
      label: 'Material Type',
      isRequired: true,
      items: widget.materials,
      selectedItem: widget.selectedMaterial,
      itemLabel: (m) => m.name,
      hintText: 'Select or type material...',
      addNewLabel: 'Add Material',
      onAddNew: widget.onAddMaterial != null
          ? () => widget.onAddMaterial!()
          : null,
      enabled: !widget.isEditing,
      focusNode: widget.materialFocusNode,
      nextFocusNode: widget.remarksFocusNode,
      onChanged: widget.onMaterialChanged,
    );
  }

  Widget _buildProminentWeightField(
    String label,
    TextEditingController controller,
    ValueChanged<String> onChanged, {
    bool enabled = true,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            nextFocusNode?.requestFocus();
          },
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
          ],
          onChanged: onChanged,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '0.000',
            hintStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              color: Colors.grey.shade300,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D3B82), width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoField(String label, String value, {bool showBadge = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            if (showBadge) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'Auto',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleChargeField() {
    final isManual = widget.isVehicleChargeManuallyEdited;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Vehicle Charge',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: isManual
                  ? 'Manual charge override. Tap reset to restore auto calculation.'
                  : 'Auto-calculated from vehicle type. Type here to manually override.',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isManual
                      ? const Color(0xFF7C3AED).withValues(alpha: 0.1)
                      : const Color(0xFF16A34A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  isManual ? 'Manual' : 'Auto',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isManual
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF16A34A),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _effectiveVehicleChargeController,
          focusNode: widget.vehicleChargeFocusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            widget.paymentModeFocusNode?.requestFocus();
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          onChanged: widget.onVehicleChargeChanged,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              color: Colors.grey.shade300,
            ),
            prefixText: '\u20B9',
            prefixStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
            suffixIcon: isManual
                ? IconButton(
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    color: const Color(0xFF7C3AED),
                    visualDensity: VisualDensity.compact,
                    tooltip:
                        'Reset to default (\u20B9${_formatCharge(widget.defaultVehicleCharge)})',
                    onPressed: () {
                      widget.onResetVehicleCharge();
                      _effectiveVehicleChargeController.text = _formatCharge(
                        widget.defaultVehicleCharge,
                      );
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0D3B82), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksField(bool isGrossEnabled, bool isTareEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remarks',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.remarksController,
          focusNode: widget.remarksFocusNode,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            if (isGrossEnabled) {
              widget.grossWeightFocusNode?.requestFocus();
            } else if (isTareEnabled) {
              widget.tareWeightFocusNode?.requestFocus();
            } else {
              widget.vehicleChargeFocusNode?.requestFocus();
            }
          },
          onChanged: widget.onRemarksChanged,
          enabled: !widget.isEditing,
          maxLines: 1,
          style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Optional remarks',
            hintStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF0D3B82),
                width: 2.0,
              ),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
