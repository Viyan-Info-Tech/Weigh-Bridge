import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../entities/report_filter.dart';
import '../entities/report_summary.dart';
import '../entities/weighment_report_item.dart';

class ReportPdfGenerator {
  const ReportPdfGenerator();

  Future<Uint8List> generateReportPdf({
    required List<WeighmentReportItem> records,
    required ReportSummary summary,
    required ReportFilter filter,
    String? companyName,
    String? address,
    String? phone,
    String? gstin,
    String partyLabel = 'All Parties',
    String vehicleLabel = 'All Vehicles',
    String materialLabel = 'All Materials',
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final printDateTime = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

    String filterDateLabel = filter.datePreset.label;
    if (filter.datePreset == DateRangePreset.custom &&
        filter.customStartDate != null &&
        filter.customEndDate != null) {
      filterDateLabel =
          '${dateFormat.format(filter.customStartDate!)} - ${dateFormat.format(filter.customEndDate!)}';
    } else {
      filterDateLabel =
          '${filter.datePreset.label} (${dateFormat.format(filter.effectiveStartDate)} - ${dateFormat.format(filter.effectiveEndDate)})';
    }

    final effectiveCompanyName = (companyName != null && companyName.trim().isNotEmpty)
        ? companyName.trim()
        : 'VIYAN WEIGHBRIDGE';

    final statusLabel = filter.status == 'all'
        ? 'All Statuses'
        : filter.status.toUpperCase();
    final paymentLabel = filter.paymentMode == 'all'
        ? 'All Modes'
        : filter.paymentMode.toUpperCase();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      effectiveCompanyName,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.2,
                        color: PdfColor.fromHex('#0F172A'),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'WEIGHMENT REPORT',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0284C7'),
                      ),
                    ),
                    if (address != null && address.isNotEmpty)
                      pw.Text(
                        address,
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          color: PdfColor.fromHex('#475569'),
                        ),
                      ),
                    if ((phone != null && phone.isNotEmpty) ||
                        (gstin != null && gstin.isNotEmpty))
                      pw.Text(
                        [
                          if (phone != null && phone.isNotEmpty) 'Phone: $phone',
                          if (gstin != null && gstin.isNotEmpty) 'GSTIN: $gstin',
                        ].join(' | '),
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColor.fromHex('#64748B'),
                        ),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1, color: PdfColor.fromHex('#0F172A')),
              pw.SizedBox(height: 4),

              // Filter & Report Info Section
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F8FAFC'),
                  border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.6),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _pdfMetaText('Period', filterDateLabel),
                        pw.SizedBox(height: 2),
                        _pdfMetaText('Party', partyLabel),
                        pw.SizedBox(height: 2),
                        _pdfMetaText('Vehicle', vehicleLabel),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _pdfMetaText('Generated', printDateTime),
                        pw.SizedBox(height: 2),
                        _pdfMetaText('Material', materialLabel),
                        pw.SizedBox(height: 2),
                        _pdfMetaText('Status', statusLabel),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _pdfMetaText('Total Bills', '${records.length}'),
                        pw.SizedBox(height: 2),
                        _pdfMetaText('Payment Mode', paymentLabel),
                        pw.SizedBox(height: 2),
                        _pdfMetaText('Export Type', 'Production Report'),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'VIYAN WEIGHBRIDGE SOLUTION - CONFIDENTIAL REPORT',
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    color: PdfColor.fromHex('#94A3B8'),
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColor.fromHex('#64748B'),
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Records Table
            pw.TableHelper.fromTextArray(
              headers: [
                'BILL NO',
                'DATE & TIME',
                'VEHICLE',
                'PARTY',
                'MATERIAL',
                'GROSS',
                'TARE',
                'NET',
                'AMOUNT',
                'STATUS',
              ],
              data: records.map((r) {
                final isTon = r.weightUnit.toLowerCase() == 'ton' ||
                    r.weightUnit.toLowerCase() == 'tonne';
                final decimals = isTon ? 3 : 0;

                final grossStr = r.grossWeightKg != null
                    ? '${(isTon ? r.grossWeightKg! / 1000 : r.grossWeightKg!).toStringAsFixed(decimals)} ${r.weightUnit}'
                    : '-';
                final tareStr = r.tareWeightKg != null
                    ? '${(isTon ? r.tareWeightKg! / 1000 : r.tareWeightKg!).toStringAsFixed(decimals)} ${r.weightUnit}'
                    : '-';
                final netStr = r.netWeightKg != null
                    ? '${(isTon ? r.netWeightKg! / 1000 : r.netWeightKg!).toStringAsFixed(decimals)} ${r.weightUnit}'
                    : '-';
                final dateStr =
                    '${dateFormat.format(r.createdAt)} ${timeFormat.format(r.createdAt)}';
                final amtStr = 'Rs. ${r.amount.toStringAsFixed(0)}';

                return [
                  r.billNumber,
                  dateStr,
                  r.vehicleNumber,
                  r.partyName,
                  r.materialName,
                  grossStr,
                  tareStr,
                  netStr,
                  amtStr,
                  r.displayStatus,
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
                color: PdfColor.fromHex('#0F172A'),
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F1F5F9'),
              ),
              cellStyle: pw.TextStyle(
                fontSize: 7.5,
                color: PdfColor.fromHex('#1E293B'),
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.centerRight,
                8: pw.Alignment.centerRight,
                9: pw.Alignment.center,
              },
              headerAlignments: {
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.centerRight,
                8: pw.Alignment.centerRight,
                9: pw.Alignment.center,
              },
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2),
                1: const pw.FlexColumnWidth(1.6),
                2: const pw.FlexColumnWidth(1.3),
                3: const pw.FlexColumnWidth(1.6),
                4: const pw.FlexColumnWidth(1.2),
                5: const pw.FlexColumnWidth(1.2),
                6: const pw.FlexColumnWidth(1.2),
                7: const pw.FlexColumnWidth(1.2),
                8: const pw.FlexColumnWidth(1.0),
                9: const pw.FlexColumnWidth(1.1),
              },
              border: pw.TableBorder.all(
                color: PdfColor.fromHex('#CBD5E1'),
                width: 0.5,
              ),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
            ),
            pw.SizedBox(height: 12),

            // Summary Totals Box
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                border: pw.Border.all(
                  color: PdfColor.fromHex('#E2E8F0'),
                  width: 0.8,
                ),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _pdfSummaryCol('Total Bills', '${summary.totalBills}'),
                  _pdfSummaryCol('Total Gross', '${summary.totalGrossTons} ton'),
                  _pdfSummaryCol(
                    'Total Tare',
                    '${(summary.totalTareWeightKg / 1000).toStringAsFixed(3)} ton',
                  ),
                  _pdfSummaryCol('Total Net', '${summary.totalNetTons} ton'),
                  _pdfSummaryCol(
                    'Total Revenue',
                    'Rs. ${summary.totalRevenue.toStringAsFixed(0)}',
                  ),
                  _pdfSummaryCol('Pending', '${summary.pendingCount}'),
                  _pdfSummaryCol('Completed', '${summary.completedCount}'),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfMetaText(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label: ',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#475569'),
            ),
          ),
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromHex('#0F172A'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSummaryCol(String title, String value) {
    return pw.Column(
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 7.5,
            color: PdfColor.fromHex('#64748B'),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#0F172A'),
          ),
        ),
      ],
    );
  }
}
