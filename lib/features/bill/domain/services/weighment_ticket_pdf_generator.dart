import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../settings/domain/entities/billing_settings.dart';
import '../entities/weighment.dart';
import '../../../customer/domain/entities/customer.dart';
import 'receipt_weight_resolver.dart';

/// Builds a professional, modern A4 invoice-style weighment document PDF.
///
/// Features:
/// - Full-width A4 Portrait document (210 mm x 297 mm) with elegant margins.
/// - Prominent Viyan Weighbridge letterhead and branding.
/// - Two-column vehicle, customer, and material summary card.
/// - Unified weight details with 3 visual highlight cards and a structured table.
/// - Financials, payment mode, and completed status breakdown.
/// - Operator note, authorized signatory signature lines, and print timestamp.
/// - Conforms to the single-weight rule: unrecorded weights render as `--`.
class WeighmentTicketPdfGenerator {
  const WeighmentTicketPdfGenerator();

  static final PdfColor _dark = PdfColor.fromHex('#0F172A');
  static final PdfColor _slate = PdfColor.fromHex('#475569');
  static final PdfColor _muted = PdfColor.fromHex('#94A3B8');
  static final PdfColor _steel = PdfColor.fromHex('#334155');
  static final PdfColor _lightBg = PdfColor.fromHex('#F8FAFC');
  static final PdfColor _cardBg = PdfColor.fromHex('#F1F5F9');
  static final PdfColor _border = PdfColor.fromHex('#CBD5E1');
  static final PdfColor _accentBorder = PdfColor.fromHex('#38BDF8');
  static final PdfColor _white = PdfColor(1, 1, 1, 1);
  static final PdfColor _green = PdfColor.fromHex('#15803D');
  static final PdfColor _greenBg = PdfColor.fromHex('#F0FDF4');

  Future<Uint8List> generateTicketPdf({
    required Weighment bill,
    required Customer? customer,
    required String materialName,
    required BillingSettings settings,
    DateTime? printedAt,
  }) async {
    final regularFontData = await rootBundle.load(
      'fonts/PlusJakartaSans-Regular.ttf',
    );
    final boldFontData = await rootBundle.load(
      'fonts/PlusJakartaSans-ExtraBold.ttf',
    );
    final pdfTheme = pw.ThemeData.withFont(
      base: pw.Font.ttf(regularFontData),
      bold: pw.Font.ttf(boldFontData),
    );
    final pdf = pw.Document(theme: pdfTheme);

    final weights = const ReceiptWeightResolver().resolve(bill);

    final vehicleNo = bill.vehicleNumber.isEmpty ? '—' : bill.vehicleNumber;
    final customerName = customer?.name ?? '—';
    final customerPhone = customer?.mobile ?? '';
    final dateFormatted = DateFormat('dd/MM/yyyy').format(bill.createdAt);
    final timeFormatted = DateFormat('hh:mm:ss a').format(bill.createdAt);
    final printDate = DateFormat(
      'dd/MM/yyyy HH:mm:ss',
    ).format(printedAt ?? DateTime.now());
    final isCompleted = bill.isCompleted;

    final hasSerial = settings.showSerialNumber;
    final hasDate = settings.showDate;
    final hasTime = settings.showTime;
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
    final hasCash = settings.showCashReceived;

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
        : (weights.grossKg != null ? dateFormatted : '--');
    final grossTime = weights.grossKg != null && bill.grossCapturedAt != null
        ? DateFormat('hh:mm a').format(bill.grossCapturedAt!)
        : (weights.grossKg != null
              ? DateFormat('hh:mm a').format(bill.createdAt)
              : '--');

    final tareDate = weights.tareKg != null && bill.tareCapturedAt != null
        ? DateFormat('dd/MM/yyyy').format(bill.tareCapturedAt!)
        : (weights.tareKg != null ? dateFormatted : '--');
    final tareTime = weights.tareKg != null && bill.tareCapturedAt != null
        ? DateFormat('hh:mm a').format(bill.tareCapturedAt!)
        : (weights.tareKg != null
              ? DateFormat('hh:mm a').format(bill.updatedAt)
              : '--');

    final logoPath = settings.logoPath?.trim();
    final hasLogo =
        logoPath != null && logoPath.isNotEmpty && File(logoPath).existsSync();

    final receiptTitleConfig = settings.receiptTitle.trim();
    final mainTitle = 'WEIGHMENT INVOICE';
    final subTitle = receiptTitleConfig.isNotEmpty ? receiptTitleConfig : null;

    final thinBorder = pw.BorderSide(color: _border, width: 0.8);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.portrait,
        margin: const pw.EdgeInsets.symmetric(horizontal: 26, vertical: 22),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: _white,
              border: pw.Border.all(color: _dark, width: 1.2),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // ── 1. COMPANY LETTERHEAD HEADER ─────────────
                pw.Center(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (hasLogo)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 6),
                          child: pw.Image(
                            pw.MemoryImage(File(logoPath).readAsBytesSync()),
                            height: 42,
                            fit: pw.BoxFit.contain,
                          ),
                        )
                      else
                        pw.Container(
                          width: 32,
                          height: 32,
                          margin: const pw.EdgeInsets.only(bottom: 6),
                          alignment: pw.Alignment.center,
                          decoration: pw.BoxDecoration(
                            color: _dark,
                            shape: pw.BoxShape.circle,
                            border: pw.Border.all(
                              color: _accentBorder,
                              width: 1.2,
                            ),
                          ),
                          child: pw.Text(
                            'VW',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: _white,
                            ),
                          ),
                        ),
                      pw.Text(
                        settings.businessName.isNotEmpty
                            ? settings.businessName
                            : 'VIYAN WEIGHBRIDGE',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: _dark,
                          letterSpacing: 1.4,
                        ),
                      ),
                      if (settings.businessSubtitle != null &&
                          settings.businessSubtitle!.trim().isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          settings.businessSubtitle!,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: _slate,
                          ),
                        ),
                      ],
                      if (settings.serviceText != null &&
                          settings.serviceText!.trim().isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          settings.serviceText!,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: _green,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                      if (settings.address != null &&
                          settings.address!.trim().isNotEmpty) ...[
                        pw.SizedBox(height: 3),
                        pw.Text(
                          settings.address!,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 8.5, color: _slate),
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
                              'Ph: ${settings.phoneNumber!}',
                            if (settings.email != null &&
                                settings.email!.trim().isNotEmpty)
                              'Email: ${settings.email!}',
                            if (settings.gstin != null &&
                                settings.gstin!.trim().isNotEmpty)
                              'GSTIN: ${settings.gstin!}',
                          ].join('  ·  '),
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 8.5, color: _slate),
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),
                pw.Divider(color: _border, thickness: 0.8),
                pw.SizedBox(height: 6),

                // ── 2. INVOICE TITLE & METADATA BAR ──────────
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: _lightBg,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4),
                    ),
                    border: pw.Border.all(color: _border, width: 0.8),
                  ),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            mainTitle,
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.5,
                              color: _dark,
                            ),
                          ),
                          if (subTitle != null)
                            pw.Text(
                              subTitle,
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 0.8,
                                color: _slate,
                              ),
                            ),
                        ],
                      ),
                      pw.Spacer(),
                      if (hasSerial)
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: pw.BoxDecoration(
                            color: _white,
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(4),
                            ),
                            border: pw.Border.all(color: _border, width: 0.8),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text(
                                'Bill No: ',
                                style: pw.TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: _slate,
                                ),
                              ),
                              pw.Text(
                                bill.billNumber,
                                style: pw.TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: _dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (hasDate || hasTime) ...[
                        pw.SizedBox(width: 12),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            if (hasDate)
                              pw.Text(
                                'Date: $dateFormatted',
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  color: _steel,
                                ),
                              ),
                            if (hasTime)
                              pw.Text(
                                'Time: $timeFormatted',
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  color: _steel,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                // ── 3. VEHICLE & PARTY SUMMARY CARD ──────────
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _white,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4),
                    ),
                    border: pw.Border.all(color: _border, width: 0.8),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left: Vehicle & Material
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (hasVehNo)
                              _buildInfoField(
                                'VEHICLE NO :',
                                vehicleNo,
                                isBold: true,
                                fontSize: 10.5,
                              ),
                            if (hasVehNo && hasMat) pw.SizedBox(height: 4),
                            if (hasMat)
                              _buildInfoField('MATERIAL :', materialName),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      // Right: Customer & Mobile
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (hasCustomer) ...[
                              _buildInfoField(
                                'CUSTOMER :',
                                customerName,
                                isBold: true,
                              ),
                              if (customerPhone.isNotEmpty) ...[
                                pw.SizedBox(height: 4),
                                _buildInfoField('MOBILE NO :', customerPhone),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                // ── 4. WEIGHT DETAILS SECTION ────────────────
                pw.Container(
                  decoration: pw.BoxDecoration(
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4),
                    ),
                    border: pw.Border.all(color: _border, width: 0.8),
                    color: _white,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // Section Header Bar
                      pw.Container(
                        color: _cardBg,
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: pw.Text(
                          'WEIGHT DETAILS',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1.0,
                            color: _dark,
                          ),
                        ),
                      ),

                      // 4A. 3 Visual KPI Cards: Gross | Tare | Net
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Row(
                          children: [
                            _buildWeightKpiCard(
                              title: 'GROSS WEIGHT',
                              weightDisplay: formatWeight(weights.grossKg),
                              dateText: grossDate,
                              timeText: grossTime,
                              hasValue: weights.grossKg != null,
                            ),
                            pw.SizedBox(width: 8),
                            _buildWeightKpiCard(
                              title: 'TARE WEIGHT',
                              weightDisplay: formatWeight(weights.tareKg),
                              dateText: tareDate,
                              timeText: tareTime,
                              hasValue: weights.tareKg != null,
                            ),
                            pw.SizedBox(width: 8),
                            _buildWeightKpiCard(
                              title: 'NET WEIGHT',
                              weightDisplay: formatWeight(weights.netKg),
                              dateText: '--',
                              timeText: '--',
                              hasValue: weights.netKg != null,
                              isNet: true,
                            ),
                          ],
                        ),
                      ),

                      pw.Divider(color: _border, thickness: 0.6),

                      // 4B. Detailed Weight Table
                      pw.Table(
                        border: pw.TableBorder(
                          horizontalInside: thinBorder,
                          verticalInside: thinBorder,
                        ),
                        columnWidths: const {
                          0: pw.FlexColumnWidth(2.4),
                          1: pw.FlexColumnWidth(1.8),
                          2: pw.FlexColumnWidth(1.6),
                          3: pw.FlexColumnWidth(2.0),
                        },
                        children: [
                          // Table Header
                          pw.TableRow(
                            decoration: pw.BoxDecoration(color: _lightBg),
                            children: [
                              _buildTableHeaderCell('Weight Type'),
                              _buildTableHeaderCell('Date'),
                              _buildTableHeaderCell('Time'),
                              _buildTableHeaderCell('Weight', alignRight: true),
                            ],
                          ),
                          // Gross Weight Row
                          if (hasGross)
                            pw.TableRow(
                              children: [
                                _buildTableCell('Gross Weight', isBold: true),
                                _buildTableCell(grossDate),
                                _buildTableCell(grossTime),
                                _buildTableCell(
                                  formatWeight(weights.grossKg),
                                  alignRight: true,
                                  isBold: true,
                                ),
                              ],
                            ),
                          // Tare Weight Row
                          if (hasTare)
                            pw.TableRow(
                              children: [
                                _buildTableCell('Tare Weight', isBold: true),
                                _buildTableCell(tareDate),
                                _buildTableCell(tareTime),
                                _buildTableCell(
                                  formatWeight(weights.tareKg),
                                  alignRight: true,
                                  isBold: true,
                                ),
                              ],
                            ),
                          // Net Weight Row
                          if (hasNet)
                            pw.TableRow(
                              decoration: pw.BoxDecoration(color: _greenBg),
                              children: [
                                _buildTableCell('Net Weight', isBold: true),
                                _buildTableCell('—'),
                                _buildTableCell('—'),
                                _buildTableCell(
                                  formatWeight(weights.netKg),
                                  alignRight: true,
                                  isBold: true,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                // ── 5. FINANCIALS & PAYMENT CARD ────────────
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _lightBg,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4),
                    ),
                    border: pw.Border.all(color: _border, width: 0.8),
                  ),
                  child: pw.Row(
                    children: [
                      // Charges
                      if (hasAmount) ...[
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'WEIGHMENT CHARGES',
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: _slate,
                                letterSpacing: 0.5,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              '₹${NumberFormat('#,##0.00').format(bill.amount)}',
                              style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: _dark,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 20),
                      ],

                      // Payment Mode
                      if (hasPayment) ...[
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'PAYMENT MODE',
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: _slate,
                                letterSpacing: 0.5,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              bill.paymentMode.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 10.5,
                                fontWeight: pw.FontWeight.bold,
                                color: _dark,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 20),
                      ],

                      // Cash Received
                      if (hasCash &&
                          bill.paymentMode.toUpperCase() == 'CASH') ...[
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'CASH RECEIVED',
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: _slate,
                                letterSpacing: 0.5,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              '₹${NumberFormat('#,##0.00').format(bill.amount)}',
                              style: pw.TextStyle(
                                fontSize: 10.5,
                                fontWeight: pw.FontWeight.bold,
                                color: _dark,
                              ),
                            ),
                          ],
                        ),
                      ],

                      pw.Spacer(),

                      // Status Badge
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: isCompleted ? _greenBg : _lightBg,
                          borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(4),
                          ),
                          border: pw.Border.all(
                            color: isCompleted ? _green : _border,
                            width: 0.8,
                          ),
                        ),
                        child: pw.Text(
                          'Status: ${isCompleted ? 'COMPLETED' : 'INCOMPLETE'}',
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            fontWeight: pw.FontWeight.bold,
                            color: isCompleted ? _green : _slate,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (hasRemarks) ...[
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: _white,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(4),
                      ),
                      border: pw.Border.all(color: _border, width: 0.8),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Direct delivery to site: ',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: _steel,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            bill.remarks!,
                            style: pw.TextStyle(fontSize: 8.5, color: _slate),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                pw.Spacer(),

                // ── 6. FOOTER NOTE & SIGNATURES ──────────────
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    if (hasFooter)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 4),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'Note: $footerNoteText',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: _steel,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ),
                    pw.SizedBox(height: 18),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        // Left: Driver signature
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(width: 140, height: 0.8, color: _dark),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "Driver's Signature",
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                color: _slate,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Right: Authorized signatory
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              settings.businessName.isNotEmpty
                                  ? settings.businessName
                                  : 'VIYAN WEIGHBRIDGE',
                              style: pw.TextStyle(
                                fontSize: 9.5,
                                fontWeight: pw.FontWeight.bold,
                                color: _dark,
                              ),
                            ),
                            pw.SizedBox(height: 14),
                            pw.Container(width: 160, height: 0.8, color: _dark),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Authorized Signatory',
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                color: _slate,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Center(
                      child: pw.Text(
                        '* Printed on: $printDate *',
                        style: pw.TextStyle(fontSize: 6.5, color: _muted),
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

    return pdf.save();
  }

  // ── Helper Widgets ────────────────────────────────────────

  static pw.Widget _buildInfoField(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 9.5,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 85,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8.5,
              color: _muted,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              color: _dark,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildWeightKpiCard({
    required String title,
    required String weightDisplay,
    required String dateText,
    required String timeText,
    required bool hasValue,
    bool isNet = false,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: pw.BoxDecoration(
          color: isNet ? _greenBg : _lightBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          border: pw.Border.all(
            color: isNet ? _green : _border,
            width: isNet ? 1.0 : 0.8,
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: isNet ? _green : _steel,
                letterSpacing: 0.5,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              weightDisplay,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: hasValue ? (isNet ? _green : _dark) : _muted,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Container(height: 0.6, color: _border),
            pw.SizedBox(height: 3),
            pw.Text(
              dateText == '--' ? 'Date : --' : 'Date : $dateText',
              style: pw.TextStyle(fontSize: 7.5, color: _slate),
            ),
            pw.Text(
              timeText == '--' ? 'Time : --' : 'Time : $timeText',
              style: pw.TextStyle(fontSize: 7.5, color: _slate),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableHeaderCell(
    String text, {
    bool alignRight = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: _steel,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool alignRight = false,
    bool isBold = false,
  }) {
    final isDash = text == '--';
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8.5,
          color: isDash ? _muted : _dark,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
