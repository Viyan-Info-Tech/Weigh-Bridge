import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Management screen for the day's common (platform) tare weight.
///
/// Opened by tapping the AUTO TARE status control, and by pressing F3 while no
/// auto tare has been configured for the day yet.
///
/// The value is stored per calendar day, so yesterday's tare never leaks into
/// today. Applying it to a weighment copies the value onto that bill, which
/// keeps historical tickets unchanged when the day's auto tare is replaced
/// later.
class AutoTareDialog extends StatefulWidget {
  const AutoTareDialog({
    super.key,
    required this.currentAutoTareKg,
    required this.liveScaleWeightKg,
    required this.isScaleStable,
    required this.isScaleMotion,
    required this.isScaleOverload,
    required this.weightUnit,
    required this.onSave,
    required this.onDelete,
    this.date,
  });

  /// Stored auto tare for the day being edited; null or 0 means "Not Set".
  final double currentAutoTareKg;

  final double liveScaleWeightKg;
  final bool isScaleStable;
  final bool isScaleMotion;
  final bool isScaleOverload;
  final String weightUnit;
  final DateTime? date;

  /// Persists the value for the day. Receives kilograms.
  final Future<void> Function(double tareKg) onSave;

  /// Removes the day's value.
  final Future<void> Function() onDelete;

  static Future<void> show(
    BuildContext context, {
    required double currentAutoTareKg,
    required double liveScaleWeightKg,
    required bool isScaleStable,
    required bool isScaleMotion,
    required bool isScaleOverload,
    required String weightUnit,
    required Future<void> Function(double tareKg) onSave,
    required Future<void> Function() onDelete,
    DateTime? date,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.50),
      builder: (_) => AutoTareDialog(
        currentAutoTareKg: currentAutoTareKg,
        liveScaleWeightKg: liveScaleWeightKg,
        isScaleStable: isScaleStable,
        isScaleMotion: isScaleMotion,
        isScaleOverload: isScaleOverload,
        weightUnit: weightUnit,
        onSave: onSave,
        onDelete: onDelete,
        date: date,
      ),
    );
  }

  @override
  State<AutoTareDialog> createState() => _AutoTareDialogState();
}

class _AutoTareDialogState extends State<AutoTareDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isBusy = false;
  String? _errorMessage;
  late DateTime _currentTime;
  Timer? _timeTimer;

  bool get _isTon => widget.weightUnit.trim().toLowerCase() == 'ton';

  bool get _hasCurrent =>
      widget.currentAutoTareKg.isFinite && widget.currentAutoTareKg > 0;

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

  @override
  void initState() {
    super.initState();
    final initialKg = _canUseLiveWeight
        ? widget.liveScaleWeightKg
        : (_hasCurrent ? widget.currentAutoTareKg : null);
    _controller = TextEditingController(
      text: initialKg == null ? '' : _formatKg(initialKg),
    );
    _currentTime = DateTime.now();
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  double? _parseToKg() {
    final text = _controller.text.trim().replaceAll(',', '');
    final value = double.tryParse(text);
    if (value == null || !value.isFinite || value <= 0) return null;
    return _isTon ? value * 1000 : value;
  }

  Future<void> _save() async {
    if (_isBusy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final tareKg = _parseToKg()!;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      await widget.onSave(tareKg);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted && _isBusy) setState(() => _isBusy = false);
    }
  }

  Future<void> _delete() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    try {
      await widget.onDelete();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted && _isBusy) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.date ?? DateTime.now();
    final unitLabel = _isTon ? 'Ton' : 'Kg';
    final isReplacing =
        _hasCurrent &&
        _parseToKg() != null &&
        (_parseToKg()! - widget.currentAutoTareKg).abs() > 0.001;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.14),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── HEADER SECTION ─────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(22, 20, 18, 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFF1F5F9),
                          width: 1.2,
                        ),
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
                          child: const Icon(
                            Icons.monitor_weight_rounded,
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
                              const Text(
                                'Enter Auto Tare',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Today's common tare for all weighments",
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Close 'X' Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isBusy
                                ? null
                                : () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20),
                            hoverColor: const Color(0xFFE2E8F0),
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── BODY CONTENT ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Current Auto Tare Banner / Status Card
                        _buildCurrentTareCard(unitLabel),

                        const SizedBox(height: 16),

                        // 2. Tare Weight Input Row Header
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
                                        _controller.text = _formatKg(
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

                        // 3. Weight Input Field
                        TextFormField(
                          key: const Key('auto_tare_weight_field'),
                          controller: _controller,
                          autofocus: true,
                          enabled: !_isBusy,
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
                            prefixIcon: Container(
                              margin: const EdgeInsets.only(
                                left: 12,
                                right: 10,
                              ),
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.scale_rounded,
                                size: 18,
                                color: Color(0xFF475569),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
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
                          onFieldSubmitted: (_) => _save(),
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

                        // 4. Live Scale Sensor Status
                        _buildLiveReadingRow(),

                        const SizedBox(height: 14),

                        // 5. DATE AND CURRENT TIME ROW (Requested Feature!)
                        _buildDateTimeBadge(day),

                        // 6. Replacing Tare Notice Banner
                        if (isReplacing) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: Color(0xFFB45309),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Replacing today's Auto Tare. Previously saved bills will retain their original tare.",
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11.5,
                                      color: Colors.amber.shade900,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // 7. Error Banner
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

                        // ── ACTIONS SECTION ──────────────────────
                        // Row: Delete (if has current) | Clear | Cancel
                        Row(
                          children: [
                            if (_hasCurrent) ...[
                              Expanded(
                                flex: 3,
                                child: OutlinedButton.icon(
                                  key: const Key('auto_tare_delete_button'),
                                  onPressed: _isBusy ? null : _delete,
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Delete'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFDC2626),
                                    disabledForegroundColor: const Color(
                                      0xFFCBD5E1,
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFFFECACA),
                                      width: 1.1,
                                    ),
                                    backgroundColor: const Color(0xFFFEF2F2),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    textStyle: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              flex: 3,
                              child: OutlinedButton.icon(
                                onPressed: _isBusy
                                    ? null
                                    : () => _controller.clear(),
                                icon: const Icon(
                                  Icons.backspace_outlined,
                                  size: 15,
                                ),
                                label: const Text('Clear'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF475569),
                                  side: const BorderSide(
                                    color: Color(0xFFCBD5E1),
                                    width: 1.1,
                                  ),
                                  backgroundColor: const Color(0xFFF8FAFC),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: OutlinedButton(
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
                                    vertical: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Primary Button: Update / Save Auto Tare
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            key: const Key('auto_tare_save_button'),
                            onPressed: _isBusy ? null : _save,
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _hasCurrent
                                            ? 'Update Auto Tare'
                                            : 'Save Auto Tare',
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 1. Current Auto Tare Banner
  Widget _buildCurrentTareCard(String unitLabel) {
    if (_hasCurrent) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF86EFAC), width: 1.1),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CURRENT AUTO TARE',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    "Active for today's weighments",
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatKg(widget.currentAutoTareKg),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unitLabel,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CURRENT AUTO TARE',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'No tare configured for today yet',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'Not Set',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Live Scale Sensor Reading Indicator
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

  /// 5. Date & LIVE CURRENT TIME Display
  Widget _buildDateTimeBadge(DateTime day) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Calendar Icon + Date
          const Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: Color(0xFF0284C7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              DateFormat('EEEE, d MMMM yyyy').format(day),
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Vertical divider
          Container(
            height: 16,
            width: 1.2,
            color: const Color(0xFFCBD5E1),
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),

          // Clock Icon + Live Ticking Current Time
          const Icon(
            Icons.access_time_filled_rounded,
            size: 14.5,
            color: Color(0xFF059669),
          ),
          const SizedBox(width: 7),
          Text(
            DateFormat('hh:mm:ss a').format(_currentTime),
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
