import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/printing/print_service.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/weighment_report_item.dart';
import '../../domain/services/report_pdf_generator.dart';

class PrintReportDialog extends StatefulWidget {
  final List<WeighmentReportItem> records;
  final ReportSummary summary;
  final ReportFilter filter;
  final String vehicleLabel;
  final String weightUnit;
  final ScaffoldMessengerState scaffoldMessenger;
  final PrintService printService;

  const PrintReportDialog({
    super.key,
    required this.records,
    required this.summary,
    required this.filter,
    this.vehicleLabel = 'All Vehicles',
    this.weightUnit = 'kg',
    required this.scaffoldMessenger,
    this.printService = const PrintService(),
  });

  static Future<void> show({
    required BuildContext context,
    required List<WeighmentReportItem> records,
    required ReportSummary summary,
    required ReportFilter filter,
    String vehicleLabel = 'All Vehicles',
    String weightUnit = 'kg',
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return showDialog<void>(
      context: context,
      builder: (_) => PrintReportDialog(
        records: records,
        summary: summary,
        filter: filter,
        vehicleLabel: vehicleLabel,
        weightUnit: weightUnit,
        scaffoldMessenger: scaffoldMessenger,
      ),
    );
  }

  @override
  State<PrintReportDialog> createState() => _PrintReportDialogState();
}

class _PrintReportDialogState extends State<PrintReportDialog> {
  bool _isPrinting = false;

  String _formatWeight(double? weightKg, String unit) {
    if (weightKg == null) return '—';
    final isTon = unit.toLowerCase() == 'ton' || unit.toLowerCase() == 'tonne';
    final val = isTon ? weightKg / 1000 : weightKg;
    final dec = isTon ? 3 : 0;
    return '${val.toStringAsFixed(dec)} $unit';
  }

  Future<void> _handlePrint(SettingsState settingsState) async {
    if (widget.records.isEmpty) {
      widget.scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('No records available to print'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isPrinting = true);
    try {
      final pdfGenerator = const ReportPdfGenerator();
      final settings = settingsState.settings;
      final pdfBytes = await pdfGenerator.generateReportPdf(
        records: widget.records,
        summary: widget.summary,
        filter: widget.filter,
        companyName: settings?.businessName,
        address: settings?.address,
        phone: settings?.phoneNumber,
        gstin: settings?.gstin,
        vehicleLabel: widget.vehicleLabel,
        weightUnit: widget.weightUnit,
      );

      await widget.printService.printPdf(
        pdfBytes,
        jobName:
            'Weighment_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      );

      if (!mounted) return;
      widget.scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.print_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Print document ready (${widget.records.length} records)'),
            ],
          ),
          backgroundColor: const Color(0xFF0284C7),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      widget.scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to generate print document: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm:ss');
    final printDateTime = DateFormat(
      'dd/MM/yyyy HH:mm:ss',
    ).format(DateTime.now());

    String filterDateLabel = widget.filter.datePreset.label;
    if (widget.filter.datePreset == DateRangePreset.custom &&
        widget.filter.customStartDate != null &&
        widget.filter.customEndDate != null) {
      filterDateLabel =
          '${dateFormat.format(widget.filter.customStartDate!)} - ${dateFormat.format(widget.filter.customEndDate!)}';
    } else {
      filterDateLabel =
          '${widget.filter.datePreset.label} (${dateFormat.format(widget.filter.effectiveStartDate)} - ${dateFormat.format(widget.filter.effectiveEndDate)})';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final settings = settingsState.settings;
          final companyName = settings?.businessName.trim() ?? '';
          final address = settings?.address ?? '';
          final phone = settings?.phoneNumber ?? '';
          final gstin = settings?.gstin ?? '';

          final statusLabel = 'All Statuses';

          return Container(
            // Fill the available width but never exceed the designed 950px,
            // so the preview shrinks instead of overflowing narrow windows.
            constraints: const BoxConstraints(maxWidth: 950, maxHeight: 740),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Modal top action bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 20,
                          color: Color(0xFF0F52BA),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Report Print Preview',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close Preview',
                    ),
                  ],
                ),
                const Divider(height: 16),

                // Printable Sheet Preview
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Business Header
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  companyName.isNotEmpty
                                      ? companyName
                                      : 'VIYAN WEIGHBRIDGE',
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'WEIGHMENT REPORT',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0284C7),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                if (address.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      address,
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 11,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                if (phone.isNotEmpty || gstin.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      [
                                        if (phone.isNotEmpty) 'Phone: $phone',
                                        if (gstin.isNotEmpty) 'GSTIN: $gstin',
                                      ].join(' | '),
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 10.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                            thickness: 1.2,
                            color: Color(0xFF0F172A),
                          ),
                          const SizedBox(height: 8),

                          // Report Info & Filters Grid
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _metaRow('Period', filterDateLabel),
                                    const SizedBox(height: 4),
                                    _metaRow('Vehicle', widget.vehicleLabel),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _metaRow('Generated', printDateTime),
                                    const SizedBox(height: 4),
                                    _metaRow('Status', statusLabel),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _metaRow(
                                      'Total Weighments',
                                      '${widget.records.length}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Tabular Report
                          Table(
                            border: TableBorder.all(
                              color: const Color(0xFFCBD5E1),
                              width: 0.8,
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(1.2), // Bill
                              1: FlexColumnWidth(1.5), // Date & Time
                              2: FlexColumnWidth(1.3), // Vehicle
                              3: FlexColumnWidth(1.2), // Gross
                              4: FlexColumnWidth(1.2), // Tare
                              5: FlexColumnWidth(1.2), // Net
                              6: FlexColumnWidth(1.1), // Status
                            },
                            children: [
                              // Table Header
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                ),
                                children: [
                                  _cell('BILL NO', isHeader: true),
                                  _cell('DATE & TIME', isHeader: true),
                                  _cell('VEHICLE', isHeader: true),
                                  _cell(
                                    'GROSS',
                                    isHeader: true,
                                    align: TextAlign.right,
                                  ),
                                  _cell(
                                    'TARE',
                                    isHeader: true,
                                    align: TextAlign.right,
                                  ),
                                  _cell(
                                    'NET',
                                    isHeader: true,
                                    align: TextAlign.right,
                                  ),
                                  _cell(
                                    'STATUS',
                                    isHeader: true,
                                    align: TextAlign.center,
                                  ),
                                ],
                              ),
                              // Table Data Rows
                              ...widget.records.map(
                                (r) => TableRow(
                                  children: [
                                    _cell(r.billNumber, bold: true),
                                    _cell(
                                      '${dateFormat.format(r.createdAt)} ${timeFormat.format(r.createdAt)}',
                                    ),
                                    _cell(r.vehicleNumber),
                                    _cell(
                                      _formatWeight(
                                        r.grossWeightKg,
                                        widget.weightUnit,
                                      ),
                                      align: TextAlign.right,
                                    ),
                                    _cell(
                                      _formatWeight(
                                        r.tareWeightKg,
                                        widget.weightUnit,
                                      ),
                                      align: TextAlign.right,
                                    ),
                                    _cell(
                                      _formatWeight(
                                        r.netWeightKg,
                                        widget.weightUnit,
                                      ),
                                      align: TextAlign.right,
                                      bold: true,
                                    ),
                                    _cell(
                                      r.isCompleted
                                          ? 'COMPLETED'
                                          : 'INCOMPLETE',
                                      align: TextAlign.center,
                                      isStatusBadge: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Summary Totals Section
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _summaryItem(
                                  'Total Weighments',
                                  '${widget.summary.totalBills}',
                                ),
                                _summaryItem(
                                  'Total Gross',
                                  _formatWeight(
                                    widget.summary.totalGrossWeightKg,
                                    widget.weightUnit,
                                  ),
                                ),
                                _summaryItem(
                                  'Total Tare',
                                  _formatWeight(
                                    widget.summary.totalTareWeightKg,
                                    widget.weightUnit,
                                  ),
                                ),
                                _summaryItem(
                                  'Total Net',
                                  _formatWeight(
                                    widget.summary.totalNetWeightKg,
                                    widget.weightUnit,
                                  ),
                                ),
                                _summaryItem(
                                  'Completed',
                                  '${widget.summary.completedCount}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bottom Action Buttons: Close | Print Report
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isPrinting
                          ? null
                          : () => _handlePrint(settingsState),
                      icon: _isPrinting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print_rounded, size: 16),
                      label: const Text('Print Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _cell(
    String text, {
    bool isHeader = false,
    bool bold = false,
    TextAlign align = TextAlign.left,
    bool isStatusBadge = false,
  }) {
    if (isStatusBadge) {
      final isCompleted = text.toUpperCase() == 'COMPLETED';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                  : const Color(0xFFD97706).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isCompleted
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFD97706),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: isHeader ? 10.5 : 11,
          fontWeight: isHeader
              ? FontWeight.w700
              : (bold ? FontWeight.w700 : FontWeight.w500),
          color: isHeader ? const Color(0xFF1E293B) : const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _summaryItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 10.5,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
