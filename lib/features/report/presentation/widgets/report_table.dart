import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/weighment_report_item.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../widgets/weighment_details_dialog.dart';

class ReportTable extends StatelessWidget {
  const ReportTable({
    super.key,
    required this.hScrollController,
    required this.state,
  });

  final ScrollController hScrollController;
  final ReportState state;

  static const double _minTableWidth = 1200;
  static const double _minTableChromeHeight = 83;

  String _formatWeight(double? kg, String unit) {
    if (kg == null) return '—';
    final isTon = unit.toLowerCase() == 'ton' || unit.toLowerCase() == 'tonne';
    final value = isTon ? kg / 1000 : kg;
    return '${NumberFormat(isTon ? '#,##0.000' : '#,##0').format(value)} ${isTon ? 'ton' : 'kg'}';
  }

  @override
  Widget build(BuildContext context) {
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
              controller: hScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TableHeader(),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ..._tableRows(context, state),
                    _TableFooter(state: state),
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
              controller: hScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TableHeader(),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      ..._tableRows(context, state),
                      _TableFooter(state: state),
                    ],
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            controller: hScrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Header Row
                  _TableHeader(),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Data Rows
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.records.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final item = state.records[index];
                        return _TableRow(
                          item: item,
                          state: state,
                          formatWeight: _formatWeight,
                        );
                      },
                    ),
                  ),

                  // Table Footer Summary Bar
                  _TableFooter(state: state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _tableRows(BuildContext context, ReportState state) {
    return [
      for (var i = 0; i < state.records.length; i++) ...[
        if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
        _TableRow(
          item: state.records[i],
          state: state,
          formatWeight: _formatWeight,
        ),
      ],
    ];
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          Expanded(flex: 13, child: _HeaderCell('CUSTOMER')),
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
}

class _TableFooter extends StatelessWidget {
  const _TableFooter({required this.state});

  final ReportState state;

  @override
  Widget build(BuildContext context) {
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
            state.hasMoreRecords
                ? 'Showing ${state.records.length} of ${state.totalRecords} Weighments'
                : 'Total: ${state.totalRecords} Weighments',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          Row(
            children: [
              if (state.isLoadingMore) ...[
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 12),
              ] else if (state.hasMoreRecords)
                TextButton(
                  onPressed: () => context.read<ReportBloc>().add(
                    const LoadNextReportPage(),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Load more',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
              Text(
                'Total Net: ${state.summary.totalNetTons} T',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.item,
    required this.state,
    required this.formatWeight,
  });

  final WeighmentReportItem item;
  final ReportState state;
  final String Function(double?, String) formatWeight;

  @override
  Widget build(BuildContext context) {
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
          customers: state.customers,
          materials: state.materials,
          weightUnit: state.weightUnit,
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
            // Customer
            Expanded(
              flex: 13,
              child: Text(
                item.customerName,
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
                  formatWeight(item.grossWeightKg, state.weightUnit),
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
                  formatWeight(item.tareWeightKg, state.weightUnit),
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
                  formatWeight(item.netWeightKg, state.weightUnit),
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
                          item.isCompleted ? 'COMPLETED' : 'INCOMPLETE',
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
                      customers: state.customers,
                      materials: state.materials,
                      weightUnit: state.weightUnit,
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
