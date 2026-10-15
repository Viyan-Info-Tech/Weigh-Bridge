import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/text_formatters.dart';
import '../../domain/entities/vehicle_tare_record.dart';

/// Modal popup for adding or editing a single vehicle tare record.
///
/// Displayed as a centered modal over the Auto Tare dialog.
class VehicleTareFormDialog extends StatefulWidget {
  const VehicleTareFormDialog({
    super.key,
    this.record,
    required this.weightUnit,
    required this.liveScaleWeightKg,
    required this.isScaleStable,
    required this.isScaleMotion,
    required this.isScaleOverload,
    required this.onSave,
  });

  /// Existing record to edit, or null when adding a new record.
  final VehicleTareRecord? record;

  final String weightUnit;
  final double liveScaleWeightKg;
  final bool isScaleStable;
  final bool isScaleMotion;
  final bool isScaleOverload;

  /// Callback to persist the record (either add or update).
  final Future<VehicleTareRecord> Function(String vehicleNumber, double tareKg)
  onSave;

  /// Helper to show this dialog centered over the active modal.
  static Future<VehicleTareRecord?> show(
    BuildContext context, {
    VehicleTareRecord? record,
    required String weightUnit,
    required double liveScaleWeightKg,
    required bool isScaleStable,
    required bool isScaleMotion,
    required bool isScaleOverload,
    required Future<VehicleTareRecord> Function(
      String vehicleNumber,
      double tareKg,
    )
    onSave,
  }) {
    return showDialog<VehicleTareRecord>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.50),
      builder: (_) => VehicleTareFormDialog(
        record: record,
        weightUnit: weightUnit,
        liveScaleWeightKg: liveScaleWeightKg,
        isScaleStable: isScaleStable,
        isScaleMotion: isScaleMotion,
        isScaleOverload: isScaleOverload,
        onSave: onSave,
      ),
    );
  }

  @override
  State<VehicleTareFormDialog> createState() => _VehicleTareFormDialogState();
}

class _VehicleTareFormDialogState extends State<VehicleTareFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _vehicleController;
  late final TextEditingController _weightController;
  late final FocusNode _vehicleFocusNode;
  late final FocusNode _weightFocusNode;
  bool _isBusy = false;
  String? _errorMessage;

  bool get _isEditing => widget.record != null;
  bool get _isTon => widget.weightUnit.trim().toLowerCase() == 'ton';

  bool get _canUseLiveWeight =>
      widget.liveScaleWeightKg.isFinite &&
      widget.liveScaleWeightKg > 0 &&
      widget.isScaleStable &&
      !widget.isScaleMotion &&
      !widget.isScaleOverload;

  String _formatKg(double kg) {
    final value = _isTon ? kg / 1000 : kg;
    return _isTon ? value.toStringAsFixed(3) : value.toStringAsFixed(0);
  }

  double? _parseToKg() {
    final text = _weightController.text.trim().replaceAll(',', '');
    final value = double.tryParse(text);
    if (value == null || !value.isFinite || value <= 0) return null;
    return _isTon ? value * 1000 : value;
  }

  String _normalizedVehicle() => _vehicleController.text.trim().toUpperCase();

  @override
  void initState() {
    super.initState();
    final rec = widget.record;
    _vehicleController = TextEditingController(text: rec?.vehicleNumber ?? '');
    _weightController = TextEditingController(
      text: rec != null ? _formatKg(rec.tareKg) : '',
    );
    _vehicleFocusNode = FocusNode(debugLabel: 'vehicleTareFormVehicleFocusNode');
    _weightFocusNode = FocusNode(debugLabel: 'vehicleTareFormWeightFocusNode');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _vehicleFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    _weightController.dispose();
    _vehicleFocusNode.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isBusy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final vehicleNumber = _normalizedVehicle();
    final tareKg = _parseToKg();
    if (tareKg == null) return;

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final saved = await widget.onSave(vehicleNumber, tareKg);
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted && _isBusy) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitLabel = _isTon ? 'Ton' : 'Kg';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.18),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── HEADER SECTION ─────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Gradient Icon Box
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF16A34A,
                              ).withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isEditing
                              ? Icons.edit_note_rounded
                              : Icons.add_circle_outline_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEditing
                                  ? 'Edit Vehicle Tare'
                                  : 'New Vehicle Tare',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 17.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isEditing
                                  ? 'Update vehicle tare weight record'
                                  : 'Record vehicle tare weight for quick selection',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── FORM BODY ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // VEHICLE NUMBER Label
                        const Text(
                          'VEHICLE NUMBER',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 7),
                        TextFormField(
                          key: const Key('vehicle_tare_vehicle_field'),
                          controller: _vehicleController,
                          focusNode: _vehicleFocusNode,
                          enabled: !_isBusy,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                          ],
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          onFieldSubmitted: (_) {
                            _weightFocusNode.requestFocus();
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter Vehicle Number (e.g. TN 14 L 1112)',
                            hintStyle: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF16A34A),
                                width: 2.0,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFDC2626),
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFDC2626),
                                width: 2.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vehicle number is required';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            if (_errorMessage != null) {
                              setState(() => _errorMessage = null);
                            }
                          },
                        ),

                        const SizedBox(height: 14),

                        // TARE WEIGHT Label + Use Live Weight
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TARE WEIGHT',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: Color(0xFF475569),
                              ),
                            ),
                            if (_canUseLiveWeight)
                              InkWell(
                                onTap: _isBusy
                                    ? null
                                    : () {
                                        _weightController.text = _formatKg(
                                          widget.liveScaleWeightKg,
                                        );
                                        setState(() {});
                                      },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.flash_on_rounded,
                                        size: 13,
                                        color: Color(0xFF059669),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Use Live: ${_formatKg(widget.liveScaleWeightKg)} $unitLabel',
                                        style: const TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF047857),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        TextFormField(
                          key: const Key('auto_tare_weight_field'),
                          controller: _weightController,
                          focusNode: _weightFocusNode,
                          enabled: !_isBusy,
                          textInputAction: TextInputAction.done,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: _canUseLiveWeight
                                ? 'Live scale: ${_formatKg(widget.liveScaleWeightKg)}'
                                : 'Enter tare weight',
                            hintStyle: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              color: Colors.grey.shade400,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  unitLabel,
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(
                              minHeight: 36,
                              minWidth: 40,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF16A34A),
                                width: 2.0,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFDC2626),
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFDC2626),
                                width: 2.0,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (_) => _handleSave(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Tare weight is required';
                            }
                            if (_parseToKg() == null) {
                              return 'Enter a valid tare weight greater than zero';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            setState(() {});
                            if (_errorMessage != null) {
                              setState(() => _errorMessage = null);
                            }
                          },
                        ),

                        const SizedBox(height: 10),
                        _buildLiveReadingRow(),

                        // Error Banner
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFECDD3),
                              ),
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
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ── FOOTER ACTIONS ─────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                key: const Key(
                                  'vehicle_tare_form_cancel_button',
                                ),
                                onPressed: _isBusy
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF64748B),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                    width: 1.1,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  key: const Key('vehicle_tare_save_button'),
                                  onPressed: _isBusy ? null : _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: const Color(
                                      0xFF16A34A,
                                    ).withValues(alpha: 0.6),
                                    disabledForegroundColor: Colors.white70,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                    shadowColor: const Color(
                                      0xFF16A34A,
                                    ).withValues(alpha: 0.4),
                                  ),
                                  child: _isBusy
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.check_rounded,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _isEditing ? 'Save' : 'Save',
                                              style: const TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveReadingRow() {
    final live = widget.liveScaleWeightKg;
    final hasLive = live.isFinite && live > 0;
    final isStable = hasLive && widget.isScaleStable && !widget.isScaleMotion;
    final label = widget.isScaleOverload
        ? 'Scale overload'
        : !hasLive
        ? 'No live reading'
        : widget.isScaleMotion
        ? 'Scale in motion'
        : isStable
        ? 'Live scale ready'
        : 'Scale not stable';

    final Color dotColor;
    final Color textColor;
    final IconData icon;

    if (widget.isScaleOverload) {
      dotColor = const Color(0xFFDC2626);
      textColor = const Color(0xFFDC2626);
      icon = Icons.warning_rounded;
    } else if (isStable) {
      dotColor = const Color(0xFF16A34A);
      textColor = const Color(0xFF15803D);
      icon = Icons.sensors_rounded;
    } else if (hasLive && widget.isScaleMotion) {
      dotColor = const Color(0xFFD97706);
      textColor = const Color(0xFFB45309);
      icon = Icons.sensors_rounded;
    } else {
      dotColor = const Color(0xFF94A3B8);
      textColor = const Color(0xFF64748B);
      icon = Icons.sensors_off_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: dotColor),
          const SizedBox(width: 6),
          Text(
            hasLive
                ? '${_formatKg(live)} ${_isTon ? 'Ton' : 'Kg'}  ·  $label'
                : label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
