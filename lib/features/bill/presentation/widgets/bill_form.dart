import 'package:flutter/material.dart' hide Material;
import 'package:flutter/services.dart';

import '../../../party/domain/entities/party.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import '../../../material/domain/entities/material_item.dart' as domain;

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
  final TextEditingController grossWeightController;
  final TextEditingController tareWeightController;
  final TextEditingController remarksController;
  final double netWeightKg;
  final double vehicleCharge;
  final double defaultVehicleCharge;
  final bool isVehicleChargeManuallyEdited;
  final double amount;
  final String weightUnit;
  final String? weightValidationError;

  final ValueChanged<Party> onPartyChanged;
  final ValueChanged<Vehicle> onVehicleChanged;
  final ValueChanged<domain.MaterialItem> onMaterialChanged;
  final ValueChanged<String> onGrossWeightChanged;
  final ValueChanged<String> onTareWeightChanged;
  final ValueChanged<String> onRemarksChanged;
  final ValueChanged<String> onPaymentModeChanged;
  final ValueChanged<String> onVehicleChargeChanged;
  final VoidCallback onResetVehicleCharge;
  final VoidCallback? onAddParty;
  final VoidCallback? onAddVehicle;
  final VoidCallback? onAddMaterial;

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
    required this.grossWeightController,
    required this.tareWeightController,
    required this.remarksController,
    required this.netWeightKg,
    required this.vehicleCharge,
    this.defaultVehicleCharge = 0,
    this.isVehicleChargeManuallyEdited = false,
    required this.amount,
    this.weightUnit = 'kg',
    this.weightValidationError,
    required this.onPartyChanged,
    required this.onVehicleChanged,
    required this.onMaterialChanged,
    required this.onGrossWeightChanged,
    required this.onTareWeightChanged,
    required this.onRemarksChanged,
    required this.onPaymentModeChanged,
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
  final GlobalKey _dropdownKey = GlobalKey();
  final GlobalKey _vehicleDropdownKey = GlobalKey();
  final GlobalKey _materialDropdownKey = GlobalKey();

  bool get isEditing => widget.isEditing;
  List<Party> get parties => widget.parties;
  Party? get selectedParty => widget.selectedParty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBillNumberBadge(),
              const SizedBox(width: 16),
              Expanded(child: _buildPaymentModeDropdown()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildPartyDropdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildVehicleDropdown()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildVehicleTypeDisplay()),
              const SizedBox(width: 16),
              Expanded(child: _buildMaterialDropdown()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildRemarksField()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildProminentWeightField(
                  'Gross Weight (${widget.weightUnit}) *', widget.grossWeightController, widget.onGrossWeightChanged, enabled: !widget.isEditing)),
              const SizedBox(width: 16),
              Expanded(child: _buildProminentWeightField(
                  'Tare Weight (${widget.weightUnit}) *', widget.tareWeightController, widget.onTareWeightChanged)),
            ],
          ),
          if (widget.weightValidationError != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
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
          Row(
            children: [
              Expanded(child: _buildAutoField(
                  'Net Weight (${widget.weightUnit})',
                  widget.weightValidationError != null ? '—' : '${widget.netWeightKg.toStringAsFixed(0)} ${widget.weightUnit}')),
              const SizedBox(width: 16),
              Expanded(child: _buildVehicleChargeField()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAutoField(
                  'Amount (₹)', '₹${widget.amount.toStringAsFixed(2)}', showBadge: false)),
              const Spacer(),
            ],
          ),
        ],
      ),
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
          initialValue: widget.paymentMode,
          isExpanded: true,
          isDense: true,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              borderSide: const BorderSide(color: Color(0xFF0D3B82)),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'Cash', child: Text('Cash', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: 'Credit', child: Text('Credit', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: 'UPI', child: Text('UPI', overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (value) {
            if (value != null) widget.onPaymentModeChanged(value);
          },
        ),
      ],
    );
  }

  Widget _buildPartyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Party Name *',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: widget.isEditing ? null : _showPartyMenu,
          key: _dropdownKey,
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                borderSide: const BorderSide(color: Color(0xFF0D3B82)),
              ),
              hintText: 'Select party',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
              suffixIcon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: widget.isEditing ? Colors.grey.shade300 : Colors.grey.shade600,
                size: 20,
              ),
            ),
            child: widget.selectedParty != null
                ? Text(
                    widget.selectedParty!.name,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    'Select party',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showPartyMenu() async {
    final renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final menuWidth = size.width;

    final items = <PopupMenuEntry<String>>[];

    for (final party in widget.parties) {
      items.add(PopupMenuItem<String>(
        value: 'party_${party.id}',
        height: 36,
        child: SizedBox(
          width: menuWidth - 32,
          child: Row(
            children: [
              if (widget.selectedParty?.id == party.id)
                const Icon(Icons.check, size: 16, color: Color(0xFF0D3B82))
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  party.name,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ));
    }

    items.add(const PopupMenuDivider(height: 1));

    items.add(PopupMenuItem<String>(
      value: '__add_party__',
      height: 36,
      child: SizedBox(
        width: menuWidth - 32,
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, size: 16, color: Color(0xFF0D3B82)),
            SizedBox(width: 8),
            Text(
              'Add Party',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D3B82),
              ),
            ),
          ],
        ),
      ),
    ));

    final result = await showMenu<String>(
      context: _dropdownKey.currentContext!,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height + 300,
      ),
      items: items,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    if (result == '__add_party__') {
      widget.onAddParty?.call();
    } else if (result != null && result.startsWith('party_')) {
      final id = int.parse(result.substring(6));
      final party = widget.parties.firstWhere((p) => p.id == id);
      widget.onPartyChanged(party);
    }
  }

  Widget _buildVehicleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Number *',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: widget.isEditing ? null : _showVehicleMenu,
          key: _vehicleDropdownKey,
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                borderSide: const BorderSide(color: Color(0xFF0D3B82)),
              ),
              hintText: 'Select vehicle',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
              suffixIcon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: widget.isEditing ? Colors.grey.shade300 : Colors.grey.shade600,
                size: 20,
              ),
            ),
            child: widget.selectedVehicle != null
                ? Text(
                    widget.selectedVehicle!.vehicleNumber,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    'Select vehicle',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showVehicleMenu() async {
    final renderBox = _vehicleDropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final menuWidth = size.width;

    final items = <PopupMenuEntry<String>>[];

    for (final vehicle in widget.vehicles) {
      items.add(PopupMenuItem<String>(
        value: 'vehicle_${vehicle.id}',
        height: 36,
        child: SizedBox(
          width: menuWidth - 32,
          child: Row(
            children: [
              if (widget.selectedVehicle?.id == vehicle.id)
                const Icon(Icons.check, size: 16, color: Color(0xFF0D3B82))
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vehicle.vehicleNumber,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ));
    }

    items.add(const PopupMenuDivider(height: 1));

    items.add(PopupMenuItem<String>(
      value: '__add_vehicle__',
      height: 36,
      child: SizedBox(
        width: menuWidth - 32,
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, size: 16, color: Color(0xFF0D3B82)),
            SizedBox(width: 8),
            Text(
              'Add Vehicle',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D3B82),
              ),
            ),
          ],
        ),
      ),
    ));

    final result = await showMenu<String>(
      context: _vehicleDropdownKey.currentContext!,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height + 300,
      ),
      items: items,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    if (result == '__add_vehicle__') {
      widget.onAddVehicle?.call();
    } else if (result != null && result.startsWith('vehicle_')) {
      final id = int.parse(result.substring(8));
      final vehicle = widget.vehicles.firstWhere((v) => v.id == id);
      widget.onVehicleChanged(vehicle);
    }
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
          child: Text(
            typeName,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: widget.selectedVehicleType != null ? FontWeight.w600 : FontWeight.w400,
              color: widget.selectedVehicleType != null
                  ? const Color(0xFF0F172A)
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material Type *',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: widget.isEditing ? null : _showMaterialMenu,
          key: _materialDropdownKey,
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                borderSide: const BorderSide(color: Color(0xFF0D3B82)),
              ),
              hintText: 'Select material',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
              suffixIcon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: widget.isEditing ? Colors.grey.shade300 : Colors.grey.shade600,
                size: 20,
              ),
            ),
            child: widget.selectedMaterial != null
                ? Text(
                    widget.selectedMaterial!.name,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    'Select material',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showMaterialMenu() async {
    final renderBox = _materialDropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final menuWidth = size.width;

    final items = <PopupMenuEntry<String>>[];

    for (final material in widget.materials) {
      items.add(PopupMenuItem<String>(
        value: 'material_${material.id}',
        height: 36,
        child: SizedBox(
          width: menuWidth - 32,
          child: Row(
            children: [
              if (widget.selectedMaterial?.id == material.id)
                const Icon(Icons.check, size: 16, color: Color(0xFF0D3B82))
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  material.name,
                  style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ));
    }

    items.add(const PopupMenuDivider(height: 1));

    items.add(PopupMenuItem<String>(
      value: '__add_material__',
      height: 36,
      child: SizedBox(
        width: menuWidth - 32,
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, size: 16, color: Color(0xFF0D3B82)),
            SizedBox(width: 8),
            Text(
              'Add Material',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D3B82),
              ),
            ),
          ],
        ),
      ),
    ));

    final result = await showMenu<String>(
      context: _materialDropdownKey.currentContext!,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height + 300,
      ),
      items: items,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    if (result == '__add_material__') {
      widget.onAddMaterial?.call();
    } else if (result != null && result.startsWith('material_')) {
      final id = int.parse(result.substring(9));
      final material = widget.materials.firstWhere((m) => m.id == id);
      widget.onMaterialChanged(material);
    }
  }

  Widget _buildProminentWeightField(
      String label, TextEditingController controller, ValueChanged<String> onChanged, {bool enabled = true}) {
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
          enabled: enabled,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF0D3B82), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
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
            Container(
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
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: widget.vehicleCharge > 0
              ? widget.vehicleCharge.toStringAsFixed(0)
              : '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    tooltip: 'Reset to default (\u20B9${widget.defaultVehicleCharge.toStringAsFixed(0)})',
                    onPressed: widget.onResetVehicleCharge,
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF0D3B82), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksField() {
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
          onChanged: widget.onRemarksChanged,
          enabled: !widget.isEditing,
          maxLines: 1,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: 'Optional remarks',
            hintStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              borderSide:
                  const BorderSide(color: Color(0xFF0D3B82)),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
