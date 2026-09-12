import 'package:flutter/material.dart';

import '../../../vehicle_type/domain/entities/vehicle_type.dart';

class QuickAddVehicleTypeDialog extends StatefulWidget {
  final Future<VehicleType?> Function(String name, double emptyPrice, double loadPrice) onSave;

  const QuickAddVehicleTypeDialog({super.key, required this.onSave});

  static Future<VehicleType?> show(BuildContext context, {required Future<VehicleType?> Function(String name, double emptyPrice, double loadPrice) onSave}) {
    return showDialog<VehicleType?>(
      context: context,
      builder: (_) => QuickAddVehicleTypeDialog(onSave: onSave),
    );
  }

  @override
  State<QuickAddVehicleTypeDialog> createState() => _QuickAddVehicleTypeDialogState();
}

class _QuickAddVehicleTypeDialogState extends State<QuickAddVehicleTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emptyPriceController = TextEditingController();
  final _loadPriceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emptyPriceController.dispose();
    _loadPriceController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      final emptyPrice = double.tryParse(_emptyPriceController.text) ?? 0;
      final loadPrice = double.tryParse(_loadPriceController.text) ?? 0;
      final createdType = await widget.onSave(_nameController.text.trim(), emptyPrice, loadPrice);
      if (mounted) {
        Navigator.of(context).pop(createdType);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 400,
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
                      child: const Icon(Icons.category_outlined, size: 18, color: Color(0xFF0D3B82)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Vehicle Type',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Add a new vehicle type to your master',
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
                _buildLabel('Name *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13),
                  decoration: _inputDecoration('e.g., Truck'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  onFieldSubmitted: (_) => _onSave(),
                ),
                const SizedBox(height: 16),
                _buildLabel('Empty Price'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emptyPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13),
                  decoration: _inputDecoration('₹ 0.00'),
                  onFieldSubmitted: (_) => _onSave(),
                ),
                const SizedBox(height: 16),
                _buildLabel('Load Price'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _loadPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13),
                  decoration: _inputDecoration('₹ 0.00'),
                  onFieldSubmitted: (_) => _onSave(),
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
                        'Save Type',
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
