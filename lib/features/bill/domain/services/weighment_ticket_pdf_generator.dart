import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../settings/domain/entities/billing_settings.dart';
import '../entities/weighment.dart';
import '../../../customer/domain/entities/customer.dart';
import 'receipt_weight_resolver.dart';

/// Builds an authentic, industrial weighbridge document PDF matching dot-matrix / slip printer formats.
///
/// Features:
/// - Clean monospace Courier typography matching real-world industrial weighbridge slips.
/// - Centered company name, address, and contact details.
/// - Left-aligned metadata fields with aligned colons (TOKEN NO, VEHICLE NO, DESCRIPTION, PRODUCT, CONTAINER NO).
/// - Authentic dashed line separators (`--------------------------------------------------------------------------------`).
/// - Monospace structured weight table (WEIGHT, DATE, TIME) for GROSS, TARE, and NET.
/// - Charges, payment mode, driver and authorized signatory signature lines.
class WeighmentTicketPdfGenerator {
  const WeighmentTicketPdfGenerator();

  Future<Uint8List> generateTicketPdf({
    required Weighment bill,
    required Customer? customer,
    required String materialName,
    required BillingSettings settings,
    DateTime? printedAt,
  }) async {
    final pdfTheme = pw.ThemeData.withFont(
      base: pw.Font.courier(),
      bold: pw.Font.courierBold(),
    );
    final pdf = pw.Document(theme: pdfTheme);

    final weights = const ReceiptWeightResolver().resolve(bill);

    final vehicleNo = bill.vehicleNumber.isEmpty ? '--' : bill.vehicleNumber;
    final customerName = customer?.name ?? '--';
    final customerPhone = customer?.mobile ?? '';
    final printDate = DateFormat(
      'dd/MM/yyyy HH:mm:ss',
    ).format(printedAt ?? DateTime.now());
    final isCompleted = bill.isCompleted;

    final hasSerial = settings.showSerialNumber;
    final hasVehNo = settings.showVehicleNumber;
    final hasMat = settings.showMaterial;
    final hasCustomer = settings.showCustomer;

    final hasGross =
        isCompleted ||
        settings.showGrossWeight ||
        (weights.grossKg != null && weights.grossKg! > 0);
    final hasTare =
        isCompleted ||
        settings.showTareWeight ||
        (weights.tareKg != null && weights.tareKg! > 0);
    final hasNet =
        isCompleted ||
        settings.showNetWeight ||
        (weights.netKg != null && weights.netKg! > 0);

    final hasAmount = isCompleted || settings.showAmount || bill.amount > 0;
    final hasPayment = settings.showPaymentMode;

    final hasRemarks =
        settings.showRemarks &&
        bill.remarks != null &&
        bill.remarks!.trim().isNotEmpty;
    final hasFooter = settings.showFooterNote;
    final customFooter = settings.footerNote?.trim();
    final footerNoteText = (customFooter != null && customFooter.isNotEmpty)
        ? customFooter
        : 'Please check the weight before leaving the weighbridge.';

    final isTon =
        settings.weightUnit.toLowerCase() == 'ton' ||
        settings.weightUnit.toLowerCase() == 'tonne';
    final unit = isTon ? 'ton' : 'kg';
    final decimals = isTon ? 3 : 0;
    String formatWeight(double? kg) {
      if (kg == null) return '--';
      final display = isTon ? kg / 1000 : kg;
      return '${display.toStringAsFixed(decimals)} $unit';
    }

    final grossDate = weights.grossKg != null && bill.grossCapturedAt != null
        ? DateFormat('dd/MM/yyyy').format(bill.grossCapturedAt!)
        : (weights.grossKg != null
              ? DateFormat('dd/MM/yyyy').format(bill.createdAt)
              : '--');
    final grossTime = weights.grossKg != null && bill.grossCapturedAt != null
        ? DateFormat('hh:mm a').format(bill.grossCapturedAt!)
        : (weights.grossKg != null
              ? DateFormat('hh:mm a').format(bill.createdAt)
              : '--');

    final tareDate = weights.tareKg != null && bill.tareCapturedAt != null
        ? DateFormat('dd/MM/yyyy').format(bill.tareCapturedAt!)
        : (weights.tareKg != null
              ? DateFormat('dd/MM/yyyy').format(bill.createdAt)
              : '--');
    final tareTime = weights.tareKg != null && bill.tareCapturedAt != null
        ? DateFormat('hh:mm a').format(bill.tareCapturedAt!)
        : (weights.tareKg != null
              ? DateFormat('hh:mm a').format(bill.updatedAt)
              : '--');

    final companyName = settings.businessName.isNotEmpty
        ? settings.businessName
        : 'VIYAN WEIGHBRIDGE';
    final receiptTitleConfig = settings.receiptTitle.trim();
    final receiptTitle = receiptTitleConfig.isNotEmpty
        ? receiptTitleConfig
        : 'Public';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.portrait,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── 1. COMPANY HEADER (Centered) ───────────
              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      companyName.toUpperCase(),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (settings.businessSubtitle != null &&
                        settings.businessSubtitle!.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        settings.businessSubtitle!,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 9.5),
                      ),
                    ],
                    if (settings.serviceText != null &&
                        settings.serviceText!.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        settings.serviceText!,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                    if (settings.address != null &&
                        settings.address!.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        settings.address!,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                    if ((settings.phoneNumber != null &&
                            settings.phoneNumber!.trim().isNotEmpty) ||
                        (settings.email != null &&
                            settings.email!.trim().isNotEmpty) ||
                        (settings.gstin != null &&
                            settings.gstin!.trim().isNotEmpty)) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        [
                          if (settings.phoneNumber != null &&
                              settings.phoneNumber!.trim().isNotEmpty)
                            'Tel: ${settings.phoneNumber!}',
                          if (settings.email != null &&
                              settings.email!.trim().isNotEmpty)
                            'E-Mail: ${settings.email!}',
                          if (settings.gstin != null &&
                              settings.gstin!.trim().isNotEmpty)
                            'GSTIN: ${settings.gstin!}',
                        ].join('   '),
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ],
                ),
              ),

              pw.SizedBox(height: 18),

              // ── 2. SUBTITLE / CATEGORY (Left-aligned) ───
              pw.Text(
                receiptTitle,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              // ── 3. METADATA FIELDS (Aligned Colons) ────
              if (hasSerial) _buildFieldRow('TOKEN NO', bill.billNumber),
              if (hasVehNo) _buildFieldRow('VEHICLE NO', vehicleNo, isBold: true),
              if (hasCustomer) _buildFieldRow('DESCRIPTION', customerName),
              if (hasMat)
                _buildFieldRow(
                  'PRODUCT',
                  materialName.isEmpty ? '--' : materialName,
                ),
              if (customerPhone.isNotEmpty)
                _buildFieldRow('MOBILE NO', customerPhone),
              if (hasRemarks) _buildFieldRow('CONTAINER No', bill.remarks!),

              pw.SizedBox(height: 8),

              // ── 4. DASHED LINE ABOVE TABLE HEADER ──────
              _buildDashedLine(),

              // ── 5. WEIGHT TABLE HEADER ────────────────
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  children: [
                    pw.SizedBox(width: 90, child: pw.Text('')),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'WEIGHT',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'DATE',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'TIME',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 6. DASHED LINE BELOW TABLE HEADER ──────
              _buildDashedLine(),

              // ── 7. WEIGHT ROWS ─────────────────────────
              // GROSS
              if (hasGross &&
                  weights.grossKg != null &&
                  weights.grossKg! > 0)
                _buildWeightRow(
                  label: 'GROSS',
                  weight: formatWeight(weights.grossKg),
                  date: grossDate,
                  time: grossTime,
                ),

              // TARE
              if (hasTare &&
                  weights.tareKg != null &&
                  weights.tareKg! > 0)
                _buildWeightRow(
                  label: 'TARE',
                  weight: formatWeight(weights.tareKg),
                  date: tareDate,
                  time: tareTime,
                ),

              // NET
              if (hasNet &&
                  weights.netKg != null &&
                  weights.netKg! > 0)
                _buildWeightRow(
                  label: 'NET',
                  weight: formatWeight(weights.netKg),
                  date: '--',
                  time: '--',
                ),

              // ── 8. DASHED LINE BELOW WEIGHT TABLE ──────
              _buildDashedLine(),

              // ── 9. FINANCIALS (If enabled) ────────────
              if (hasAmount || hasPayment) ...[
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    if (hasAmount)
                      pw.Text(
                        'CHARGES (Rs.) : ${bill.amount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.Spacer(),
                    if (hasPayment)
                      pw.Text(
                        'PAYMENT MODE : ${bill.paymentMode.toUpperCase()}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],

              // ── 10. FOOTER NOTE ───────────────────────
              if (hasFooter) ...[
                pw.SizedBox(height: 10),
                pw.Text(
                  'Note: $footerNoteText',
                  style: const pw.TextStyle(fontSize: 8.5),
                ),
              ],

              pw.SizedBox(height: 48),

              // ── 11. SIGNATURES ────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Driver's Signature",
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Authorized Signatory',
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              // ── 12. PRINT TIMESTAMP ───────────────────
              pw.Center(
                child: pw.Text(
                  '* Printed on: $printDate *',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildFieldRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 125,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Text(
            ': ',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDashedLine() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Text(
        '--------------------------------------------------------------------------------',
        maxLines: 1,
        style: const pw.TextStyle(
          fontSize: 10,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  static pw.Widget _buildWeightRow({
    required String label,
    required String weight,
    required String date,
    required String time,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              weight,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              date,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              time,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
