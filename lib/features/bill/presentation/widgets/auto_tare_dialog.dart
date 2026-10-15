import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/text_formatters.dart';
import '../../domain/entities/vehicle_tare_record.dart';

/// Vehicle tare registry popup, opened from the AUTO TARE status control
/// and by pressing F3 while no auto tare has been configured.
///
/// The popup lists every stored per-vehicle tare record and offers exactly
/// two actions: [Add] records a new vehicle tare, [Cancel] closes the popup
/// without saving. Adding a record never creates a weighment or a bill; the
/// main-screen F3 apply flow is untouched and keeps working as before.
class AutoTareDialog extends StatefulWidget {
  const AutoTareDialog({
    super.key,
    required this.records,
    required this.liveScaleWeightKg,
    required this.isScaleStable,
    required this.isScaleMotion,
    required this.isScaleOverload,
    required this.weightUnit,
    required this.onAdd,
    required this.onDelete,
    required this.onSelect,
    required this.onUpdate,
    this.recordsStream,
    this.date,
  });

  /// Vehicle tare records known when the popup opens.
  final List<VehicleTareRecord> records;

  /// Optional reactive stream that pushes tare record updates from Drift.
  final Stream<List<VehicleTareRecord>>? recordsStream;

  final double liveScaleWeightKg;
  final bool isScaleStable;
  final bool isScaleMotion;
  final bool isScaleOverload;
  final String weightUnit;
  final DateTime? date;

  /// Persists one vehicle tare record. Receives the normalized vehicle
  /// number and kilograms, resolves with the stored record.
  final Future<VehicleTareRecord> Function(String vehicleNumber, double tareKg)
  onAdd;

  /// Removes the tare record for [vehicleNumber]. Used when an edit renames
  /// a vehicle: the renamed record is saved as new, the old row is removed.
  final Future<void> Function(String vehicleNumber) onDelete;
  final ValueChanged<VehicleTareRecord> onSelect;
  final Future<VehicleTareRecord> Function(
    int id,
    String vehicleNumber,
    double tareKg,
  )
  onUpdate;

  static Future<void> show(
    BuildContext context, {
    required List<VehicleTareRecord> records,
    Stream<List<VehicleTareRecord>>? recordsStream,
    required double liveScaleWeightKg,
    required bool isScaleStable,
    required bool isScaleMotion,
    required bool isScaleOverload,
    required String weightUnit,
    required Future<VehicleTareRecord> Function(
      String vehicleNumber,
      double tareKg,
    )
    onAdd,
    required Future<void> Function(String vehicleNumber) onDelete,
    required ValueChanged<VehicleTareRecord> onSelect,
    required Future<VehicleTareRecord> Function(
      int id,
      String vehicleNumber,
      double tareKg,
    )
    onUpdate,
    DateTime? date,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.50),
      builder: (_) => AutoTareDialog(
        records: records,
        recordsStream: recordsStream,
        liveScaleWeightKg: liveScaleWeightKg,
        isScaleStable: isScaleStable,
        isScaleMotion: isScaleMotion,
        isScaleOverload: isScaleOverload,
        weightUnit: weightUnit,
        onAdd: onAdd,
        onDelete: onDelete,
        onSelect: onSelect,
        onUpdate: onUpdate,
        date: date,
      ),
    );
  }

  @override
  State<AutoTareDialog> createState() => _AutoTareDialogState();
}

class _AutoTareDialogState extends State<AutoTareDialog> {
  late List<VehicleTareRecord> _records;
  late final TextEditingController _vehicleController;
  late final TextEditingController _weightController;
  late final FocusNode _vehicleFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool _isBusy = false;
  bool _showEntryForm = false;

  /// Normalized vehicle number of the selected table row, if any.
  String? _selectedVehicle;

  /// Original vehicle number being edited, or null when adding.
  String? _editingVehicle;

  String? _errorMessage;

  /// Neutral guidance (e.g. "select a record first"); cleared on any action.
  String? _hintMessage;
  late DateTime _currentTime;
  Timer? _timeTimer;
  Timer? _singleTapTimer;
  StreamSubscription<List<VehicleTareRecord>>? _recordsSubscription;

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

  String _formatTableWeight(double kg) {
    final value = _isTon ? kg / 1000 : kg;
    final unitLabel = _isTon ? 'Ton' : 'Kg';
    final number = _isTon
        ? value.toStringAsFixed(3)
        : NumberFormat('#,##0').format(value);
    return '$number $unitLabel';
  }

  static int _sortRecords(VehicleTareRecord a, VehicleTareRecord b) {
    if (a.id != null && b.id != null) {
      return a.id!.compareTo(b.id!);
    }
    return a.vehicleNumber.compareTo(b.vehicleNumber);
  }

  @override
  void initState() {
    super.initState();
    _records = List.of(widget.records)..sort(_sortRecords);
    _recordsSubscription = widget.recordsStream?.listen((updated) {
      if (!mounted) return;
      setState(() {
        _records = List.of(updated)..sort(_sortRecords);
      });
    });
    _vehicleController = TextEditingController();
    _weightController = TextEditingController();
    _vehicleFocusNode = FocusNode(debugLabel: 'vehicleTareVehicleFocusNode');
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
    _recordsSubscription?.cancel();
    _singleTapTimer?.cancel();
    _timeTimer?.cancel();
    _vehicleController.dispose();
    _weightController.dispose();
    _vehicleFocusNode.dispose();
    super.dispose();
  }

  double? _parseToKg() {
    final text = _weightController.text.trim().replaceAll(',', '');
    final value = double.tryParse(text);
    if (value == null || !value.isFinite || value <= 0) return null;
    return _isTon ? value * 1000 : value;
  }

  String _normalizedVehicle() => _vehicleController.text
      .trim()
      .toUpperCase()
      .replaceAll(RegExp(r'\s+'), ' ');

  bool get _isEditing => _editingVehicle != null;

  VehicleTareRecord? _findRecord(String vehicleNumber) {
    for (final record in _records) {
      if (record.vehicleNumber == vehicleNumber) return record;
    }
    return null;
  }

  /// Opens the edit UI for the selected record and prefills its values.
  void _editRecord(VehicleTareRecord record) {
    if (_isBusy) return;
    _singleTapTimer?.cancel();
    _singleTapTimer = null;
    setState(() {
      _showEntryForm = true;
      _editingVehicle = record.vehicleNumber;
      _selectedVehicle = record.vehicleNumber;
      _errorMessage = null;
      _hintMessage = null;
      _vehicleController.text = record.vehicleNumber;
      _weightController.text = _formatKg(record.tareKg);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vehicleFocusNode.requestFocus();
    });
  }

  /// Single-click handler: slightly delayed to allow double-click to cancel it.
  void _onRecordTap(VehicleTareRecord record) {
    if (_isBusy) return;
    setState(() {
      _selectedVehicle = record.vehicleNumber;
    });
    _singleTapTimer?.cancel();
    _singleTapTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      widget.onSelect(record);
    });
  }

  /// Double-click handler: cancels the delayed single click and opens edit UI.
  void _onRecordDoubleTap(VehicleTareRecord record) {
    if (_isBusy) return;
    _singleTapTimer?.cancel();
    _singleTapTimer = null;
    _editRecord(record);
  }

  /// Discards an in-progress edit (or a new-entry draft) without persisting.
  /// Restores the table to its stored values and returns to viewing mode.
  /// The popup stays open so Add continues to work independently.
  void _cancelEditPressed() {
    if (_isBusy) return;
    _singleTapTimer?.cancel();
    _singleTapTimer = null;
    setState(() {
      _showEntryForm = false;
      _editingVehicle = null;
      _errorMessage = null;
      _hintMessage = null;
      _vehicleController.clear();
      _weightController.clear();
    });
  }

  /// The single primary action: reveals the entry form on first tap, then
  /// validates and persists the new vehicle tare record — or the in-progress
  /// edit, when one is active.
  Future<void> _addPressed() async {
    if (_isBusy) return;
    _singleTapTimer?.cancel();
    _singleTapTimer = null;
    if (!_showEntryForm) {
      setState(() {
        _showEntryForm = true;
        _editingVehicle = null;
        _errorMessage = null;
        _hintMessage = null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _vehicleFocusNode.requestFocus();
      });
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final vehicleNumber = _normalizedVehicle();
    final tareKg = _parseToKg()!;
    final editingOriginal = _editingVehicle;
    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _hintMessage = null;
    });

    try {
      final originalRecord = editingOriginal != null
          ? _findRecord(editingOriginal)
          : null;
      final saved = editingOriginal != null
          ? await widget.onUpdate(
              originalRecord?.id ?? 0,
              vehicleNumber,
              tareKg,
            )
          : await widget.onAdd(vehicleNumber, tareKg);
      if (!mounted) return;
      setState(() {
        _records.removeWhere(
          (r) =>
              r.vehicleNumber == saved.vehicleNumber ||
              (editingOriginal != null && r.vehicleNumber == editingOriginal),
        );
        _records.add(saved);
        _records.sort(_sortRecords);
        _showEntryForm = false;
        _editingVehicle = null;
        _selectedVehicle = saved.vehicleNumber;
        _vehicleController.clear();
        _weightController.clear();
      });
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
    final unitLabel = _isTon ? 'Ton' : 'Kg';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
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
                        child: const Icon(
                          Icons.monitor_weight_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Title & Subtitle
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto Tare',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 17.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Vehicle tare weight records',
                              style: TextStyle(
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

                // ── BODY CONTENT ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Date and time badge
                        _buildDateTimeBadge(_currentTime),

                        const SizedBox(height: 14),

                        // 2. Records table
                        _buildRecordsTable(),

                        // 3. Guidance hint (e.g. select a record before Edit)
                        if (_hintMessage != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: Color(0xFF475569),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _hintMessage!,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12,
                                      color: Color(0xFF475569),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // 4. Entry form (revealed by Add, prefilled by Edit)
                        if (_showEntryForm) ...[
                          const SizedBox(height: 16),
                          _buildEntryForm(unitLabel),
                        ],

                        // 4. Error Banner
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

                        // ── FOOTER: Cancel (left) + Add (right) ──
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                key: const Key('vehicle_tare_cancel_button'),
                                onPressed: _isBusy
                                    ? null
                                    : () {
                                        _singleTapTimer?.cancel();
                                        Navigator.of(context).pop();
                                      },
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  key: const Key('vehicle_tare_add_button'),
                                  onPressed: _isBusy ? null : _addPressed,
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
                                            Icon(
                                              _isEditing
                                                  ? Icons.check_rounded
                                                  : Icons.add_rounded,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _isEditing ? 'Save' : 'Add',
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

  /// Records table with SL NO / VEHICLE NO / WEIGHT columns.
  Widget _buildRecordsTable() {
    const headerStyle = TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: Color(0xFF64748B),
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                SizedBox(width: 52, child: Text('SL NO', style: headerStyle)),
                Expanded(child: Text('VEHICLE NO', style: headerStyle)),
                SizedBox(
                  width: 136,
                  child: Text(
                    'WEIGHT',
                    style: headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: const Color(0xFFE2E8F0)),
          if (_records.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              child: Center(
                child: Text(
                  'No vehicle tare records yet.\nTap Add to record the first one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                    height: 1.5,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < _records.length; i++) ...[
              _buildRecordRow(i),
              if (i < _records.length - 1)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  height: 1,
                  color: const Color(0xFFF1F5F9),
                ),
            ],
        ],
      ),
    );
  }

  /// One selectable table row. The selected row is highlighted so the
  /// operator can see which record Edit will load.
  Widget _buildRecordRow(int index) {
    final record = _records[index];
    final isSelected = _selectedVehicle == record.vehicleNumber;

    const cellStyle = TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Color(0xFF0F172A),
    );
    final weightStyle = TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: isSelected ? const Color(0xFF0D53FC) : const Color(0xFF0F172A),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: _isBusy ? null : () => _onRecordTap(record),
          onDoubleTap: _isBusy ? null : () => _onRecordDoubleTap(record),
          borderRadius: BorderRadius.circular(8),
          hoverColor: const Color(0xFFF1F5F9),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0D53FC)
                    : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text('${index + 1}', style: cellStyle),
                ),
                Expanded(
                  child: Text(
                    record.vehicleNumber,
                    style: cellStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 104,
                  child: Text(
                    _formatTableWeight(record.tareKg),
                    style: weightStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'Edit Tare Weight',
                  child: InkWell(
                    key: Key('vehicle_tare_row_edit_${record.id ?? index}'),
                    onTap: _isBusy ? null : () => _editRecord(record),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 15,
                        color: isSelected
                            ? const Color(0xFF0D53FC)
                            : const Color(0xFF94A3B8),
                      ),
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

  /// Entry form for one new vehicle tare record, revealed by Add.
  /// In edit mode it is prefilled with the selected record's values and
  /// offers an explicit Discard control that restores the stored values.
  Widget _buildEntryForm(String unitLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isEditing ? 'EDIT VEHICLE TARE' : 'NEW VEHICLE TARE',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Color(0xFF475569),
              ),
            ),
            if (_isEditing)
              TextButton(
                key: const Key('vehicle_tare_cancel_edit_button'),
                onPressed: _isBusy ? null : _cancelEditPressed,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Cancel'),
              ),
          ],
        ),
        const SizedBox(height: 7),
        TextFormField(
          key: const Key('vehicle_tare_vehicle_field'),
          controller: _vehicleController,
          focusNode: _vehicleFocusNode,
          enabled: !_isBusy,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\-/]')),
            UpperCaseTextFormatter(),
          ],
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: 'Enter Vehicle Number',
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
            if (_errorMessage != null || _hintMessage != null) {
              setState(() {
                _errorMessage = null;
                _hintMessage = null;
              });
            }
          },
        ),
        const SizedBox(height: 10),
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
                    border: Border.all(color: const Color(0xFFA7F3D0)),
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
          enabled: !_isBusy,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
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
          onFieldSubmitted: (_) => _addPressed(),
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
            if (_errorMessage != null || _hintMessage != null) {
              setState(() {
                _errorMessage = null;
                _hintMessage = null;
              });
            }
          },
        ),
        const SizedBox(height: 10),
        _buildLiveReadingRow(),
      ],
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

  /// Date & Time Display Badge
  Widget _buildDateTimeBadge(DateTime dateTime) {
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
              DateFormat('EEEE, d MMMM yyyy').format(dateTime),
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

          // Clock Icon + Time
          const Icon(
            Icons.access_time_filled_rounded,
            size: 14.5,
            color: Color(0xFF059669),
          ),
          const SizedBox(width: 7),
          Text(
            DateFormat('hh:mm:ss a').format(dateTime),
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
