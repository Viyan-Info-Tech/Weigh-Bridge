import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/confirm_action_dialog.dart';
import '../../domain/entities/vehicle_tare_record.dart';
import 'vehicle_tare_form_dialog.dart';

export 'vehicle_tare_form_dialog.dart';

/// Vehicle tare registry popup, opened from the AUTO TARE status control
/// and by pressing F3 while no auto tare has been configured.
///
/// The popup lists every stored per-vehicle tare record and offers exactly
/// two actions: [Add] opens a separate modal popup to record a new vehicle tare,
/// and [Cancel] closes the popup without saving. Adding or editing a record never
/// creates a weighment or a bill; the main-screen F3 apply flow is untouched.
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

  /// Removes the tare record for [vehicleNumber].
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
  bool _isBusy = false;

  /// Normalized vehicle number of the selected table row, if any.
  String? _selectedVehicle;

  String? _errorMessage;

  /// Neutral guidance (e.g. "select a record first"); cleared on any action.
  String? _hintMessage;
  late DateTime _currentTime;
  Timer? _timeTimer;
  StreamSubscription<List<VehicleTareRecord>>? _recordsSubscription;
  final ScrollController _tableScrollController = ScrollController();

  bool get _isTon => widget.weightUnit.trim().toLowerCase() == 'ton';

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
    _timeTimer?.cancel();
    _tableScrollController.dispose();
    super.dispose();
  }

  /// Opens the edit modal dialog for [record] and prefills its values.
  Future<void> _editRecord(VehicleTareRecord record) async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _selectedVehicle = record.vehicleNumber;
      _hintMessage = null;
      _errorMessage = null;
    });

    try {
      final saved = await VehicleTareFormDialog.show(
        context,
        record: record,
        weightUnit: widget.weightUnit,
        liveScaleWeightKg: widget.liveScaleWeightKg,
        isScaleStable: widget.isScaleStable,
        isScaleMotion: widget.isScaleMotion,
        isScaleOverload: widget.isScaleOverload,
        onSave: (veh, kg) => widget.onUpdate(record.id ?? 0, veh, kg),
      );

      if (saved != null && mounted) {
        setState(() {
          _records.removeWhere(
            (r) =>
                r.vehicleNumber == saved.vehicleNumber ||
                r.vehicleNumber == record.vehicleNumber,
          );
          _records.add(saved);
          _records.sort(_sortRecords);
          _selectedVehicle = saved.vehicleNumber;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to update record: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  /// Opens a confirmation dialog to delete [record] and removes it if confirmed.
  Future<void> _deleteRecord(VehicleTareRecord record) async {
    if (_isBusy) return;
    final confirmed = await ConfirmActionDialog.show(
      context: context,
      title: 'Delete Vehicle Tare',
      message:
          'Are you sure you want to delete the tare record for vehicle ${record.vehicleNumber} (${_formatTableWeight(record.tareKg)})?',
      warningNote:
          'This will only remove the stored tare weight record for this vehicle. Existing weighments and bills will not be affected.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDanger: true,
      confirmIcon: Icons.delete_outline_rounded,
      confirmColor: const Color(0xFFDC2626),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isBusy = true;
        _hintMessage = null;
        _errorMessage = null;
      });

      try {
        await widget.onDelete(record.vehicleNumber);
        if (mounted) {
          setState(() {
            _records.removeWhere(
              (r) => r.vehicleNumber == record.vehicleNumber,
            );
            if (_selectedVehicle == record.vehicleNumber) {
              _selectedVehicle = null;
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to delete record: $e';
          });
        }
      } finally {
        if (mounted) {
          setState(() => _isBusy = false);
        }
      }
    }
  }

  /// Opens the new vehicle tare modal dialog.
  Future<void> _openAddDialog() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _hintMessage = null;
      _errorMessage = null;
    });

    try {
      final saved = await VehicleTareFormDialog.show(
        context,
        record: null,
        weightUnit: widget.weightUnit,
        liveScaleWeightKg: widget.liveScaleWeightKg,
        isScaleStable: widget.isScaleStable,
        isScaleMotion: widget.isScaleMotion,
        isScaleOverload: widget.isScaleOverload,
        onSave: (veh, kg) => widget.onAdd(veh, kg),
      );

      if (saved != null && mounted) {
        setState(() {
          _records.removeWhere((r) => r.vehicleNumber == saved.vehicleNumber);
          _records.add(saved);
          _records.sort(_sortRecords);
          _selectedVehicle = saved.vehicleNumber;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to add record: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  /// Single-click handler: selects the record for the weighment.
  void _onRecordTap(VehicleTareRecord record) {
    if (_isBusy) return;
    setState(() {
      _selectedVehicle = record.vehicleNumber;
    });
    widget.onSelect(record);
  }

  /// Double-click handler: opens edit modal UI for the record.
  void _onRecordDoubleTap(VehicleTareRecord record) {
    if (_isBusy) return;
    _editRecord(record);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Date and time badge
                      _buildDateTimeBadge(_currentTime),

                      const SizedBox(height: 14),

                      // 2. Records table
                      _buildRecordsTable(),

                      // 3. Guidance hint
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                key: const Key('vehicle_tare_add_button'),
                                onPressed: _isBusy ? null : _openAddDialog,
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
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add',
                                      style: TextStyle(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Records table with SL NO / VEHICLE NO / WEIGHT / ACTION columns.
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
          // Header row (pinned above scrollable rows)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                SizedBox(width: 52, child: Text('SL NO', style: headerStyle)),
                Expanded(child: Text('VEHICLE NO', style: headerStyle)),
                SizedBox(
                  width: 120,
                  child: Text(
                    'WEIGHT',
                    style: headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'ACTION',
                    style: headerStyle,
                    textAlign: TextAlign.center,
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Scrollbar(
                controller: _tableScrollController,
                thumbVisibility: _records.length > 5,
                child: SingleChildScrollView(
                  controller: _tableScrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// One selectable table row.
  /// Clicking the row selects the record and closes the Auto Tare dialog.
  /// Clicking Edit or Delete performs their actions without triggering row selection.
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
        child: Container(
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
              // 1. Tappable area for selecting record (SL NO, VEHICLE NO, WEIGHT)
              Expanded(
                child: InkWell(
                  onTap: _isBusy ? null : () => _onRecordTap(record),
                  onDoubleTap: _isBusy ? null : () => _onRecordDoubleTap(record),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(7),
                  ),
                  hoverColor: const Color(0xFFF1F5F9),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 7,
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
                          width: 120,
                          child: Text(
                            _formatTableWeight(record.tareKg),
                            style: weightStyle,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Action buttons (Edit & Delete) isolated from row selection
              SizedBox(
                width: 86,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Edit button (neutral/blue pencil)
                      Tooltip(
                        message: 'Edit vehicle tare',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: Key(
                              'vehicle_tare_row_edit_${record.id ?? record.vehicleNumber}',
                            ),
                            onTap: _isBusy ? null : () => _editRecord(record),
                            borderRadius: BorderRadius.circular(6),
                            hoverColor: const Color(0xFFEFF6FF),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: isSelected
                                    ? const Color(0xFF0D53FC)
                                    : const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Delete button (red trash)
                      Tooltip(
                        message: 'Delete vehicle tare',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: Key(
                              'vehicle_tare_row_delete_${record.id ?? record.vehicleNumber}',
                            ),
                            onTap: _isBusy ? null : () => _deleteRecord(record),
                            borderRadius: BorderRadius.circular(6),
                            hoverColor: const Color(0xFFFEF2F2),
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
