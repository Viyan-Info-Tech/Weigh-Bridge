import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../settings/domain/entities/billing_settings.dart';
import '../entities/weighment.dart';
import 'receipt_pdf_fonts.dart';
import 'weighment_receipt_data.dart';

/// Builds an authentic, industrial weighbridge document PDF matching dot-matrix / slip printer formats.
///
/// The page is laid out from a [WeighmentReceiptData], the same object the
/// on-screen slip and the Settings live preview render, so the printed ticket
/// cannot drift away from what the operator approved on screen.
///
/// Features:
/// - Monospaced typography matching real-world industrial weighbridge slips.
///   The face comes from [ReceiptPdfFonts], which uses a Unicode-capable
///   TrueType font when one is bundled and Courier otherwise.
/// - Centered company name, address, and contact details.
/// - Left-aligned metadata fields with aligned colons (SERIAL NO, VEHICLE NO, DESCRIPTION, PRODUCT, CONTAINER NO).
/// - Authentic dashed line separators (`--------------------------------------------------------------------------------`).
/// - Monospace structured weight table (WEIGHT, DATE, TIME) for GROSS, TARE, and NET.
/// - Charges, payment mode, driver and authorized signatory signature lines.
class WeighmentTicketPdfGenerator {
  const WeighmentTicketPdfGenerator();

  Future<Uint8List> generateTicketPdf({
    required Weighment bill,
    required BillingSettings settings,
    DateTime? printedAt,
  }) async {
    final data = WeighmentReceiptData(
      bill: bill,
      settings: settings,
      printedAt: printedAt,
    );

    final pdfTheme = await ReceiptPdfFonts.load();
    final pdf = pw.Document(theme: pdfTheme);

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
                      data.companyName.toUpperCase(),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (data.settings.businessSubtitle != null &&
                        data.settings.businessSubtitle!.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        data.settings.businessSubtitle!,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 9.5),
                      ),
                    ],
                    if (data.settings.serviceText != null &&
                        data.settings.serviceText!.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        data.settings.serviceText!,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                    if (data.settings.address != null &&
                        data.settings.address!.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        data.settings.address!,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                    if (_hasContactLine(data)) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        _contactLine(data),
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
                data.receiptTitle,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              // ── 3. METADATA FIELDS (Aligned Colons) ────
              if (data.hasSerialNumber)
                _buildFieldRow('SERIAL NO', data.bill.billNumber),
              if (data.hasVehicleNumber)
                _buildFieldRow('VEHICLE NO', data.vehicleNumber, isBold: true),
              if (data.hasMaterial)
                _buildFieldRow('MATERIAL', data.materialName),
              if (data.hasDescription)
                _buildFieldRow('DESCRIPTION', data.descriptionText),
            
              if (data.hasRemarks)
                _buildFieldRow('CONTAINER NO', data.bill.remarks!),

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
              if (data.showGrossRow)
                _buildWeightRow(
                  label: 'GROSS',
                  weight: data.formatWeight(data.weights.grossKg),
                  date: data.grossDate,
                  time: data.grossTime,
                ),

              if (data.showTareRow)
                _buildWeightRow(
                  label: 'TARE',
                  weight: data.formatWeight(data.weights.tareKg),
                  date: data.tareDate,
                  time: data.tareTime,
                ),

              if (data.showNetRow)
                _buildWeightRow(
                  label: 'NET',
                  weight: data.formatWeight(data.weights.netKg),
                  date: '--',
                  time: '--',
                ),

              // ── 8. DASHED LINE BELOW WEIGHT TABLE ──────
              _buildDashedLine(),

              // ── 9. FOOTER NOTE ───────────────────────
              if (data.hasFooterNote) ...[
                pw.SizedBox(height: 10),
                pw.Text(
                  'Note: ${data.footerNoteText}',
                  style: const pw.TextStyle(fontSize: 8.5),
                ),
              ],

              pw.SizedBox(height: 24),

              // ── 12. PRINT TIMESTAMP ───────────────────
              pw.Center(
                child: pw.Text(
                  '* Printed on: ${data.printDate} *',
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

  static bool _hasContactLine(WeighmentReceiptData data) =>
      (data.settings.phoneNumber != null &&
          data.settings.phoneNumber!.trim().isNotEmpty) ||
      (data.settings.email != null && data.settings.email!.trim().isNotEmpty) ||
      (data.settings.gstin != null && data.settings.gstin!.trim().isNotEmpty);

  static String _contactLine(WeighmentReceiptData data) => [
    if (data.settings.phoneNumber != null &&
        data.settings.phoneNumber!.trim().isNotEmpty)
      'Tel: ${data.settings.phoneNumber!}',
    if (data.settings.email != null && data.settings.email!.trim().isNotEmpty)
      'E-Mail: ${data.settings.email!}',
    if (data.settings.gstin != null && data.settings.gstin!.trim().isNotEmpty)
      'GSTIN: ${data.settings.gstin!}',
  ].join('   ');

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
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            ': ',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
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
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Divider(
        height: 6,
        thickness: 0.8,
        color: PdfColors.black,
        borderStyle: pw.BorderStyle.dashed,
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
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              weight,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
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
