import 'package:flutter/material.dart';

import '../../../../core/utils/text_formatters.dart';
import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import 'quick_add_vehicle_type_dialog.dart';

class QuickAddVehicleDialog extends StatefulWidget {
  final List<VehicleType> vehicleTypes;
  final void Function(String vehicleNumber, int vehicleTypeId) onSave;
  final void Function(String name, double emptyPrice, double loadPrice) onAddVehicleType;

  const QuickAddVehicleDialog({
    super.key,
    required this.vehicleTypes,
    required this.onSave,
    required this.onAddVehicleType,
  });

  static Future<void> show({
    required BuildContext context,
    required List<VehicleType> vehicleTypes,
    required void Function(String vehicleNumber, int vehicleTypeId) onSave,
    required void Function(String name, double emptyPrice, double loadPrice) onAddVehicleType,
  }) {
    return showDialog(
      context: context,
      builder: (_) => QuickAddVehicleDialog(
        vehicleTypes: vehicleTypes,
        onSave: onSave,
        onAddVehicleType: onAddVehicleType,
      ),
    );
  }

  @override
  State<QuickAddVehicleDialog> createState() => _QuickAddVehicleDialogState();
}

class _QuickAddVehicleDialogState extends State<QuickAddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  VehicleType? _selectedType;
  final GlobalKey _typeDropdownKey = GlobalKey();

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate() && _selectedType != null) {
      widget.onSave(_numberController.text.trim(), _selectedType!.id);
      Navigator.of(context).pop();
    }
  }

  void _showTypeMenu() async {
    final renderBox = _typeDropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final menuWidth = size.width;

    final items = <PopupMenuEntry<String>>[];

    for (final vt in widget.vehicleTypes) {
      items.add(PopupMenuItem<String>(
        value: 'type_${vt.id}',
        height: 36,
        child: SizedBox(
          width: menuWidth - 32,
          child: Row(
            children: [
              if (_selectedType?.id == vt.id)
                const Icon(Icons.check, size: 16, color: Color(0xFF0D3B82))
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vt.name,
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
      value: '__add_type__',
      height: 36,
      child: SizedBox(
        width: menuWidth - 32,
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, size: 16, color: Color(0xFF0D3B82)),
            SizedBox(width: 8),
            Text(
              'Add Vehicle Type',
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
      context: _typeDropdownKey.currentContext!,
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

    if (result == '__add_type__') {
      if (mounted) {
        QuickAddVehicleTypeDialog.show(
          context,
          onSave: (name, emptyPrice, loadPrice) {
            widget.onAddVehicleType(name, emptyPrice, loadPrice);
          },
        );
      }
    } else if (result != null && result.startsWith('type_')) {
      final id = int.parse(result.substring(5));
      final vt = widget.vehicleTypes.firstWhere((v) => v.id == id);
      setState(() => _selectedType = vt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 450,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D3B82).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.local_shipping_outlined, size: 18, color: Color(0xFF0D3B82)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Vehicle',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Add a new vehicle to your master',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.grey.shade500,
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildLabel('Vehicle Number *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _numberController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [VehicleNumberFormatter()],
                  style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13),
                  decoration: _inputDecoration('e.g., TN31CM2026'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vehicle number is required' : null,
                  onFieldSubmitted: (_) => _onSave(),
                ),
                const SizedBox(height: 16),
                _buildLabel('Vehicle Type *'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _showTypeMenu,
                  key: _typeDropdownKey,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                      suffixIcon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                    child: _selectedType != null
                        ? Text(
                            _selectedType!.name,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              color: Color(0xFF0F172A),
                            ),
                          )
                        : Text(
                            'Select vehicle type',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B82),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Save Vehicle',
                        style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
