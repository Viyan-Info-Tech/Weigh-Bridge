import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../vehicle_type/domain/entities/vehicle_type.dart';
import '../../../vehicle_type/presentation/bloc/vehicle_type_bloc.dart';
import '../../../vehicle_type/presentation/bloc/vehicle_type_state.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/weighment_report_item.dart';
import '../../domain/usecases/export_report_usecase.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/print_report_dialog.dart';
import '../widgets/weighment_details_dialog.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  static const double _minTableWidth = 1200;
  static const double _minTableChromeHeight = 83;
  static const double _shortViewportHeight = 560;

  final TextEditingController _searchController = TextEditingController();
  final DateFormat _datePickerFormat = DateFormat('dd/MM/yyyy');
  final ScrollController _hScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(const LoadReportInitial());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _hScrollController.dispose();
    super.dispose();
  }

  Future<void> _selectCustomDate({
    required BuildContext context,
    required bool isStartDate,
    required ReportFilter filter,
  }) async {
    final bloc = context.read<ReportBloc>();
    final initialDate = isStartDate
        ? (filter.customStartDate ?? filter.effectiveStartDate)
        : (filter.customEndDate ?? filter.effectiveEndDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0284C7),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStartDate) {
        bloc.add(
          ReportCustomDateChanged(
            startDate: picked,
            endDate: filter.customEndDate ?? filter.effectiveEndDate,
          ),
        );
      } else {
        bloc.add(
          ReportCustomDateChanged(
            startDate: filter.customStartDate ?? filter.effectiveStartDate,
            endDate: picked,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFDC2626),
              ),
            );
          }

          if (state.exportResult != null) {
            final result = state.exportResult!;
            context.read<ReportBloc>().add(const ClearExportResult());

            switch (result.type) {
              case ExportResultType.noRecords:
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: const Text(
                      'No Records to Export',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    content: const Text(
                      'There are no weighment records matching the selected filters.',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF475569),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                break;

              case ExportResultType.failure:
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: const Text(
                      'Unable to Export Report',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    content: Text(
                      result.errorMessage ??
                          'The file could not be saved to the selected location.\n\nPlease choose another location and try again.',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF475569),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                break;

              case ExportResultType.cancelled:
                // User intentionally cancelled save dialog: silent return, no error snackbar
                break;

              case ExportResultType.success:
                final filePath = result.filePath!;
                final fileName = result.fileName ?? p.basename(filePath);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '✓ Report exported successfully',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                fileName,
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF16A34A),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Open Folder',
                      textColor: Colors.white,
                      onPressed: () => _openFolder(filePath),
                    ),
                  ),
                );
                break;
            }
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: LayoutBuilder(
              builder: (context, viewport) {
                final pageContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, state),
                    const SizedBox(height: 16),
                    _buildSummaryCards(state.summary),
                    const SizedBox(height: 16),
                    _buildFilterCard(context, state),
                    const SizedBox(height: 16),
                    _buildSearchAndActionBar(context, state),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildReportTableContainer(context, state),
                    ),
                  ],
                );

                if (viewport.maxHeight >= _shortViewportHeight) {
                  return pageContent;
                }

                // Very short window: the fixed chrome above the table no
                // longer fits, so make the whole page scroll instead.
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context, state),
                      const SizedBox(height: 16),
                      _buildSummaryCards(state.summary),
                      const SizedBox(height: 16),
                      _buildFilterCard(context, state),
                      const SizedBox(height: 16),
                      _buildSearchAndActionBar(context, state),
                      const SizedBox(height: 12),
                      _buildReportTableContainer(context, state),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ReportState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'REPORTS',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'View, filter and export weighment records',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569)),
          onPressed: () {
            context.read<ReportBloc>().add(const RefreshReport());
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCards(ReportSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Bills',
                value: '${summary.totalBills}',
                subtitle: 'Total weighments',
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xFF0284C7),
                bgColor: const Color(0xFFF0F9FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Gross',
                value: '${summary.totalGrossTons} T',
                subtitle: '${summary.totalGrossWeightKg.toStringAsFixed(0)} kg',
                icon: Icons.scale_outlined,
                iconColor: const Color(0xFF475569),
                bgColor: const Color(0xFFF1F5F9),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Net Weight',
                value: '${summary.totalNetTons} T',
                subtitle: '${summary.totalNetWeightKg.toStringAsFixed(0)} kg',
                icon: Icons.line_weight_rounded,
                iconColor: const Color(0xFF16A34A),
                bgColor: const Color(0xFFDCFCE7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Revenue',
                value:
                    '₹${NumberFormat('#,##,###').format(summary.totalRevenue.round())}',
                subtitle: 'Billed amount',
                icon: Icons.currency_rupee_rounded,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Pending',
                value: '${summary.pendingCount}',
                subtitle: 'Waiting 2nd weight',
                icon: Icons.pending_actions_outlined,
                iconColor: const Color(0xFFEA580C),
                bgColor: const Color(0xFFFFEDD5),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context, ReportState state) {
    final filter = state.filter;
    final isCustomDate = filter.datePreset == DateRangePreset.custom;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune_rounded, size: 16, color: Color(0xFF475569)),
              SizedBox(width: 6),
              Text(
                'Filters',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Date Range Preset Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdownContainer(
                  label: 'Date Range',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DateRangePreset>(
                      value: filter.datePreset,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          context.read<ReportBloc>().add(
                            ReportFilterPresetChanged(val),
                          );
                        }
                      },
                      items: DateRangePreset.values
                          .map(
                            (preset) => DropdownMenuItem(
                              value: preset,
                              child: Text(preset.label),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // If Custom Range, show Date Pickers
              if (isCustomDate) ...[
                Expanded(
                  flex: 2,
                  child: _buildDateButton(
                    label: 'Date From',
                    dateText: _datePickerFormat.format(
                      filter.effectiveStartDate,
                    ),
                    onTap: () => _selectCustomDate(
                      context: context,
                      isStartDate: true,
                      filter: filter,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildDateButton(
                    label: 'Date To',
                    dateText: _datePickerFormat.format(filter.effectiveEndDate),
                    onTap: () => _selectCustomDate(
                      context: context,
                      isStartDate: false,
                      filter: filter,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Party Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdownContainer(
                  label: 'Party',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: filter.partyId,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      onChanged: (val) {
                        context.read<ReportBloc>().add(
                          ReportPartyFilterChanged(val),
                        );
                      },
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'All Parties',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...state.parties.map(
                          (p) => DropdownMenuItem<int?>(
                            value: p.id,
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Vehicle Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdownContainer(
                  label: 'Vehicle',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: filter.vehicleId,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      onChanged: (val) {
                        context.read<ReportBloc>().add(
                          ReportVehicleFilterChanged(val),
                        );
                      },
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'All Vehicles',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...state.vehicles.map(
                          (v) => DropdownMenuItem<int?>(
                            value: v.id,
                            child: Text(
                              v.vehicleNumber,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Material Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdownContainer(
                  label: 'Material',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: filter.materialId,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      onChanged: (val) {
                        context.read<ReportBloc>().add(
                          ReportMaterialFilterChanged(val),
                        );
                      },
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'All Materials',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...state.materials.map(
                          (m) => DropdownMenuItem<int?>(
                            value: m.id,
                            child: Text(
                              m.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Status Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdownContainer(
                  label: 'Status',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filter.status,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          context.read<ReportBloc>().add(
                            ReportStatusFilterChanged(val),
                          );
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All Status'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Payment Mode Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdownContainer(
                  label: 'Payment',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filter.paymentMode,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          context.read<ReportBloc>().add(
                            ReportPaymentFilterChanged(val),
                          );
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All Modes'),
                        ),
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(
                          value: 'credit',
                          child: Text('Credit'),
                        ),
                        DropdownMenuItem(value: 'upi', child: Text('UPI')),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Apply and Reset Buttons
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _searchController.clear();
                      context.read<ReportBloc>().add(
                        const ResetReportFilters(),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ReportBloc>().add(
                        const ApplyReportFilters(),
                      );
                    },
                    icon: const Icon(Icons.filter_alt_outlined, size: 16),
                    label: const Text(
                      'Apply',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer({
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required String dateText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateText,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndActionBar(BuildContext context, ReportState state) {
    return Row(
      children: [
        // Live Search Input
        Expanded(
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                context.read<ReportBloc>().add(ReportSearchQueryChanged(val));
              },
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Search bill number, vehicle, party, material...',
                hintStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  color: Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ReportBloc>().add(
                            const ReportSearchQueryChanged(''),
                          );
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Print Report button
        OutlinedButton.icon(
          onPressed: () {
            final partyLabel =
                state.parties
                    .where((p) => p.id == state.filter.partyId)
                    .map((p) => p.name)
                    .firstOrNull ??
                'All Parties';
            final vehicleLabel =
                state.vehicles
                    .where((v) => v.id == state.filter.vehicleId)
                    .map((v) => v.vehicleNumber)
                    .firstOrNull ??
                'All Vehicles';
            final materialLabel =
                state.materials
                    .where((m) => m.id == state.filter.materialId)
                    .map((m) => m.name)
                    .firstOrNull ??
                'All Materials';

            PrintReportDialog.show(
              context: context,
              records: state.records,
              summary: state.summary,
              filter: state.filter,
              partyLabel: partyLabel,
              vehicleLabel: vehicleLabel,
              materialLabel: materialLabel,
            );
          },
          icon: const Icon(Icons.print_outlined, size: 16),
          label: const Text(
            'Print Report',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1E293B),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        const SizedBox(width: 10),

        // Export CSV button
        ElevatedButton.icon(
          onPressed: state.isExporting
              ? null
              : () {
                  context.read<ReportBloc>().add(const ExportReportCsv());
                },
          icon: state.isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.download_rounded, size: 16),
          label: Text(
            state.isExporting ? 'Exporting...' : 'Export CSV',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF64748B),
            disabledForegroundColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildReportTableContainer(BuildContext context, ReportState state) {
    if (state.isLoading && state.records.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0284C7)),
      );
    }

    if (state.records.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              const Text(
                'No weighment records found',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Try adjusting the date range or filter criteria above.',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<VehicleTypeBloc, VehicleTypeState>(
      builder: (context, vtState) {
        final vehicleTypes = vtState.vehicleTypes;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth < _minTableWidth
                  ? _minTableWidth
                  : constraints.maxWidth;

              // Whole-page scroll mode (very short window): the table is given
              // unbounded height, so render it at its natural size and let the
              // page scroll vertically.
              if (!constraints.maxHeight.isFinite) {
                return SingleChildScrollView(
                  controller: _hScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tableHeader(),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        ..._tableRows(context, state, vehicleTypes),
                        _tableFooter(state),
                      ],
                    ),
                  ),
                );
              }

              // The fixed table chrome (header 42 + divider 1 + footer 40)
              // needs at least 83px. When the available height is smaller the
              // Expanded rows list would overflow, so switch to a naturally
              // sized table inside a vertical scroll instead.
              if (constraints.maxHeight < _minTableChromeHeight) {
                return SingleChildScrollView(
                  controller: _hScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _tableHeader(),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          ..._tableRows(context, state, vehicleTypes),
                          _tableFooter(state),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                controller: _hScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Header Row
                      _tableHeader(),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),

                      // Data Rows
                      Expanded(
                        child: ListView.separated(
                          itemCount: state.records.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: Color(0xFFF1F5F9),
                          ),
                          itemBuilder: (context, index) {
                            final item = state.records[index];
                            return _buildTableRow(
                              context,
                              item,
                              state,
                              vehicleTypes,
                            );
                          },
                        ),
                      ),

                      // Table Footer Summary Bar
                      _tableFooter(state),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _tableHeader() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: const [
          Expanded(flex: 11, child: _HeaderCell('BILL NO')),
          Expanded(flex: 13, child: _HeaderCell('DATE & TIME')),
          Expanded(flex: 11, child: _HeaderCell('VEHICLE')),
          Expanded(flex: 13, child: _HeaderCell('PARTY')),
          Expanded(flex: 11, child: _HeaderCell('MATERIAL')),
          Expanded(
            flex: 12,
            child: _HeaderCell('GROSS WEIGHT', align: TextAlign.right),
          ),
          Expanded(
            flex: 12,
            child: _HeaderCell('TARE WEIGHT', align: TextAlign.right),
          ),
          Expanded(
            flex: 12,
            child: _HeaderCell('NET WEIGHT', align: TextAlign.right),
          ),
          Expanded(
            flex: 10,
            child: _HeaderCell('AMOUNT', align: TextAlign.right),
          ),
          Expanded(
            flex: 11,
            child: _HeaderCell('STATUS', align: TextAlign.center),
          ),
          Expanded(
            flex: 8,
            child: _HeaderCell('ACTION', align: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _tableFooter(ReportState state) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ${state.records.length} Bills',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          Row(
            children: [
              Text(
                'Total Net: ${state.summary.totalNetTons} T',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'Total Amount: ₹${NumberFormat('#,##,###').format(state.summary.totalRevenue.round())}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _tableRows(
    BuildContext context,
    ReportState state,
    List<VehicleType> vehicleTypes,
  ) {
    return [
      for (var i = 0; i < state.records.length; i++) ...[
        if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
        _buildTableRow(context, state.records[i], state, vehicleTypes),
      ],
    ];
  }

  Widget _buildTableRow(
    BuildContext context,
    WeighmentReportItem item,
    ReportState state,
    List<VehicleType> vehicleTypes,
  ) {
    final dateFormat = DateFormat('dd/MM/yy');
    final timeFormat = DateFormat('hh:mm a');

    final isCompleted = item.isCompleted;
    final statusColor = isCompleted
        ? const Color(0xFF16A34A)
        : const Color(0xFFD97706);
    final statusBg = isCompleted
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEF3C7);

    return InkWell(
      onTap: () {
        WeighmentDetailsDialog.show(
          context: context,
          record: item,
          parties: state.parties,
          vehicles: state.vehicles,
          materials: state.materials,
          vehicleTypes: vehicleTypes,
        );
      },
      hoverColor: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Bill No
            Expanded(
              flex: 11,
              child: Text(
                item.billNumber,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                ),
              ),
            ),
            // Date & Time
            Expanded(
              flex: 13,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(item.createdAt),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    timeFormat.format(item.createdAt),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            // Vehicle
            Expanded(
              flex: 11,
              child: Text(
                item.vehicleNumber,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Party
            Expanded(
              flex: 13,
              child: Text(
                item.partyName,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: Color(0xFF334155),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Material
            Expanded(
              flex: 11,
              child: Text(
                item.materialName,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: Color(0xFF334155),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Gross Weight
            Expanded(
              flex: 12,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  item.grossWeightKg != null
                      ? '${((item.weightUnit.toLowerCase() == 'ton' || item.weightUnit.toLowerCase() == 'tonne') ? item.grossWeightKg! / 1000 : item.grossWeightKg!).toStringAsFixed(item.weightUnit.toLowerCase() == 'kg' ? 0 : 3)} ${item.weightUnit}'
                      : '—',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.grossWeightKg != null
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
            // Tare Weight
            Expanded(
              flex: 12,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  item.tareWeightKg != null
                      ? '${((item.weightUnit.toLowerCase() == 'ton' || item.weightUnit.toLowerCase() == 'tonne') ? item.tareWeightKg! / 1000 : item.tareWeightKg!).toStringAsFixed(item.weightUnit.toLowerCase() == 'kg' ? 0 : 3)} ${item.weightUnit}'
                      : '—',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.tareWeightKg != null
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
            // Net Weight
            Expanded(
              flex: 12,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  item.netWeightKg != null
                      ? '${((item.weightUnit.toLowerCase() == 'ton' || item.weightUnit.toLowerCase() == 'tonne') ? item.netWeightKg! / 1000 : item.netWeightKg!).toStringAsFixed(item.weightUnit.toLowerCase() == 'kg' ? 0 : 3)} ${item.weightUnit}'
                      : '—',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: item.netWeightKg != null
                        ? const Color(0xFF0284C7)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
            // Amount
            Expanded(
              flex: 10,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '₹${item.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            // Status Badge
            Expanded(
              flex: 11,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          item.displayStatus,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Action (View)
            Expanded(
              flex: 8,
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: Color(0xFF0284C7),
                  ),
                  tooltip: 'View Weighment Details',
                  splashRadius: 18,
                  onPressed: () {
                    WeighmentDetailsDialog.show(
                      context: context,
                      record: item,
                      parties: state.parties,
                      vehicles: state.vehicles,
                      materials: state.materials,
                      vehicleTypes: vehicleTypes,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openFolder(String filePath) {
    try {
      if (Platform.isMacOS) {
        Process.run('open', ['-R', filePath]);
      } else if (Platform.isWindows) {
        Process.run('explorer.exe', ['/select,', filePath]);
      } else if (Platform.isLinux) {
        Process.run('xdg-open', [p.dirname(filePath)]);
      }
    } catch (e) {
      debugPrint('Error opening folder: $e');
    }
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final TextAlign align;

  const _HeaderCell(this.label, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: align,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF475569),
        letterSpacing: 0.5,
      ),
    );
  }
}
