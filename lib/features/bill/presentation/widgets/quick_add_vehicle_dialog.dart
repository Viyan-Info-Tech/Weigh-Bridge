import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/text_formatters.dart';
import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import 'quick_add_vehicle_type_dialog.dart';

class QuickAddVehicleDialog extends StatefulWidget {
  final List<VehicleType> vehicleTypes;
  final void Function(String vehicleNumber, int vehicleTypeId) onSave;
  final Future<VehicleType?> Function(
    String name,
    double emptyPrice,
    double loadPrice,
  )
  onAddVehicleType;

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
    required Future<VehicleType?> Function(
      String name,
      double emptyPrice,
      double loadPrice,
    )
    onAddVehicleType,
  }) {
    return showDialog(
      context: context,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
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
  late List<VehicleType> _localVehicleTypes;
  bool _isLoading = false;
  String? _errorMessage;
  bool _typeHasError = false;

  @override
  void initState() {
    super.initState();
    _localVehicleTypes = List.of(widget.vehicleTypes);
  }

  @override
  void didUpdateWidget(covariant QuickAddVehicleDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleTypes != widget.vehicleTypes) {
      _localVehicleTypes = List.of(widget.vehicleTypes);
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_isLoading) return;

    final isFormValid = _formKey.currentState!.validate();
    if (_selectedType == null) {
      setState(() => _typeHasError = true);
      return;
    } else {
      setState(() => _typeHasError = false);
    }

    if (isFormValid) {
      setState(() => _isLoading = true);
      widget.onSave(_numberController.text.trim(), _selectedType!.id);
      Navigator.of(context).pop();
    }
  }

  void _showTypeMenu() async {
    if (_isLoading) return;

    final renderBox =
        _typeDropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final menuWidth = size.width;

    final items = <PopupMenuEntry<String>>[];

    for (final vt in _localVehicleTypes) {
      items.add(
        PopupMenuItem<String>(
          value: 'type_${vt.id}',
          height: 38,
          child: SizedBox(
            width: menuWidth - 32,
            child: Row(
              children: [
                if (_selectedType?.id == vt.id)
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Color(0xFF0D3B82),
                  )
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vt.name,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    items.add(const PopupMenuDivider(height: 1));

    items.add(
      PopupMenuItem<String>(
        value: '__add_type__',
        height: 38,
        child: SizedBox(
          width: menuWidth - 32,
          child: const Row(
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: 16,
                color: Color(0xFF0D3B82),
              ),
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
      ),
    );

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(
          renderBox.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: _typeDropdownKey.currentContext!,
      position: position,
      constraints: BoxConstraints(
        minWidth: renderBox.size.width,
        maxWidth: math.max(renderBox.size.width, 280),
        maxHeight: 350,
      ),
      items: items,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    if (result == '__add_type__') {
      if (mounted) {
        final createdType = await QuickAddVehicleTypeDialog.show(
          context,
          onSave: (name, emptyPrice, loadPrice) async {
            return widget.onAddVehicleType(name, emptyPrice, loadPrice);
          },
        );
        if (createdType != null && mounted) {
          setState(() {
            _localVehicleTypes.add(createdType);
            _selectedType = createdType;
            _typeHasError = false;
          });
        }
      }
    } else if (result != null && result.startsWith('type_')) {
      final id = int.parse(result.substring(5));
      final vt = _localVehicleTypes.firstWhere((v) => v.id == id);
      setState(() {
        _selectedType = vt;
        _typeHasError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F0F172A),
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        size: 20,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add Vehicle',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Add a new vehicle to your master',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12.5,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 16,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Vehicle Number
                _buildLabel('Vehicle Number', isRequired: true),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _numberController,
                  autofocus: true,
                  enabled: !_isLoading,
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    VehicleNumberFormatter(),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: _inputDecoration('e.g., TN31HS8090'),
                  validator: validateVehicleNumber,
                  onFieldSubmitted: (_) => _onSave(),
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Vehicle Type Dropdown
                _buildLabel('Vehicle Type', isRequired: true),
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: _isLoading ? null : _showTypeMenu,
                  key: _typeDropdownKey,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: _typeHasError
                              ? const Color(0xFFE11D48)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: _typeHasError
                              ? const Color(0xFFE11D48)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF0D3B82),
                          width: 1.5,
                        ),
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
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F172A),
                            ),
                          )
                        : Text(
                            'Select vehicle type',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                ),
                if (_typeHasError) ...[
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'Vehicle type is required',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: Color(0xFFE11D48),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 26),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B82),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(
                          0xFF0D3B82,
                        ).withValues(alpha: 0.6),
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Save Vehicle',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
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

  Widget _buildLabel(String text, {required bool isRequired}) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFE11D48)),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 13,
        color: Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0D3B82), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE11D48)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
      ),
    );
  }
}
