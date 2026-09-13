import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/weighment_report_item.dart';

class PrintReportDialog extends StatelessWidget {
  final List<WeighmentReportItem> records;
  final ReportSummary summary;
  final ReportFilter filter;

  const PrintReportDialog({
    super.key,
    required this.records,
    required this.summary,
    required this.filter,
  });

  static Future<void> show({
    required BuildContext context,
    required List<WeighmentReportItem> records,
    required ReportSummary summary,
    required ReportFilter filter,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => PrintReportDialog(
        records: records,
        summary: summary,
        filter: filter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final printDateTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    String filterDateLabel = filter.datePreset.label;
    if (filter.datePreset == DateRangePreset.custom &&
        filter.customStartDate != null &&
        filter.customEndDate != null) {
      filterDateLabel =
          '${dateFormat.format(filter.customStartDate!)} to ${dateFormat.format(filter.customEndDate!)}';
    } else {
      filterDateLabel =
          '${filter.datePreset.label} (${dateFormat.format(filter.effectiveStartDate)} - ${dateFormat.format(filter.effectiveEndDate)})';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final settings = settingsState.settings;
          final businessName = settings?.businessName ?? 'VIYAN WEIGHBRIDGE';
          final address = settings?.address ?? '';
          final phone = settings?.phoneNumber ?? '';
          final gstin = settings?.gstin ?? '';

          return Container(
            width: 900,
            constraints: const BoxConstraints(maxHeight: 700),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Modal top action bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Report Print Preview',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 16),

                // Printable Sheet
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Business Header
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  businessName.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                if (address.isNotEmpty)
                                  Text(
                                    address,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                if (phone.isNotEmpty || gstin.isNotEmpty)
                                  Text(
                                    [
                                      if (phone.isNotEmpty) 'Phone: $phone',
                                      if (gstin.isNotEmpty) 'GSTIN: $gstin',
                                    ].join(' | '),
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(thickness: 1.5, color: Color(0xFF0F172A)),
                          const SizedBox(height: 8),

                          // Report Info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'WEIGHMENT REPORT',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Period: $filterDateLabel',
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Printed On: $printDateTime',
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    'Total Bills: ${records.length}',
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Table
                          Table(
                            border: TableBorder.all(
                              color: const Color(0xFFCBD5E1),
                              width: 0.8,
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(1.2), // Bill
                              1: FlexColumnWidth(1.5), // Date & Time
                              2: FlexColumnWidth(1.4), // Vehicle
                              3: FlexColumnWidth(1.5), // Party
                              4: FlexColumnWidth(1.2), // Material
                              5: FlexColumnWidth(1.1), // Gross
                              6: FlexColumnWidth(1.1), // Tare
                              7: FlexColumnWidth(1.1), // Net
                              8: FlexColumnWidth(1.0), // Amount
                              9: FlexColumnWidth(1.3), // Status
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
                                  _cell('PARTY', isHeader: true),
                                  _cell('MATERIAL', isHeader: true),
                                  _cell('GROSS (kg)', isHeader: true, align: TextAlign.right),
                                  _cell('TARE (kg)', isHeader: true, align: TextAlign.right),
                                  _cell('NET (kg)', isHeader: true, align: TextAlign.right),
                                  _cell('AMT (₹)', isHeader: true, align: TextAlign.right),
                                  _cell('STATUS', isHeader: true),
                                ],
                              ),
                              // Table Rows
                              ...records.map(
                                (r) => TableRow(
                                  children: [
                                    _cell(r.billNumber, bold: true),
                                    _cell('${dateFormat.format(r.createdAt)} ${timeFormat.format(r.createdAt)}'),
                                    _cell(r.vehicleNumber),
                                    _cell(r.partyName),
                                    _cell(r.materialName),
                                    _cell(r.grossWeightKg?.toStringAsFixed(0) ?? '—', align: TextAlign.right),
                                    _cell(r.tareWeightKg?.toStringAsFixed(0) ?? '—', align: TextAlign.right),
                                    _cell(r.netWeightKg?.toStringAsFixed(0) ?? '—', align: TextAlign.right, bold: true),
                                    _cell('₹${r.amount.toStringAsFixed(0)}', align: TextAlign.right),
                                    _cell(r.displayStatus),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Summary Totals
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _summaryItem('Total Bills', '${summary.totalBills}'),
                                _summaryItem('Total Gross', '${summary.totalGrossTons} T'),
                                _summaryItem('Total Net', '${summary.totalNetTons} T'),
                                _summaryItem('Total Revenue', '₹${summary.totalRevenue.toStringAsFixed(0)}'),
                                _summaryItem('Pending', '${summary.pendingCount}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bottom actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.print, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text('Print job sent for Weighment Report (${records.length} records)'),
                              ],
                            ),
                            backgroundColor: const Color(0xFF0284C7),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Print Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  Widget _cell(
    String text, {
    bool isHeader = false,
    bool bold = false,
    TextAlign align = TextAlign.left,
  }) {
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
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
